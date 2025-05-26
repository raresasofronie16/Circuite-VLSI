`ifndef SVBT_DATA_IN_GENERATOR
`define SVBT_DATA_IN_GENERATOR

class svbt_data_in_generator extends svbt_base_unit;

   //LAB: declare the maximum number of packets to send and a packet counter
   int max_number_of_packets;
   int pkts_counter;
   
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
   this.packet_mbox = packet_mbox;
   this.max_number_of_packets = max_number_of_packets;
   endfunction : new

   task run();
      svbt_packet pkt2send;

      $display("[%0t] %s Starting to generate %0d packets...", $time,
            super.name, max_number_of_packets);

      while (pkts_counter < max_number_of_packets) begin
         pkt2send = get_packet(pkts_counter);
         //LAB: put the generated packet in the mailbox and add extra code needed here (if needed)
         packet_mbox.put(pkt2send);
         pkts_counter++;
      end

   endtask : run

   //LAB: implement the get_packet task (remember the tasks implemented in the packet class
   //and the predefined functions of SystemVerilog)
   
   function svbt_packet get_packet(int id);
      assert (this.curent_packet.randomize()) else $error("Contradiction!");
      curent_packet.id = id;
      get_packet = curent_packet.copy();
   endfunction : get_packet

endclass : svbt_data_in_generator

`endif