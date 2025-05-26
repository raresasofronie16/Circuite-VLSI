`ifndef SVBT_CHANNEL_OUT_GENERATOR
`define SVBT_CHANNEL_OUT_GENERATOR

class svbt_channel_out_generator extends svbt_base_unit;

   int id;
   rand int delay;
   constraint keep_delay_0 { delay==0; }
   constraint keep_delay_random;

   function new(string name,int id);
     super.new(name,id);
     this.id=id;
   endfunction: new

   function int generate_delay();
     void'(this.randomize(delay));
     return delay;
   endfunction: generate_delay

endclass: svbt_channel_out_generator

`endif