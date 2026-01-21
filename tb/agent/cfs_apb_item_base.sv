`ifndef CFS_APB_ITEM_BASE_SV
 `define CFS_APB_ITEM_BASE_SV


//shall include driver and monitor driving items
class cfs_apb_item_base extends uvm_sequence_item;
  
  `uvm_object_utils(cfs_apb_item_base)
  
  function new(string name="");
    super.new(name);
  endfunction
  
endclass


`endif
