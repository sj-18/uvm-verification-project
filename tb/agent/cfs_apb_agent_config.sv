//Agent configuration kept separate so that can be passed as an object to wherever it is needed instead of passing individual fields

`ifndef CFS_APB_AGENT_CONFIG_SV
 `define CFS_APB_AGENT_CONFIG_SV

//agent_config made as component to enable component features such as phases and overriding
class cfs_apb_agent_config extends uvm_component;
  
  `uvm_component_utils(cfs_apb_agent_config)
  
  //Virtual interface - set as local and access allowed only via setter and getter functions which allow us do some actions when field is set or get. Checks in setter and getter can help save debugging time.
  local cfs_apb_vif vif;
  
  //Active/Passive agent flag with pre-defined UVM enum
  local uvm_active_passive_enum active_passive;
  
  function new(string name ="", uvm_component parent);
    super.new(name, parent);
    
    //Active agent by default
    active_passive = UVM_ACTIVE;
  endfunction
  
  //vif Getter
  virtual function cfs_apb_vif get_vif();
    return vif;
  endfunction
    
  //vif Setter
  virtual function void set_vif(cfs_apb_vif value);
    //Check to ensure virtual interface is only set once
    if(vif == null) begin
      //Set the virtual interface
      vif = value;
    end
    else begin
      `uvm_fatal("ALGO ISSUE", "Trying to set the APB virtual interface more than once")
    end
  endfunction
  
  //active/passive getter
  virtual function uvm_active_passive_enum get_active_passive();
    return active_passive;
  endfunction
 
  //active/passive setter
  virtual function void set_active_passive(uvm_active_passive_enum value);
    active_passive = value;
  endfunction
 
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    
    //Check to ensure virtual interface is available before calling run_phase()
    if(get_vif() == null) begin
      `uvm_fatal("ALGO ISSUE","The APB virtual interface is not configured at \"Start of Simulation\" phase")
    end
    else begin
      `uvm_info("APB_CONFIG","The APB virtual interface is configured at \"Start of Simulation\" phase", UVM_LOW)
    end
    
  endfunction
  
  
endclass


`endif
