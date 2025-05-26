class svbt_channel_out_monitor extends svbt_base_unit;

   //LAB: declare the necessary modports, mailbox and variables

   function new (int port_id, virtual output_intf.rcv smp,
               svbt_packet_channel packet_mbox,
               virtual reset_intf.rcv smp_reset,
               string name,
               int id);
      super.new(name, id);
      //LAB: initialize the class fields
   endfunction : new

   task run();
      @(posedge smp_reset.rcv_cb.reset);

      //LAB: implement the monitoring, similar with the input interface monitor
   endtask: run

endclass : svbt_channel_out_monitor
