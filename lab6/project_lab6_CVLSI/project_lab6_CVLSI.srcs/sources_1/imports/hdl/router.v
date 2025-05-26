`include "demux.v"
`include "fifo.v"
`include "memory.v"

module router (clk,
	       reset_b,
               packet_valid,                     
               data,                           
               channel0, 
	       channel1, 
	       channel2,     
               vld_chan_0, 
	       vld_chan_1, 
	       vld_chan_2,
               read_enb_0, 
	       read_enb_1, 
	       read_enb_2,
               suspend_data_in,                   
               err);                            


   input          clk;
   input 	  reset_b;
   
   input          packet_valid;
   input [7:0] 	  data;
   output [7:0]   channel0;
   output [7:0]   channel1;
   output [7:0]   channel2;
   output         vld_chan_0;
   output 	  vld_chan_1;
   output 	  vld_chan_2;
   input 	  read_enb_0;
   input 	  read_enb_1;
   input 	  read_enb_2;
   output         suspend_data_in;
   output         err;

   reg 		  err;
   wire 	  new_err;
   
   reg [1:0] 	  pv_r;    //packet valid register
   wire [1:0] 	  new_pv;  //new value for the packet valid register
   wire 	  pv;      //asserted if header, data or parity

   reg [7:0] 	  v_data;  //data validated by "pv" and "suspend_data_in"
   
   reg [7:0] 	  parity_r;   //parity register
   wire [7:0] 	  new_parity; //new value for the parity register

   reg [7:0] 	  data_r;     //data register
   wire [1:0] 	  address;    //address used for demux-ing the "write enable" signal
   reg [1:0] 	  address_r;  //the address register
   wire [1:0] 	  new_address;//the new value for the address register

   wire [3:0] 	  write;    //the write enable signals, write[3] is not connected
   wire [2:0] 	  suspend;  //the "full" signals from the 3 output channels
   wire [8:0] 	  p_data;   //{packet_valid,data}

   wire [2:0]	  dav;   //"fifo not empty" signals from the 3 output channels
   wire [2:0] 	  o_pv;  //output packet valid, read from fifo

   assign 	  new_pv = {pv_r[0],packet_valid};//00 - IDLE, 01 - HEADER, 11 - DATA, 10 - PARITY
   
   always @(posedge clk or negedge reset_b)
     begin
	if (reset_b == 0)
	  begin
	     pv_r = 2'b0;
	     data_r <= 0;
	     err <= 0;
	  end
	else
	  begin
	     err <= new_err;
	     data_r <= data;
	     if (suspend_data_in)
	       pv_r <= pv_r;
	     else
	       pv_r <= new_pv;
	  end
     end

   assign         pv = |new_pv;
   
   //assign 	  v_data = pv ? (data) : parity_r;//same as "data" if header, valid data or parity, gets new_parity to 0 if parity is OK
   always @(pv or suspend_data_in or data or parity_r)
     begin
	if (pv)
	  begin
	     if (suspend_data_in)
	       v_data = 0;
	     else
	       v_data = data;
	  end
	else
	  begin
	     v_data = parity_r;
	  end
     end
   
   assign 	  new_parity = parity_r ^ v_data;
   
   assign 	  new_address = data[1:0];
      
   always @(posedge clk or negedge reset_b)
     begin
	if (reset_b == 0)
	  begin
	     address_r <= 2'b11;//no outport selected
	     parity_r <= 0;
	  end
	else
	  begin
	     parity_r <= new_parity;
	     case (new_pv)
	       2'b00: //IDLE
		 begin
		    address_r <= 2'b11;
		 end
	       2'b01: //HEADER
		 begin
		    address_r <= new_address;
		    parity_r <= data;
		 end
	       2'b11: //DATA
		 begin
		    address_r <= address_r;
		 end
	       2'b10: //PARITY
		 begin
		    address_r <= 2'b11;
		 end
	     endcase // case(pv_r)
	  end
     end

   assign address = (new_pv == 2'b01) ? new_address : address_r;
   assign new_err = (pv_r == 2'b10) && (|parity_r);
   
   assign 	  p_data = {packet_valid,data};
   assign 	  {vld_chan_2,vld_chan_1,vld_chan_0} = dav & o_pv;
   
   demux we(
	    .in(address),
	    .out(write)
	    );
   
   fifo f0(
	   .clk(clk),
	   .reset_b(reset_b),
	   .write(write[0]),
	   .data_in(p_data), //date si packet_valid
	   .read(read_enb_0),
	   .data_out({o_pv[0],channel0}),//si valid channel
	   .dav(dav[0]), // ???
	   .full(suspend[0])
	   );
   
   fifo f1(
	   .clk(clk),
	   .reset_b(reset_b),
	   .write(write[1]),
	   .data_in(p_data),
	   .read(read_enb_1),
	   .data_out({o_pv[1],channel1}),
	   .dav(dav[1]),
	   .full(suspend[1])
	   );
   
   fifo f2(
	   .clk(clk),
	   .reset_b(reset_b),
	   .write(write[2]),
	   .data_in(p_data),
	   .read(read_enb_2),
	   .data_out({o_pv[2],channel2}),
	   .dav(dav[2]),
	   .full(suspend[2])
	   );

   assign 	  suspend_data_in = |suspend;
endmodule // router

