`ifndef CFS_APB_ITEM_BASE_SV
 `define CFS_APB_ITEM_BASE_SV


//shall include driver and monitor driving items
class cfs_apb_item_base extends uvm_sequence_item;
    
  rand cfs_apb_dir dir;
  rand cfs_apb_data data;
  rand cfs_apb_addr addr;
  
  `uvm_object_utils(cfs_apb_item_base)
  
  function new(string name="");
    super.new(name);
  endfunction
  
    virtual function string convert2string();
    string result = $sformatf("dir: %0s, addr: %0x", dir.name(), addr);
    
    return result;
  endfunction
  
endclass


`endif
