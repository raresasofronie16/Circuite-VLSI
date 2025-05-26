class svbt_data_in_bfm extends svbt_base_unit;
  //the mailbox between the generator and the BFM
   svbt_packet_channel packet_mbox;
   
   //LAB: declare the modports the BFM needs (remember there are driving and receiving
   //modports defined in the interfaces)

   function new(svbt_packet_channel packet_mbox,
                virtual input_intf.drv smp_drv,
                virtual input_intf.rcv smp_rcv,
                virtual reset_intf.rcv smp_reset,
                string name,
                int id);
      super.new(name,id);
      //LAB: tie the mailbox and modports with the one passed by the environment as parameters
      //of the new() function
   endfunction : new

   task run();
      svbt_packet curent_packet;

      $display("[%0t] %s Starting to drive packets...", $time, super.name);

      forever begin
         //LAB: get a packet from the mailbox
         drive_packet(curent_packet);
      end
   endtask : run


   task drive_packet(svbt_packet pkt);
      //wait a number of cycles equal to the generated delay for each packet
      repeat (pkt.delay) @(smp_rcv.rcv_cb);

      //don't drive anything during reset and keep the current data on the bus while
      //'suspend_data_in' is asserted
      while((smp_rcv.rcv_cb.suspend_data_in==1'b1)||(smp_reset.rcv_cb.reset==0))
         @(smp_rcv.rcv_cb);

      //drive the packet, starting with the header
      smp_drv.drv_cb.packet_valid <= 1'b1;
      smp_drv.drv_cb.data <= { pkt.length , pkt.address };
      @(smp_rcv.rcv_cb);
      
      //LAB: continue the function with the driving of the rest of the packet

   endtask : drive_packet

endclass : svbt_data_in_bfm
