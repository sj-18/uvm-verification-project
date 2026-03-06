///////////////////////////////////////////////////////////////////////////////
// Description: APB Random sequence. This sends the simple sequence num_items times.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_APB_SEQUENCE_RANDOM_SV
 `define CFS_APB_SEQUENCE_RANDOM_SV

class cfs_apb_sequence_random extends cfs_apb_sequence_base;
  
  rand int unsigned num_items;
  
  //Constraint on number of times we call the simple sequence
  constraint num_items_default{
    soft num_items inside {[1:10]};  
  }
  
  `uvm_object_utils(cfs_apb_sequence_random)
  
  function new(string name = "");
    super.new(name);
  endfunction
  
  virtual task body();
    for(int i=0; i<num_items; i++) begin
      cfs_apb_sequence_simple seq;
      
      //uvm_do can take input argument as sequence item or a sequence itself as well
      `uvm_do(seq)
    end
    
  endtask
  
endclass


`endif
