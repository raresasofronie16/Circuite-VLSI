`ifndef SVBT_CHANN_OUT_MON
`define SVBT_CHANN_OUT_MON
class svbt_channel_out_monitor extends svbt_base_unit;

   //LAB: declare the necessary modports, mailbox and variables
    virtual output_intf.rcv smp;
    svbt_packet_channel packet_mbox;
    virtual reset_intf.rcv smp_reset;
    int port_id;
   

   function new (int port_id, virtual output_intf.rcv smp,
               svbt_packet_channel packet_mbox,
               virtual reset_intf.rcv smp_reset,
               string name,
               int id);
      super.new(name, id);
      //LAB: initialize the class fields
      this.smp = smp;
      this.packet_mbox = packet_mbox;
      this.smp_reset = smp_reset;
      this.port_id = port_id;
      
      
   endfunction : new

   task run();
        svbt_packet pkt;

      @(posedge smp_reset.rcv_cb.reset);

      //LAB: implement the monitoring, similar with the input interface monitor

        forever 
        begin
        @(smp.rcv_cb);
            if(smp.rcv_cb.vld_chan == 1'b1)
            begin
                pkt = new;

//header
                pkt.length = smp.rcv_cb.channel[7:2];
                pkt.address = smp.rcv_cb.channel[1:0];

//R date din pkt            
                for(int i=0; i<pkt.length; i=i+1)
                begin
                    @(smp.rcv_cb);
                    pkt.data.push_back(smp.rcv_cb.channel);
                
                end
                
                @(smp.rcv_cb)
                pkt.parity = smp.rcv_cb.channel;
            
                packet_mbox.put(pkt);
            
            
                
            end    
        
        
        end
        
        
   
   endtask: run

endclass : svbt_channel_out_monitor

`endif