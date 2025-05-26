`include "../env/svbt_interface.sv"
`include "../env/svbt_packet.sv"

constraint svbt_packet::keep_address_fixed { address == 0; }
//LAB: add an external constraint to keep the length of the packets smaller than 10

program test;
   svbt_packet pkt;

   initial begin
     //LAB: allocate a new instance of type svbt_packet
     //LAB: call pkt.display to see the default values
     //LAB: randomize the packet 
     //LAB: display the packet after randomization
     //LAB: make an inline constraint - randomize() with {}
     //LAB: display the packet after the second randomization
   end
endprogram