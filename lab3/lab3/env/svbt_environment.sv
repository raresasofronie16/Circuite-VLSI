class svbt_environment extends svbt_base_unit;

   int number_of_packets;

   function new (int unsigned number_of_packets,
                  string name,
                  int id);
      //this must always be the first line of the "new()" of a child class
      super.new(name,id);
      //LAB: initialize the class variables
   endfunction: new

   task run();
     //LAB: generate a number of packets equal to "number_of_packets"
   endtask: run

endclass: svbt_environment