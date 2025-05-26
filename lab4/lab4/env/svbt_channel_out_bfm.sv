class svbt_channel_out_bfm extends svbt_base_unit;

   //LAB: declare the modports needed here

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
   endfunction : new

   task run();
      int delay, length;

      forever begin
         if(force_read_enable_deasserted==0) begin
            //LAB: implement the functionality of the BFM
         end
         else @(smp_drv.drv_cb);
      end
   endtask: run

endclass: svbt_channel_out_bfm