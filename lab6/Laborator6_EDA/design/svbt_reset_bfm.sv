class svbt_reset_bfm extends svbt_base_unit;

//LAB: declare the modport of reset_intf (virtual)
   virtual interface reset_intf.drv smp_drv;

function new(virtual reset_intf.drv smp_drv,
	          string name, 
	          int id);
  super.new(name,id);
  //LAB: tie the virtual modport declared above with the one passed
  //through the parameter of the function new()
   this.smp_drv = smp_drv;
endfunction : new

task run();
  //LAB: wait 5 clock cycles then de-assert the reset signal for 2 cycles
    repeat(5) @(smp_drv.drv_cb);
    smp_drv.drv_cb.reset <= 1'b0;
    repeat(2) @(smp_drv.drv_cb);
    smp_drv.drv_cb.reset <= 1'b1;
endtask: run

endclass : svbt_reset_bfm
