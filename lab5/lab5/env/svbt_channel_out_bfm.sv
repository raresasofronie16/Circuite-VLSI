class svbt_channel_out_bfm extends svbt_base_unit;

   virtual output_intf.drv smp_drv;
   virtual output_intf.rcv smp_rcv;
   svbt_channel_out_generator read_enb_gen;
   bit force_read_enable_deasserted;

   function new(virtual output_intf.drv smp_drv,
                virtual output_intf.rcv smp_rcv,
                svbt_channel_out_generator read_enb_gen,
                string name,
                int id);
      super.new(name,id);
      this.smp_drv = smp_drv;
      this.smp_rcv = smp_rcv;
      this.read_enb_gen=read_enb_gen;
   endfunction : new

   task run();
      int delay, length;

      forever begin
         if(force_read_enable_deasserted==0) begin
            @(posedge smp_rcv.rcv_cb.vld_chan);
            delay = read_enb_gen.generate_delay();
            repeat (delay) @(smp_drv.drv_cb);
            smp_drv.drv_cb.read_enb<=1'b1;
            @(smp_drv.drv_cb);
            length=smp_rcv.rcv_cb.channel[7:2];
            repeat(length+1) @(smp_drv.drv_cb);
            smp_drv.drv_cb.read_enb<=1'b0;
         end
         else @(smp_drv.drv_cb);
      end
   endtask: run

endclass: svbt_channel_out_bfm