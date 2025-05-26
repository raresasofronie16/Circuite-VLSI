`include "svbt_include.sv"

constraint svbt_packet::keep_address_fixed { address == 0; }
constraint svbt_packet::keep_length_fixed { length < 10; }

class test_addr;
  task test(virtual reset_intf reset_interface,
          virtual input_intf input_interface,
          virtual output_intf output_intf0,
          virtual output_intf output_intf1,
          virtual output_intf output_intf2);
	
    svbt_environment env;

    env=new(15,"Environment",25, reset_interface, input_interface, output_intf0, output_intf1, output_intf2);
    env.run();

  endtask
endclass:test_addr