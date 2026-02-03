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
  
  //Switch to enable apb protocol checks
  local bit has_checks;  
  
  //Switch to enable coverage
  local bit has_coverage; 
  
  //The max number of clock cycls we wait before declaring that the
  //APB transfer is stuck and triggering an error
  local int unsigned stuck_threshold;
  
  function new(string name ="", uvm_component parent);
    super.new(name, parent);
    
    //Active agent by default
    active_passive = UVM_ACTIVE;
    
    //Enable the checks by default
    has_checks = 1;
    
    //default value large enough
    stuck_threshold = 1000;
    
    //deafult enable coverage
    has_coverage = 1;
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
      
      //When vif is set, set the has_checks bit as well
      set_has_checks(get_has_checks());
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
  
  //has_checks getter
  virtual function bit get_has_checks();
    return has_checks;
  endfunction
 
  //has_checks setter
  virtual function void set_has_checks(bit value);
    has_checks = value;
    
    //synchronize the has_checks bit between the interface and the agent_config
    if(vif != null) begin
      vif.has_checks = has_checks;
    end
  endfunction
 
  //stuck_threshold getter
  virtual function int unsigned get_stuck_threshold();
    return stuck_threshold;
  endfunction
  
 //stuck_threshold setter
  virtual function void set_stuck_threshold(int unsigned value);
    if(stuck_threshold > 2) begin
    stuck_threshold = value;
    end else begin
      `uvm_fatal("ALGO ISSUE", $sformatf("Tried to set stuck_threshold value less than 2 while minimum APB transfer length is 2"))
    end
  endfunction  
  
  //has_coverage getter
  virtual function bit get_has_coverage();
    return has_coverage;
  endfunction
 
  //has_coverage setter
  virtual function void set_has_coverage(bit value);
    has_coverage = value;
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
  
  virtual task run_phase(uvm_phase phase);
    //Ensure that virtual interface does not change has_checks
    
    forever begin
      @(vif.has_checks);
 
      //Throw an error if interface is changing has_checks
      if(vif.has_checks != get_has_checks()) begin
        `uvm_error("ALGO ISSUE", $sformatf("The has_checks bit cannot be changed from the interface, use %0s.set_has_checks() method", get_full_name()))
      end
    
    end
    
  endtask
  
  
endclass


`endif
