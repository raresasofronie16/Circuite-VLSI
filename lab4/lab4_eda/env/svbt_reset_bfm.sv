class svbt_reset_bfm extends svbt_base_unit;

//LAB: declare the modport of reset_intf (virtual)

function new(virtual reset_intf.drv smp_drv,
	          string name, 
	          int id);
  super.new(name,id);
  //LAB: tie the virtual modport declared above with the one passed
  //through the parameter of the function new()
endfunction : new

task run();
  //LAB: wait 5 clock cycles then de-assert the reset signal for 2 cycles
endtask: run

endclass : svbt_reset_bfm
