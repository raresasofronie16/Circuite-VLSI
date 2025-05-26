class svbt_environment extends svbt_base_unit;

   int number_of_packets;

   function new (int unsigned number_of_packets,
                  string name,
                  int id);
      //this must always be the first line of the "new()" of a child class
      super.new(name,id);
      //LAB: initialize the class variables
     this.number_of_packets = number_of_packets;
     
     
   endfunction: new

  
   task run();
     //LAB: generate a number of packets equal to "number_of_packets"
     for(int i=0;i < number_of_packets; i=i+1)
       begin
         $display("generare de pachet : %d", i+1);
         
       end
     
   endtask: run

endclass: svbt_environment