typedef enum { SMALL, MEDIUM, LARGE } packet_length;

class svbt_packet;

   // packet unique id
   int id;

   rand bit[1:0] address;
   constraint keep_address { address != 2'b11; }
   constraint keep_address_fixed;

   rand bit[5:0] length;
   constraint keep_length { length > 0; }
   constraint keep_length_fixed;

   rand bit[7:0] data [$];
   constraint order { solve length before data; }
   constraint keep_data_size { data.size()==length;  }

   bit[7:0] parity;

   //LAB: add a rand bit 'flag_mismatched_parity' to control the good/bad parity generation
   //LAB: add constraints for this field		
   rand bit flag_mismatched_parity;
   constraint keep_flag_mismatched_parity_0 {flag_mismatched_parity == 0;}
   constraint keep_flag_mismatched_parity_1 {flag_mismatched_parity == 1;}
   

   																				   
   rand int delay;
   constraint keep_delay { delay inside {[1:10]}; }

   rand packet_length pkt_length;
   constraint keep_pkt_length;
   constraint packet_length_c {
   (length == 1) -> pkt_length == SMALL;
   (length inside {[2:5]}) -> pkt_length == MEDIUM;
   (length > 5) -> pkt_length == LARGE;
   }


   function void post_randomize();
      //LAB: take 'flag_mismatched_parity' when computing the parity
      //parity = compute_parity();
      parity = compute_parity() + flag_mismatched_parity;
      
   endfunction : post_randomize

   function svbt_packet copy();
      copy = new();
      copy.id = this.id;
      copy.address = this.address;
      copy.length = this.length;
      foreach (this.data[i])
         copy.data.push_back(this.data[i]);
      copy.parity = this.parity;
      copy.delay = this.delay;
      copy.pkt_length = this.pkt_length;
   endfunction : copy

   function display(input string prefix);
      string str, ddata = "";
      foreach(this.data[i]) begin
         str.hextoa(data[i]);
         ddata = { ddata, " h'", str };
      end
      $display("[%0t] %s : packet ID: %0d address is h'%h, data length is %0d, payload is %s,\
      parity is %0h, delay is %0d", $time, prefix, id, address, length, ddata,
      parity, delay);
   endfunction : display

   function bit[7:0] compute_parity();
      // { , } bit concatenation operator
      compute_parity = {length, address};
      foreach(data[i])
         compute_parity ^= data[i];
   endfunction : compute_parity

endclass : svbt_packet

typedef mailbox #(svbt_packet) svbt_packet_channel;