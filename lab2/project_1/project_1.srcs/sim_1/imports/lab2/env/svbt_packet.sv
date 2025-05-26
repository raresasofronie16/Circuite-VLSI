// LAB: define a scalar type "packet_length"
typedef enum bit [1:0] {SMALL, MEDIUM , LARGE} packet_length;


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
   
   //LAB: constrain the length to be greater than 0, <64
    constraint keep_length { length inside {[1:63]}; }  


   //LAB: define the 'data' field, 8 bits wide, as a smart queue
    rand bit [7:0] data[];
   
   //LAB: constrain its size to be equal to the length
    constraint keep_data_size { data.size() == length; }

   //LAB: define the 'parity' field, 8 bits wide, as a smart queue
    bit [7:0] parity[];

   //LAB: define a 'delay' field, which will tell the number of cycles between packets
    rand int delay;
    
   
   //LAB: constrain the delay to be inside an interval, 1 to 10 for example
    constraint keep_delay_size { delay inside {[1:10]}; }

   rand packet_length pkt_length;
   constraint keep_pkt_length;
   constraint packet_length_c {
      (length == 1) -> pkt_length == SMALL;
      //LAB: continue for MEDIUM and LARGE
      (length inside {[2:6]} ) -> pkt_length == MEDIUM;
      (length > 6) -> pkt_length == LARGE;
           
   }


//   function void post_randomize();
//      //since all the data is random, parity has to be calculated at post_randomize(),
//      //based on what was generated at randomize()
//      parity = compute_parity();
//   endfunction : post_randomize

   function void post_randomize();
      //since all the data is random, parity has to be calculated at post_randomize(),
      //based on what was generated at randomize()
        parity = new[data.size()];
        foreach(data[i])
            parity[i] = compute_parity(data[i]);

   endfunction : post_randomize



   function svbt_packet copy();
      copy = new();
      copy.id = this.id;
      copy.address = this.address;
      //LAB: continue for the rest of the fields
      copy.length = this.length;
      copy.delay = this.delay;
      copy.pkt_length = this.pkt_length;
      copy.data = this.data;
      copy.parity = this.parity;
      
   endfunction : copy


   function display(string prefix);
     //LAB: this function should $display the time, id and packet fields (addr, length, data etc)
     $display("%s Time: %t, id: %d, addr: %b, length: %d, data: %p, delay: %d",
     prefix, $time, id, address, length, data, delay);
     
   endfunction : display

//   function bit[7:0] compute_parity();
//      // { , } bit concatenation operator
//      compute_parity = {length, address};
//      foreach(data[i])
//         compute_parity ^= data[i];
//   endfunction : compute_parity

    function bit[7:0] compute_parity(bit[7:0] input_data);
      // { , } bit concatenation operator
        bit[7:0] parity_result = {length, address};
        // rez e 0 daca nr de 1 este par & 1 daca nr e impar
        parity_result = parity_result ^ input_data;
        return parity_result;
      
    endfunction : compute_parity


endclass : svbt_packet