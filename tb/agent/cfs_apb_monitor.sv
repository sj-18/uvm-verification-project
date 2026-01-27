`ifndef CFS_APB_MONITOR_SV
 `define CFS_APB_MONITOR_SV

class cfs_apb_monitor extends uvm_monitor;
  
  //Pointer to agent configuration
  cfs_apb_agent_config agent_config;
  
  //uvm_analysis_port to broadcast the transaction from monitor
  uvm_analysis_port#(cfs_apb_item_mon) output_port;
  
  `uvm_component_utils(cfs_apb_monitor)
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    
    output_port = new("output_port", this);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    collect_transactions();
  endtask
  
  protected virtual task collect_transactions();
    forever begin
      collect_transaction();
    end    
  endtask
  
  protected virtual task collect_transaction();
    cfs_apb_vif vif = agent_config.get_vif();
    cfs_apb_item_mon item = cfs_apb_item_mon::type_id::create("item");
    
    //After entering collect_transaction from prev transfer
    while(vif.psel !== 1) begin
      @(posedge vif.pclk);
      item.prev_item_delay++;
    end
    
    //Once we get psel -> addr, dir and pwdata(if applicable) will be at their correct values
    item.addr = vif.paddr;
   
    item.dir = cfs_apb_dir'(vif.pwrite);
    
    if(item.dir == CFS_APB_WRITE) begin
      item.data = vif.pwdata;
    end
    
    //Initialize the transfer length as 1 as one clock cycle has passed above
    item.length = 1;
    
    //One cycle will pass where penable will become 1
    @(posedge vif.pclk);
    item.length++;
    
    //Wait till we get a pready from the slave and keep increasing transfer length
    while(vif.pready !== 1) begin
      @(posedge vif.pclk);
      item.length++;
      
      if(agent_config.get_has_checks()) begin
        if(item.length >= agent_config.get_stuck_threshold()) begin
          `uvm_error("APB_PROTOCOL_ERROR", $sformatf("Hit the stuck threshold : %0d clock cycles for the APB transfer", item.length))
        end   
      end
    end
    
    //Once pready is received, prdata and pslverr will hold valid values
    item.response = cfs_apb_response'(vif.pslverr);
    if(item.dir == CFS_APB_READ) begin
      item.data = vif.prdata;
    end
    
    //Pass item to output port
    output_port.write(item);
    
    `uvm_info("DEBUG", $sformatf("Monitored item : %0s", item.convert2string()), UVM_NONE)
    
    @(posedge vif.pclk);
    
  endtask
  
endclass

`endif
