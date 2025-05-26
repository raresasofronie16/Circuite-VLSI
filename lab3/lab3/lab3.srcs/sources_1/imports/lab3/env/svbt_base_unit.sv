
class svbt_base_unit;
  
   string name;
   int id;

   function new (string name, int id);
      //LAB: initialize the class variables with the parameters of new()
     this.name = name;
     this.id = id;
     
   endfunction: new

   function display_name(int id);
     $display("%s",name);
   endfunction: display_name

   //LAB: define a virtual empty task named "run" (all the classes
   //that inherit the base will be able to re-define and use it
  virtual task run();
  endtask
  
  
 
endclass: svbt_base_unit

 
