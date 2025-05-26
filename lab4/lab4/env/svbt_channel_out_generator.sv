class svbt_channel_out_generator extends svbt_base_unit;

   int id;
   rand int delay;
   constraint keep_delay_0 { delay==0; }
   constraint keep_delay_random;

   function new(string name,int id);
     super.new(name,id);
     this.id=id;
   endfunction: new

   //LAB: implement a function 'generate_delay()' that randomizes and returns the 'delay'

endclass: svbt_channel_out_generator