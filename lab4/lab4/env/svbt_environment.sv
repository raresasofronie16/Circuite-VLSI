class svbt_environment extends svbt_base_unit;

   int number_of_packets;

   //a smart queue of all the units instantiated in the environment;
   //this is very useful for modularization, because you can take out any
   //environment component and the remaining ones will still work
   svbt_base_unit units[$];
   svbt_packet_channel packet_mbox, data_in_mbox, channel_out_mbox[$];

   svbt_data_in_generator data_in_generator;
   svbt_data_in_bfm data_in_bfm;

   svbt_reset_bfm reset_bfm;

   svbt_channel_out_generator channel_out_generator[$];
   svbt_channel_out_bfm channel_out_bfm[$], ch_out_bfm;

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
            //LAB: continue for 1 and 2
         endcase
         //LAB: push the BFMs into the 'units' queue
      end

   endfunction: new

   task run();
      for(int i=0; i<3; i++)
         //LAB: "spread" the value of 'force_read_enable_deasserted' to the output BFMs

      //this is where the environment resets the DUT
      units[0].run;

      for(int i=1;i<units.size();i++) begin
         fork
            //LAB: why was 'automatic' used here?
            automatic int k=i;
            begin
              units[k].run();
            end
         join_none
      end

      //temporary, until a proper test_end() function is defined
      #30000
      $finish(1);

   endtask: run

endclass: svbt_environment