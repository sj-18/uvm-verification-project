///////////////////////////////////////////////////////////////////////////////
// Description: The APB agent class.
//              1. Instances of the agent components - sequencer
//              driver, monitor and coverage are created inside this.
//              2. agent_config is connected. vif is fetched from config_db.
//              3. ports connected in connect_phase
//              4. reset handling logic
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_APB_AGENT_SV
 `define CFS_APB_AGENT_SV

class cfs_apb_agent extends uvm_agent implements cfs_apb_reset_handler;
  
  //Create an instance of the agent config which will be shared by all members.
  cfs_apb_agent_config agent_config;
  //Virtual interface instance to store the config_db get return value
  cfs_apb_vif vif;
  
  //Handles for driver, sequencer, monitor, coverage
  cfs_apb_sequencer sequencer;
  cfs_apb_driver driver;
  cfs_apb_monitor monitor;
  cfs_apb_coverage coverage;
  
  `uvm_component_utils(cfs_apb_agent)
  
  function new(string name ="", uvm_component parent);
    super.new(name, parent);    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent_config = cfs_apb_agent_config::type_id::create("agent_config", this);
    
    monitor = cfs_apb_monitor::type_id::create("monitor", this);
    
    //If coverage enabled
    if(agent_config.get_has_coverage()) begin
      coverage = cfs_apb_coverage::type_id::create("coverage", this);
    end
    
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
      //seq_item_export amd seq_item_port are in-built
      driver.seq_item_port.connect(sequencer.seq_item_export);
      //Driver and monitor need the vif and so on
      driver.agent_config = agent_config;
      monitor.agent_config = agent_config;
    end
    
    //If coverage enabled connect the analysis port from monitor to coverage
    if(agent_config.get_has_coverage()) begin
      //The output_port is instantiated as part of monitor new() function call when
      //we create monitor instance in the build_phase above
      monitor.output_port.connect(coverage.port_item);
      coverage.agent_config = agent_config;
    end
    
  endfunction
  
  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    //Loop through all the children of the agent class and call the reset_handler wherever necessary
    
    //Queue that will hold all children objects
    uvm_component children[$];
    
    //In-built UVM method to get the components instantiated under the agent
    get_children(children);
    
    foreach(children[i]) begin
      cfs_apb_reset_handler reset_handler;
      
      if($cast(reset_handler, children[i])) begin
        reset_handler.handle_reset(phase);
      end
    end
    
  endfunction
  
  //Loop that waits till reset start 
  virtual task wait_reset_start();
    agent_config.wait_reset_start();
  endtask
  
  //Loop that waits till reset end
  virtual task wait_reset_end();
    agent_config.wait_reset_end();
  endtask
    
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      wait_reset_start();
      //Handle reset when it starts by calling handle_reset() methods of the children
      handle_reset(phase);
      wait_reset_end();
    end
  endtask
  
endclass


`endif
