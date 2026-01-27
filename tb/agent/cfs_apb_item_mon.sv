`ifndef CFS_APB_ITEM_MON_SV
 `define CFS_APB_ITEM_MON_SV

class cfs_apb_item_mon extends cfs_apb_item_base;
  
  cfs_apb_response response;
  
  //Nuber of clock cycles of the APB transfer
  int unsigned length;
  
  //Number of clock cycles from the previous APB transfer
  int unsigned prev_item_delay;
  
  `uvm_object_utils(cfs_apb_item_mon)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual function string convert2string();
    string result = super.convert2string();
    
    if(dir == CFS_APB_WRITE) begin
      result = $sformatf("%0s, write data: %0x", result, data);
    end 
    else if (dir == CFS_APB_READ) begin
      result = $sformatf("%0s, read data: %0x", result, data);
    end
    
    result = $sformatf("%0s, prev_item_delay: %0d, length: %0d, response :%0s ", result, prev_item_delay, length, response.name());
    
    return result;
  endfunction
  
  
endclass


`endif
