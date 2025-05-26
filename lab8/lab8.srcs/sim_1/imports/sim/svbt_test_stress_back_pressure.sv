`include "../env/svbt_include.sv"

constraint svbt_channel_out_generator::keep_delay_random{delay==100;}

program test;
  svbt_environment env;

  initial begin
    env=new(100,"Environment",7);
    env.channel_out_bfm[0].read_enb_gen.keep_delay_0.constraint_mode(0);    
    env.channel_out_bfm[1].read_enb_gen.keep_delay_0.constraint_mode(0); 
    env.channel_out_bfm[2].read_enb_gen.keep_delay_0.constraint_mode(0);        
    env.run();
   end
endprogram