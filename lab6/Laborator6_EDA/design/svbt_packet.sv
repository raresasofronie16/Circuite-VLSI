// LAB: define a scalar type "packet_length"
typedef enum {SMALL, MEDIUM, LARGE } packet_length;

class svbt_packet;

   // packet unique id
   int id;

   //the 'address' field
   rand bit[1:0] address;
   constraint keep_address { address != 2'b11; }
   //leave room for further constraints
   constraint keep_address_fixed;

   //LAB: define the 'length' field, 6 bits wide
   rand bit [5:0] length;
   //LAB: constrain the length to be greater than 0
   constraint positive_length { length > 0; }
   constraint keep_length_fixed;

   //LAB: define the 'data' field, 8 bits wide, as a smart queue
   rand bit [7:0] data [$];
   //LAB: constrain its size to be equal to the length
   constraint solve_order { solve length before data; }
   constraint data_size {data.size() == length; }

   //LAB: define the 'parity' field, 8 bits wide, as a smart queue
   bit [7:0] parity;

   //LAB: define a 'delay' field, which will tell the number of cycles between packets
  	rand int delay;
   //LAB: constrain the delay to be inside an interval, 1 to 10 for example
   constraint delay_value { soft delay inside {[1:10]}; }
   constraint keep_delay_value;

   rand packet_length pkt_length;
   constraint keep_pkt_length;
   constraint packet_length_c {
      (length == 1) -> pkt_length == SMALL;
      //LAB: continue for MEDIUM and LARGE
      (length > 1 && length < 32) -> pkt_length == MEDIUM;
      (length >=32 && length < 64) -> pkt_length == LARGE;
   }


   function void post_randomize();
      //since all the data is random, parity has to be calculated at post_randomize(),
      //based on what was generated at randomize()
      parity = compute_parity();
   endfunction : post_randomize

   function svbt_packet copy();
      copy = new();
      copy.id = this.id;
      copy.address = this.address;
      //LAB: continue for the rest of the fields
      copy.parity = this.parity;
      copy.delay = this.delay;
      copy.pkt_length = this.pkt_length;
      foreach(this.data[i]) copy.data[i] = this.data[i];
          
   endfunction : copy

   function display(string prefix);
     //LAB: this function should $display the time, id and packet fields (addr, length, data etc)
         string str, ddata = "";
        foreach(this.data[i]) begin
         str.hextoa(data[i]);
         ddata = { ddata, " h'", str };
      end
      $display("[%0t] %s : packet ID: %0d address is h'%h, data length is %0d, payload is %s,parity is %0h, delay is %0d", $time, prefix, id, address, length, ddata,parity, delay);
     
   endfunction : display

   function bit[7:0] compute_parity();
      // { , } bit concatenation operator
      compute_parity = {length, address};
      foreach(data[i])
         compute_parity ^= data[i];
   endfunction : compute_parity

endclass : svbt_packet