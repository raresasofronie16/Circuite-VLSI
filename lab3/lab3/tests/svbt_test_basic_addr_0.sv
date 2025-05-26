//LAB: include the new "includes" file

constraint svbt_packet::keep_address_fixed { address == 0; }
constraint svbt_packet::keep_length_fixed { length < 10; }

program test;
   svbt_environment env;
   initial begin
     env=new(15,"Environment",25);
     env.run();
   end
endprogram