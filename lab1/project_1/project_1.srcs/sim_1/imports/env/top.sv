
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

   router router1 (.clk             (clock), // input
                   .reset_b         (reset), // input
                   .packet_valid    (packet_valid), // input
                   .data            (data), // input
                   .channel0        (channel0), // output
                   .vld_chan_0      (vld_chan_0), // output
                   .read_enb_0      (read_enb_0), // input
                   
                   .channel1(channel1),
                   .channel2(channel2),
                   .vld_chan_1(vld_chan_1),
                   .vld_chan_2(vld_chan_2),
                   .read_enb_1(read_enb_1),
                   .read_enb_2(read_enb_2),            
                   
                   .suspend_data_in (suspend_data_in), // output
                   .err             (err)); // output

   reset_intf reset_intf(
      .clock(clock),
      .reset(reset)
   );

   input_intf input_intf(
      .clock(clock),
      .packet_valid(packet_valid),
      .data(data),
      .err(err),
      .suspend_data_in(suspend_data_in)
   );

   output_intf output_intf0(
      .clock(clock),
      .channel(channel0),
      .vld_chan(vld_chan_0),
      .read_enb(read_enb_0)
   );

   output_intf output_intf1(
      .clock(clock),
      .channel(channel1),
      .vld_chan(vld_chan_1),
      .read_enb(read_enb_1)
   );

   output_intf output_intf2(
      .clock(clock),
      .channel(channel2),
      .vld_chan(vld_chan_2),
      .read_enb(read_enb_2)
   );

   // Clock generator
   initial begin
     $dumpfile("dump.vcd");
     $dumpvars;
      clock = 0;
      forever begin
        #50 clock = !clock;
          $finish;
      end
   end


endmodule
