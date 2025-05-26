// Code your testbench here
// or browse Examples

`include "top_inst.sv"
`include "svbt_test_basic_addr_0.sv"

module top();
  
   reg          clock;
   reg          reset;
   reg          packet_valid;
   reg    [7:0] data;
   wire   [7:0] channel0;
   wire   [7:0] channel1;
   wire   [7:0] channel2;
   wire         vld_chan_0;
   wire         vld_chan_1;
   wire         vld_chan_2;
   reg          read_enb_0;
   reg          read_enb_1;
   reg          read_enb_2;
   wire         suspend_data_in;
   wire         err;
  
  top_inst inst(clock, reset, packet_valid, data, channel0, channel1, channel2, vld_chan_0, vld_chan_1, vld_chan_2, read_enb_0, read_enb_1, read_enb_2, suspend_data_in, err);
  
     //Clock generator
   initial begin
      clock = 0;
      forever begin
         #50 clock = !clock;
      end
   end
  
  test_addr test_principal = new();
  
  initial begin
    //conectam input-urile 
    assign reset = inst.reset_intf.reset;
    assign packet_valid = inst.input_intf.packet_valid;
    //se va continua asignarea pentru toate semnalele notate ca input in top_inst.sv
    assign data = inst.input_intf.data;
    assign read_enb_0 = inst.output_intf0.read_enb;
    assign read_enb_1 = inst.output_intf1.read_enb;
    assign read_enb_2 = inst.output_intf2.read_enb;
    
      test_principal.test(inst.reset_intf, inst.input_intf,
                      inst.output_intf0, inst.output_intf1, 
                      inst.output_intf2);
  end
  

  
    initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars(0,inst);
    end
 
endmodule