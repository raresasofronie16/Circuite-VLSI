`ifndef SVBT_DATA_IN_MON
`define SVBT_DATA_IN_MON
class svbt_data_in_monitor extends svbt_base_unit;

   svbt_packet curent_packet;
   
   //declare the necessary modports and mailbox
   virtual input_intf.rcv smp;
   virtual reset_intf.rcv smp_reset;
   svbt_packet_channel packet_mbox;
	int pkt_id;
   event ended;

   covergroup packet_cover @(ended);
      //LAB: define coverpoints for the packet fields (bins are always good also)
      //LAB: define coverpoints for the 'suspend_data_in' and 'err' signals
      //LAB: define meaningful crosses between the coverpoints
    coverpoint curent_packet.length
    {
        bins len_small = {[0:3]};
        bins len_medium = {[4:10]};
        bins len_large = {[11:63]};
        
    }
    
    coverpoint curent_packet.address
    {
        bins addr0 = {0};
        bins addr1 = {1};
        bins addr2 = {2};
    
    }
    
    coverpoint curent_packet.pkt_length
    {
        bins is_SMALL = {SMALL};
        bins is_MEDIUM = {MEDIUM};
        bins is_LARGE = {LARGE};
    
    }
    
    


    coverpoint curent_packet.delay
    {
        bins delay_mic = {[1:3]};
        bins delay_mediu = {[4:7]};
        bins delay_mare = {[8:10]};
    
    }
    
    
    coverpoint curent_packet.flag_mismatched_parity
    {
        bins good_parity = {0};
        bins bad_parity = {1};
    
    }
    
    coverpoint smp.rcv_cb.suspend_data_in
    {
        bins active = {1};
        bins inactive = {0};
    
    
    }
    
    
    coverpoint smp.rcv_cb.err 
    {
         bins error     = {1};
         bins no_error  = {0};
    
      }


    cross curent_packet.pkt_length, curent_packet.flag_mismatched_parity;
    cross curent_packet.delay, smp.rcv_cb.suspend_data_in;
    cross curent_packet.flag_mismatched_parity, smp.rcv_cb.err;
    cross curent_packet.address, smp.rcv_cb.err;

      //LAB: remember to emit the 'ended' event!
   endgroup			  

   //field that uniquely identifies each monitored packet
   int pkt_id;

   function new( virtual input_intf.rcv smp,
                 virtual reset_intf.rcv smp_reset,
                 svbt_packet_channel packet_mbox,
                 string name,
                 int id);
      super.new(name,id);
      //LAB: tie the modports and mailbox with the ones sent by the environment as parameters
      this.smp = smp;
      this.smp_reset = smp_reset;
      this.packet_mbox = packet_mbox;
      pkt_id = 0;
   endfunction : new

   task run();
      //wait for the reset to toggle
      @(posedge smp_reset.rcv_cb.reset);

      forever begin

         curent_packet = new;

         if(smp.rcv_cb.packet_valid == 1'b1) begin
            curent_packet.length = smp.rcv_cb.data[7:2];
            //get the address
            curent_packet.address = smp.rcv_cb.data[1:0];
            
            if(smp.rcv_cb.suspend_data_in) begin
               @(negedge smp.rcv_cb.suspend_data_in);
            end
            @(smp.rcv_cb);

            //LAB: continue for the rest of the packet
            for (int i = 0; i < curent_packet.length; i++) begin
                curent_packet.data.push_back(smp.rcv_cb.data);

                if(smp.rcv_cb.suspend_data_in)begin
                @(negedge smp.rcv_cb.suspend_data_in);
                end
                @(smp.rcv_cb);
            end

            curent_packet.parity = smp.rcv_cb.data;
            
            curent_packet.id = pkt_id;
            void'(curent_packet.display("DATA_IN_MONITOR:"));

            //put the complete packet in the mailbox
            packet_mbox.put(curent_packet);
            pkt_id++;
         end

         @(smp.rcv_cb);
      end
   endtask :run

endclass: svbt_data_in_monitor
`endif