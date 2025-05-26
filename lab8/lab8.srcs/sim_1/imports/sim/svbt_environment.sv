`include "svbt_data_in_generator.sv"
`include "svbt_data_in_bfm.sv"
`include "svbt_reset_bfm.sv"
`include "svbt_channel_out_generator.sv"
`include "svbt_channel_out_bfm.sv"
`include "svbt_data_in_monitor.sv"
`include "svbt_channel_out_monitor.sv"
//`include "data_in_monitor.sv"

class svbt_environment extends svbt_base_unit;

   int number_of_packets;

   //a smart queue of all the units instantiated in the environment;
   //this is very useful for modularization, because you can take out any
   //environment component and the remaining ones will still work
   svbt_base_unit units[$];
   svbt_packet_channel packet_mbox, data_in_mbox, channel_out_mbox[$];

   svbt_data_in_generator data_in_generator;
   svbt_data_in_bfm data_in_bfm;
   svbt_data_in_monitor data_in_monitor;										

   svbt_reset_bfm reset_bfm;

   svbt_channel_out_generator channel_out_generator[$];
   svbt_channel_out_bfm channel_out_bfm[$], ch_out_bfm;
   svbt_channel_out_monitor channel_out_monitor;												

   svbt_scoreboard scbd;
   int counter=0, watchdog=200000;													  
   bit force_read_enable_deasserted;

   function new (int unsigned number_of_packets,
                  string name,
                  int id);
      super.new(name,id);
      this.number_of_packets=number_of_packets;

      //Reset BFM
      reset_bfm = new(top.reset_intf.drv, "RESET_BFM", 0);
      units.push_back(reset_bfm);

      //Input channel generator
      //notice how 'packet_mbox' is sent to both BFM and generator as parameters
      //to their constructor
      packet_mbox=new();
      data_in_generator = new(packet_mbox,
                              number_of_packets,
                              "DATA_IN_GENERATOR",
                              1);
      units.push_back(data_in_generator);

      //Input channel BFM
      data_in_bfm = new(packet_mbox,
                        top.input_intf.drv,
                        top.input_intf.rcv,
                        top.reset_intf.rcv,
                        "DATA_IN_BFM", 2);
      units.push_back(data_in_bfm);

      //Channel in monitor
      data_in_mbox=new();
      data_in_monitor=new(top.input_intf.rcv,
                           top.reset_intf.rcv,
                           data_in_mbox,
                           "DATA_IN_MONITOR",
                           3);
      units.push_back(data_in_monitor);				  
      //Output channel BFM + generator
      for(int i=0; i<3; i++) begin
         svbt_packet_channel temp_mbox = new;
         channel_out_mbox.push_back(temp_mbox);

         channel_out_generator[i] = new("CHANNEL_OUT_GENERATOR", i);
         case (i)
            0 : begin ch_out_bfm = new(top.output_intf0.drv,
                                       top.output_intf0.rcv,
                                       channel_out_generator[i],
                                       "CHANNEL_OUT_BFM0",
                                       0);
            end
            
            //continue for 1 and 2
            1 : begin ch_out_bfm = new(top.output_intf1.drv,
                                       top.output_intf1.rcv,
                                       channel_out_generator[i],
                                       "CHANNEL_OUT_BFM1",
                                       1);
            end
            2 : begin ch_out_bfm = new(top.output_intf2.drv,
                                       top.output_intf2.rcv,
                                       channel_out_generator[i],
                                       "CHANNEL_OUT_BFM2",
                                       2);
            end
         endcase
         //push the BFMs into the 'units' queue
         channel_out_bfm.push_back(ch_out_bfm);
         units.push_back(ch_out_bfm);
      end

	//instantiate and hook up the monitors for the output interfaces
	//use inspiration from BFM
     for(int i=0; i<3; i++) begin
         case (i)
            0 : begin channel_out_monitor = new(i,
                                                top.output_intf0.rcv,
                                                channel_out_mbox[i],
                                                top.reset_intf.rcv,
                                                "CHANNEL_OUT_MONITOR0",
                                                0);
            end
            1 : begin channel_out_monitor = new(i,
                                                top.output_intf1.rcv,
                                                channel_out_mbox[i],
                                                top.reset_intf.rcv,
                                                "CHANNEL_OUT_MONITOR1",
                                                1);
            end
            2 : begin channel_out_monitor = new(i,
                                                top.output_intf2.rcv,
                                                channel_out_mbox[i],
                                                top.reset_intf.rcv,
                                                "CHANNEL_OUT_MONITOR2",
                                                2);
            end
         endcase
         units.push_back(channel_out_monitor);
      end	
	
      //Scoreboard
      //instantiate the scoreboard									   
      scbd = new("SCOREBOARD",
               10,
               data_in_mbox,
               channel_out_mbox,
               top.input_intf.rcv);
      units.push_back(scbd);			  
   endfunction: new
   
   task testend();
      //LAB: implement the function, which should print the test summary (passed/failed),
      //check to see that the scoreboard mailboxes are empty
      //and also include a watchdog mechanism, which will automatically end the simulation if it hangs
      //(hang means there is no activity in the simulation for a great period of time)
		while (1) begin
         if(scbd.total_packets==number_of_packets) begin
            scbd.check_empty();
            if(scbd.errors) begin
               $display("\n\n\n.............FAILED...............\n\n\n");
               $display("TOTAL NUMBER OF ERRORS: %0d",scbd.errors);
            end
            else
            $display("\n\n\n.............PASSED...............\n\n\n");
            $finish(1);
         end
         else if (counter==watchdog) begin
            scbd.check_empty();
            $display("Error! Test ended due to watchdog.\n");
            $display("Total number of errors: %0d", scbd.errors);
            $finish(1);
         end
         else begin
            @(posedge top.clock); counter++;
         end
      end																		  
   endtask: testend
   task run();
      for(int i=0; i<3; i++)
         //"spread" the value of 'force_read_enable_deasserted' to the output BFMs
         channel_out_bfm[i].force_read_enable_deasserted = force_read_enable_deasserted;

      //this is where the environment resets the DUT
      units[0].run;

      for(int i=1;i<units.size();i++) begin
         fork
            
            automatic int k=i;
            begin
              units[k].run();
            end
         join_none
      end

	  this.testend();

   endtask: run

endclass: svbt_environment