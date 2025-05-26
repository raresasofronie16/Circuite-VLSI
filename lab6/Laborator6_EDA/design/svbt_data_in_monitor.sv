class svbt_data_in_monitor extends svbt_base_unit;

   svbt_packet curent_packet;
   
   //LAB: declare the necessary modports and mailbox
  virtual input_intf.rcv smp;
  virtual reset_intf.rcv smp_reset;
  svbt_packet_channel packet_mbox;

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
            //LAB: get the address
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

            //LAB: put the complete packet in the mailbox
           packet_mbox.put(curent_packet);
           pkt_id++;
         end

         @(smp.rcv_cb);
      end
   endtask :run

endclass: svbt_data_in_monitor