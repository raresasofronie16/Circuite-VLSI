

constraint svbt_packet::keep_address_fixed { address == 0; }
//LAB: add an external constraint to keep the length of the packets smaller than 10
constraint svbt_packet::keep_pkt_length { length < 10; }


program test;
   svbt_packet pkt;

   initial begin
     //LAB: allocate a new instance of type svbt_packet
     pkt = new();
     
     //LAB: call pkt.display to see the default values
     pkt.display("default");
     
     //LAB: randomize the packet
     pkt.randomize();
      
     //LAB: display the packet after randomization
     pkt.display("randomized packet");
     
     //LAB: make an inline constraint - randomize() with {}
     pkt.randomize() with { pkt.length >= 8; };
     
     //LAB: display the packet after the second randomization
     pkt.display("second randomized packet cu length 8");
   
   end
endprogram