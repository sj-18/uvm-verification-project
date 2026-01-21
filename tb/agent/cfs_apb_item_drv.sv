`ifndef CFS_APB_ITEM_DRV_SV
 `define CFS_APB_ITEM_DRV_SV

class cfs_apb_item_drv extends cfs_apb_item_base;
  
  rand cfs_apb_dir dir;
  rand cfs_apb_data data;
  rand cfs_apb_addr addr;
  rand int unsigned pre_drive_delay;
  rand int unsigned post_drive_delay;
  
  constraint pre_drive_delay_default{
    soft pre_drive_delay <=5;
  }
  
  constraint post_drive_delay_default{
    soft post_drive_delay <=5;
  }
  
  `uvm_object_utils(cfs_apb_item_drv)
  
  function new(string name="");
    super.new(name);
  endfunction
  
  virtual function string convert2string();
    string result = $sformatf("dir: %0s, addr: %0x", dir.name(), addr);
    
    // Data only makes sense when we are ding an APB write
    if(dir == CFS_APB_WRITE) begin
      result = $sformatf("%0s, data: %0x", result, data);
    end
    
    result = $sformatf("%0s, pre_drive_delay: %0d, post_drive_delay: %0d, ", result, pre_drive_delay, post_drive_delay);
    
    return result;
  endfunction
  
  
endclass


`endif
