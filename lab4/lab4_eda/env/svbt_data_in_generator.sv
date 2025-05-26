class svbt_data_in_generator extends svbt_base_unit;

   //LAB: declare the maximum number of packets to send and a packet counter
   
   //mailbox between the generator and the BFM
   svbt_packet_channel packet_mbox;
   svbt_packet curent_packet;

   function new(svbt_packet_channel packet_mbox,
                int max_number_of_packets,
                string name,
                int id);
   super.new(name,id);
   curent_packet = new;
   //LAB: initialize the packet mailbox and the maximum number of packets to generate
   //with the values passed as parameters from the environment unit
   endfunction : new

   task run();
      svbt_packet pkt2send;

      $display("[%0t] %s Starting to generate %0d packets...", $time,
            super.name, max_number_of_packets);

      while (pkts_counter < max_number_of_packets) begin
         pkt2send = get_packet(pkts_counter);
         //LAB: put the generated packet in the mailbox and add extra code needed here (if needed)
      end

   endtask : run

   //LAB: implement the get_packet task (remember the tasks implemented in the packet class
   //and the predefined functions of SystemVerilog)

endclass : svbt_data_in_generator
