
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
   //this clocking block is used for driving
   clocking drv_cb @(negedge clock);
      output packet_valid;
      output data;
   endclocking
   modport drv(clocking drv_cb, input clock);

   //this clocking block is used for monitoring
   clocking rcv_cb @(negedge clock);
      input packet_valid;
      input data;
      input err;
      input suspend_data_in;
   endclocking
   modport rcv(clocking rcv_cb, input clock);

endinterface : input_intf


// output_intf output_intf0(
//      .clock(clock),
//      .channel(channel0),
//      .vld_chan(vld_chan_0),
//      .read_enb(read_enb_0)
//   );
interface output_intf(
  //LAB: define the output interface and its clocking blocks and modports
  //(this is a single interface that you will instantiate 3 times in top.sv,
  //one instance per physical interface of the DUT)
  //(hint: notice how the direction of the signals is declared in the driving and monitoring
  //clocking blocks of the input interface defined above)
  input wire clock,
  input bit [7:0] channel,
  input bit vld_chan,
  output bit read_enb
  
);
    
    
//     //this clocking block is used for driving
//   clocking drv_cb @(negedge clock);
//      output packet_valid;
//      output data;
//   endclocking
//   modport drv(clocking drv_cb, input clock);

//   //this clocking block is used for monitoring
//   clocking rcv_cb @(negedge clock);
//      input packet_valid;
//      input data;
//      input err;
//      input suspend_data_in;
//   endclocking
//   modport rcv(clocking rcv_cb, input clock);

    clocking drv_cb @(posedge clock);
        output read_enb;
    endclocking
    modport drv(clocking drv_cb , input clock);
    
    clocking rcv_cb @(posedge clock);
        input channel;
        input vld_chan;
    endclocking
    modport rcv(clocking rcv_cb, input clock);
    
endinterface : output_intf
