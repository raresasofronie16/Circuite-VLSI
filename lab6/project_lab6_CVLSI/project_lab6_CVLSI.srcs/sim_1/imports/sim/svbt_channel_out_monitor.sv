`ifndef SVBT_CHANN_OUT_MON
`define SVBT_CHANN_OUT_MON
class svbt_channel_out_monitor extends svbt_base_unit;

   //LAB: declare the necessary modports, mailbox and variables
   int port_id;
   svbt_packet curent_packet;
   virtual output_intf.rcv smp;
   svbt_packet_channel packet_mbox;
   virtual reset_intf.rcv smp_reset;
   int pkt_id;

   function new (int port_id, virtual output_intf.rcv smp,
               svbt_packet_channel packet_mbox,
               virtual reset_intf.rcv smp_reset,
               string name,
               int id);
      super.new(name, id);
      //LAB: initialize the class fields
      this.port_id = port_id;
      this.smp = smp;
      this.smp_reset = smp_reset;
      this.packet_mbox = packet_mbox;
      pkt_id = 0;
   endfunction : new

   task run();
      @(posedge smp_reset.rcv_cb.reset);

      //LAB: implement the monitoring, similar with the input interface monitor
       forever begin
         while((smp.rcv_cb.vld_chan == 1'b0)&&(smp.rcv_cb.read_enb == 1'b0))
            @(smp.rcv_cb);

         curent_packet = new;
         @(smp.rcv_cb);

         while (smp.rcv_cb.vld_chan == 1'b1) begin
            curent_packet.length = smp.rcv_cb.channel[7:2];
            curent_packet.address = smp.rcv_cb.channel[1:0];

            @(smp.rcv_cb);
            for (int i = 0; i < curent_packet.length; i++) begin
            curent_packet.data.push_back(smp.rcv_cb.channel);
            @(smp.rcv_cb);
            end
         end

         curent_packet.parity = smp.rcv_cb.channel;
         curent_packet.id = pkt_id;
         
         void'(curent_packet.display($psprintf("CHANNEL_OUT_MONITOR%0d",id)));
         packet_mbox.put(curent_packet);
         pkt_id++;
         
         @(smp.rcv_cb);
      end
   endtask: run

endclass : svbt_channel_out_monitor
`endif