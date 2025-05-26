`include "svbt_include.sv"

constraint svbt_packet::keep_flag_mismatched_parity_1 { flag_mismatched_parity==1; }

program test;
   svbt_environment env;
   initial begin
     env=new(15,"Environment",25);
     env.data_in_generator.curent_packet.
       keep_flag_mismatched_parity_0.constraint_mode(0);
     env.run();
   end
endprogram