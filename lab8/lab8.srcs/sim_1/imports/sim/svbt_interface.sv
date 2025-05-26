
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

   sequence packet_end;
      @(posedge clock) (read_enb == 1'b1) ##1 (read_enb == 1'b0);
   endsequence		
   
   /*
	always@(packet_start) begin
     length = channel[7:2];
     fork 
         begin
            cnt_clks();
            check_validity();
         end
      join_none
	end
   */
   
	always@(posedge clock iff read_enb) begin
   //always@(packet_start) begin
         length = channel[7:2];
         counter = 0;
         fork
             begin
                cnt_clks();
                check_validity();
             end
          join_none


	
//	task cnt_clks();
//      while(read_enb) begin
//        @(posedge clock);
//        counter++;	   
//      end 
//	endtask
	
   
	/*
   task cnt_clks();
      counter = 0;
      length = channel[7:2];
      fork
         begin
            while (1) begin
               @(posedge clock);
               counter = counter+1;
            end
         end
         begin
            @(packet_end);
         end
      join_any
      disable fork;
   endtask
   */
//   task check_validity();
 
//    if (channel=='hx) $display("ERROR : Channel doesn't receive proper information");
   
//   endtask

   property chk_len;
     @(posedge clock) packet_end |-> (length == (counter-1));
   endproperty

   len_rule : assert property (chk_len)
      else $error("[%0t] ERROR: length is %0d counter is %0d", $time, length, counter);
endinterface : output_intf


module output_intf_utils;

   task automatic cnt_clks(input logic clock, input logic read_enb, output int counter);
      counter = 0;
      while (read_enb) begin
         @(posedge clock);
         counter++;
      end
   endtask

   task automatic check_validity(input [7:0] channel);
      if (channel === 'hx)
         $display("ERROR : Channel doesn't receive proper information");
   endtask

endmodule

