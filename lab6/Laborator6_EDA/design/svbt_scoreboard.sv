class svbt_scoreboard extends svbt_base_unit;

   //LAB: instantiate the mailboxes from the monitors

   //errors counter, when there is a data mismatch this counter is incremented;
   //if it is 0 at the end of test, we consider the test passed
   int errors;
   
   //pointer to the input interface, needed for protocol checks
   virtual input_intf.rcv smp_rcv;

   function new(string name, int id,
                svbt_packet_channel drv2scbd,
                svbt_packet_channel rcv2scbd[$],
                virtual input_intf.rcv smp_rcv );
      //LAB: implement the new() function
   endfunction


   task run();
      forever begin
         check_packets();
      end
   endtask : run

   task check_packets();
      svbt_packet drv_packet, rcv_packet;
      drv_packet=new;
      rcv_packet=new;

      //LAB: if (there are packets in the input mailbox) ...
         //LAB: if (there are packets in the output mailboxes) ...

            $display("[%0t] %s: Starting to compare packet ID: %0d", $time, super.name, rcv_packet.id);

            if(drv2scbd.try_get(drv_packet)==0) begin
               $display("[%0t] %s:	**ERROR** There is something on the output, but nothing on the input!",
                        $time, super.name);
               errors++;
            end
            else begin
               //protocol checks
               check_err(rcv_packet);
               check_payload_size(rcv_packet);
            end

            if(drv_packet.address != rcv_packet.address) begin
               $display("[%0t] %s:  **ERROR** Packet address mismatch: driven addr is %0h received addr is %0h",
                        $time, super.name, drv_packet.address, rcv_packet.address);
               errors++;
            end
            //LAB: implement the checking for the rest of the packet fields
         end
      end
      @(smp_rcv.rcv_cb);

   endtask: check_packets

   function int check_data(svbt_packet drv_packet, svbt_packet rcv_packet);
      //LAB: implement the payload data check
   endfunction: check_data

   task check_err(svbt_packet rcv_packet);
      //LAB: implement the 'err' signal protocol check: if a packet with bad parity is driven
      //the 'err' signal should be asserted; if it is not, increase the errors counter
   endtask: check_err

   task check_payload_size(svbt_packet rcv_packet);
      //LAB: implement the payload size protocol check
   endtask: check_payload_size

endclass : svbt_scoreboard
