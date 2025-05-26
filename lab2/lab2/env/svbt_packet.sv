// LAB: define a scalar type "packet_length"

class svbt_packet;

   // packet unique id
   int id;

   //the 'address' field
   rand bit[1:0] address;
   constraint keep_address { address != 2'b11; }
   //leave room for further constraints
   constraint keep_address_fixed;

   //LAB: define the 'length' field, 6 bits wide
   //LAB: constrain the length to be greater than 0

   //LAB: define the 'data' field, 8 bits wide, as a smart queue
   //LAB: constrain its size to be equal to the length

   //LAB: define the 'parity' field, 8 bits wide, as a smart queue

   //LAB: define a 'delay' field, which will tell the number of cycles between packets
   //LAB: constrain the delay to be inside an interval, 1 to 10 for example

   rand packet_length pkt_length;
   constraint keep_pkt_length;
   constraint packet_length_c {
      (length == 1) -> pkt_length == SMALL;
      //LAB: continue for MEDIUM and LARGE
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
   endfunction : copy

   function display(string prefix);
     //LAB: this function should $display the time, id and packet fields (addr, length, data etc)
   endfunction : display

   function bit[7:0] compute_parity();
      // { , } bit concatenation operator
      compute_parity = {length, address};
      foreach(data[i])
         compute_parity ^= data[i];
   endfunction : compute_parity

endclass : svbt_packet