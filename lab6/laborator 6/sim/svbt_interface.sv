
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
   
   int counter = 0;
   logic [5:0] length;

   sequence packet_start;
       @(posedge clock) (read_enb == 1'b0) ##1 (read_enb == 1'b1);
   endsequence

   always@(packet_start) begin
     length = channel[7:2];
     fork
         begin
            cnt_clks();
            check_validity();
         end
      join_none
   end


   //LAB: define the sequence 'packet_end'
   
   task cnt_clks();
      //LAB: implement the function that counts the number of data cycles
   endtask
   
   task check_validity();
      if (channel=='hx) $display("ERROR : Channel doesn't receive proper information");
   endtask

   //LAB: define the 'chk_len' property which should say that at packet_end the length in the
   //packet header is equal to the data cycles counted


   len_rule : assert property (chk_len)
      else $error("[%0t] ERROR: length is %0d counter is %0d", $time, length, counter);
endinterface : output_intf
