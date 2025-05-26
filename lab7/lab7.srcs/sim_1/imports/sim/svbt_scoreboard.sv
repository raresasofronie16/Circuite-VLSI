class svbt_scoreboard extends svbt_base_unit;

   //instantiate the mailboxes from the monitors
	svbt_packet_channel drv2scbd, rcv2scbd [$];
   //errors counter, when there is a data mismatch this counter is incremented;
   //if it is 0 at the end of test, we consider the test passed
   int total_packets, errors;
   
   //pointer to the input interface, needed for protocol checks
   virtual input_intf.rcv smp_rcv;

   function new(string name, int id,
                svbt_packet_channel drv2scbd,
                svbt_packet_channel rcv2scbd[$],
                virtual input_intf.rcv smp_rcv );
      //implement the new() function
	  super.new(name, id);
      this.drv2scbd = drv2scbd;
      this.rcv2scbd = rcv2scbd;
      this.smp_rcv=smp_rcv;
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

		if(drv2scbd.try_peek(drv_packet)) begin
         if(rcv2scbd[drv_packet.address].try_get(rcv_packet)) begin

            $display("[%0t] %s: Starting to compare packet ID: %0d", $time, super.name, rcv_packet.id);

            if(drv2scbd.try_get(drv_packet)==0) begin
               $display("[%0t]  %s: **ERROR** There is something on the output, but nothing on the input!",
                        $time, super.name);
               errors++;
            end
            else begin
               check_err(rcv_packet);
               check_payload_size(rcv_packet);
            end

            if(drv_packet.address != rcv_packet.address) begin
               $display("[%0t] %s:  **ERROR** Packet address mismatch: driven addr is %0h received addr is %0h",
                        $time, super.name, drv_packet.address, rcv_packet.address);
               errors++;
            end

            if(drv_packet.length != rcv_packet.length) begin
               $display("[%0t] %s:  **ERROR** Packet length mismatch: driven length is %0d received length is %0d",
                        $time,super.name,drv_packet.length, rcv_packet.length);
               errors++;
            end

            if (check_data(drv_packet, rcv_packet)) begin
               errors++;
            end

            if(drv_packet.parity != rcv_packet.parity) begin
               $display("[%0t] %s:  **ERROR** Packet parity mismatch: driven parity is h'%0h received parity is h'%0h",
                        $time, super.name, drv_packet.parity, rcv_packet.parity);
               errors++;
            end

            total_packets++;
         end
      end
      @(smp_rcv.rcv_cb);

   endtask: check_packets

   function int check_data(svbt_packet drv_packet, svbt_packet rcv_packet);
      foreach (drv_packet.data[i])
         if(drv_packet.data[i] != rcv_packet.data[i]) begin
            $display("[%0t] %s:  **ERROR** Packet data at index %0d mismatch: driven data is h'%0h received data is h'%0h",
                     $time, super.name, i, drv_packet.data[i], rcv_packet.data[i]);
            return (1);
         end
      return (0);
   endfunction: check_data

   task check_err(svbt_packet rcv_packet);
      bit [7:0] correct_parity;
      correct_parity = rcv_packet.compute_parity();
      if((correct_parity!=rcv_packet.parity)&&(smp_rcv.rcv_cb.err==1'b0)) begin
         $display("[%0t] %s:     **ERROR** The err signal is not asserted even though the parity is bad.",$time, super.name);
         errors++;
      end
   endtask: check_err

   task check_payload_size(svbt_packet rcv_packet);
      if(rcv_packet.data.size() < 1) begin
         $display("[%0t] %s:     **ERROR** The length is not big enough.",$time, super.name);
         errors++;
      end

      if(rcv_packet.data.size() > 63) begin
         $display("[%0t] %s:     **ERROR** The length is too big.",$time, super.name);
         errors++;
      end

      if(rcv_packet.data.size() !=  rcv_packet.length) begin
         $display("[%0t] %s:     **ERROR** The length and the payload size are not the same.",$time, super.name);
         errors++;
      end
   endtask: check_payload_size

   task check_empty();
      if(drv2scbd.num()) begin
         $display("[%0t] %s:     **ERROR** The input mailbox is not empty, but the test has ended.",$time, super.name);
         errors++;
      end
      foreach(rcv2scbd[i])
         if(rcv2scbd[i].num()) begin
            $display("[%0t] %s:     **ERROR** The input mailbox is not empty, but the test has ended.",$time, super.name);
            errors++;
         end
   endtask: check_empty

endclass : svbt_scoreboard
