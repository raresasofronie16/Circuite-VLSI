
interface reset_intf(
   input wire clock,
   output logic reset
);

   clocking drv_cb@(posedge clock);
      output reset;
   endclocking
   modport drv(clocking drv_cb, input clock);

   clocking rcv_cb@(posedge clock);
      input reset;
   endclocking
   modport rcv(clocking rcv_cb, input clock);

endinterface: reset_intf


interface input_intf(
   input wire clock,
   output bit packet_valid,
   output bit [7:0] data,
   input bit err,
   input bit suspend_data_in
);

   clocking drv_cb @(negedge clock);
      output packet_valid;
      output data;
   endclocking
   modport drv(clocking drv_cb, input clock);


   clocking rcv_cb @(negedge clock);
      input packet_valid;
      input data;
      input err;
      input suspend_data_in;
   endclocking
   modport rcv(clocking rcv_cb, input clock);

endinterface : input_intf


interface output_intf(
   input  wire clock,
   input  wire [7:0] channel,
   input  wire vld_chan,
   output bit read_enb
);

   clocking drv_cb @(negedge clock);
      output read_enb;
   endclocking
   modport drv(clocking drv_cb, input clock);

   
   clocking rcv_cb @(negedge clock);
      input channel;
      input vld_chan;
      input read_enb;
   endclocking
   modport rcv(clocking rcv_cb, input clock);
   
endinterface : output_intf
