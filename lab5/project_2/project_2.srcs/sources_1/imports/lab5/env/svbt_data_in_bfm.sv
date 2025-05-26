class svbt_data_in_bfm extends svbt_base_unit;

   mailbox packet_mbox;
   virtual input_intf.drv smp_drv;
   virtual input_intf.rcv smp_rcv;
   virtual reset_intf.rcv smp_reset;

   function new(mailbox packet_mbox,
                virtual input_intf.drv smp_drv,
                virtual input_intf.rcv smp_rcv,
                virtual reset_intf.rcv smp_reset,
                string name,
                int id);
      super.new(name,id);
      this.packet_mbox = packet_mbox;
      this.smp_drv = smp_drv;
      this.smp_rcv = smp_rcv;
      this.smp_reset = smp_reset;
   endfunction : new

   task run();
      svbt_packet curent_packet;

      $display("[%0t] %s Starting to drive packets...", $time, super.name);

      forever begin
         packet_mbox.get(curent_packet);
         drive_packet(curent_packet);
      end
   endtask : run


   task drive_packet(svbt_packet pkt);

      repeat (pkt.delay) @(smp_rcv.rcv_cb);

      while((smp_rcv.rcv_cb.suspend_data_in==1'b1)||(smp_reset.rcv_cb.reset==0))
         @(smp_rcv.rcv_cb);

      smp_drv.drv_cb.packet_valid <= 1'b1;
      smp_drv.drv_cb.data <= { pkt.length , pkt.address };
      @(smp_rcv.rcv_cb);
      
      while(smp_rcv.rcv_cb.suspend_data_in) begin
         smp_drv.drv_cb.data <= { pkt.length , pkt.address };
         @(smp_rcv.rcv_cb);
      end

      for(int i=0;i<pkt.data.size();i++) begin
         smp_drv.drv_cb.data <= pkt.data[i];
         @(smp_rcv.rcv_cb);
         if(smp_rcv.rcv_cb.suspend_data_in) i--;
      end

      smp_drv.drv_cb.packet_valid <= 1'b0;
      smp_drv.drv_cb.data <= pkt.parity;
      while(smp_rcv.rcv_cb.suspend_data_in) begin
         smp_drv.drv_cb.data <= pkt.parity;
         @(smp_rcv.rcv_cb);
      end

      @(smp_rcv.rcv_cb);
      smp_drv.drv_cb.data <= 8'b0;

   endtask : drive_packet

endclass : svbt_data_in_bfm
