`include "svbt_include.sv"

//LAB: implement a test where all stimulus is random
//remember to use 'constraint_mode(0)' for the constraints you want to disable

constraint svbt_channel_out_generator::keep_delay_random {delay inside {[0:10]}; }

program test;
    svbt_environment env;
    initial begin
        env = new(100, "Environment", 7);
        env.channel_out_bfm[0].read_enb_gen.keep_delay_0.constrainy_mode(0);
        env.channel_out_bfm[1].read_enb_gen.keep_delay_0.constrainy_mode(0);
        env.channel_out_bfm[2].read_enb_gen.keep_delay_0.constrainy_mode(0);
        env.run();
    end


endprogram

