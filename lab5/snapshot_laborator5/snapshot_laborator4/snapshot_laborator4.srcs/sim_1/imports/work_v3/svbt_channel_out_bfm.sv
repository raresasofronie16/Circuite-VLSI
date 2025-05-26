`ifndef SVBT_CHANN_OUT
`define SVBT_CHANN_OUT

`include "svbt_channel_out_generator.sv"

class svbt_channel_out_bfm extends svbt_base_unit;

   //LAB: declare the modports needed here
   virtual output_intf.drv smp_drv;
   virtual output_intf.rcv smp_rcv;
   
   //instance of the generator (since it only generates a delay for
   //the 1 bit value for the read_enb wire, there is no need to declare
   //a mailbox between the generator and the BFM)
   svbt_channel_out_generator read_enb_gen;
   
   //this bit is needed for the cases when we want to force the
   //backpressure mechanism to take effect
   bit force_read_enable_deasserted;

   function new(virtual output_intf.drv smp_drv,
                virtual output_intf.rcv smp_rcv,
                svbt_channel_out_generator read_enb_gen,
                string name,
                int id);
      super.new(name,id);
      //LAB: make the necessary connections
      this.smp_drv = smp_drv;
      this.smp_rcv = smp_rcv;
      this.read_enb_gen=read_enb_gen;
   endfunction : new

   task run();
      int delay, length;

      forever begin
         if(force_read_enable_deasserted==0) begin
            //LAB: implement the functionality of the BFM
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

`endif