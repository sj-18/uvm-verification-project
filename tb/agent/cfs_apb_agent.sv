`ifndef CFS_APB_AGENT_SV
 `define CFS_APB_AGENT_SV

class cfs_apb_agent extends uvm_agent;
  
  //Create an instance of the agent config
  cfs_apb_agent_config agent_config;
  //Virtual interface instance to store the config_db get return value
  cfs_apb_vif vif;
  
  //Handles for driver, sequencer and monitor
  cfs_apb_sequencer sequencer;
  cfs_apb_driver driver;
  cfs_apb_monitor monitor;
  
  `uvm_component_utils(cfs_apb_agent)
  
  function new(string name ="", uvm_component parent);
    super.new(name, parent);    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent_config = cfs_apb_agent_config::type_id::create("agent_config", this);
    
    monitor = cfs_apb_monitor::type_id::create("monitor", this);
    
    //If active agent
    if(agent_config.get_active_passive() == UVM_ACTIVE) begin
      sequencer = cfs_apb_sequencer::type_id::create("sequencer", this);
      driver = cfs_apb_driver::type_id::create("driver", this);
    end
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    //Get the virtual interface from the tb top
    if(!uvm_config_db#(cfs_apb_vif)::get(this, "", "vif", vif)) begin
      `uvm_fatal("APB_NO_VIF", "Could not get the virtual interface from the config database")
    end
    //Set the agent config using the setter
    else begin
      agent_config.set_vif(vif);
    end
    
    //If active agent
    if(agent_config.get_active_passive() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      //Driver and monitor need the vif and so on
      driver.agent_config = agent_config;
      monitor.agent_config = agent_config;
    end
    
  endfunction
  
endclass


`endif
