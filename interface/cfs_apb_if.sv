`ifndef CFS_APB_IF_SV
 `define CFS_APB_IF_SV

`ifndef CFS_APB_MAX_DATA_WIDTH
 `define CFS_APB_MAX_DATA_WIDTH 32
`endif

`ifndef CFS_APB_MAX_ADDR_WIDTH
 `define CFS_APB_MAX_ADDR_WIDTH 16
`endif

interface cfs_apb_if(input pclk);
  
  logic preset_n;
  
  logic[`CFS_APB_MAX_ADDR_WIDTH-1:0] paddr;
  
  logic pwrite;
  
  logic psel;
  
  logic penable;
  
  logic pready;
  
  logic[`CFS_APB_MAX_DATA_WIDTH-1:0] pwdata;
  
  logic[`CFS_APB_MAX_DATA_WIDTH-1:0] prdata;
  
  logic pslverr;
  
  //has_checks from cfs_apb_agent_config cannot be accessed directly here in the interface. We have logic inside the setter and getter of the has_checks to ensure the has_checks here and in the config are synchronized all the time
  bit has_checks;
  
  //checks enabled by default
  initial begin
    has_checks = 1;
  end
  
  //Setup phase can occur when psel is 0 and then 1 OR
  //It can occur when there are back to back transfers so psel stays 1 and pready was 1 in the past cycle
  sequence setup_phase_s;
    (psel == 1) && ($past(psel) == 0 || (($past(psel) == 1) && ($past(pready) ==1)));
  endsequence
  
  //Access phase when psel and penable are 1
  sequence access_phase_s;
    (psel == 1) && (penable == 1);
  endsequence
  
  
  
  //Check if penable is 0 in setup phase
  property penable_at_setup_phase_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //overlapping operator as we check penable 0 in same cycle
    setup_phase_s |-> penable == 0;
  endproperty
  
  PENABLE_AT_SETUP_PHASE_A : assert property(penable_at_setup_phase_p) else
    $error("PENABLE is not 0 in \"Setup Phase\" ");
    
    
    
    
  //Check if penable becomes 1 after entering access phase
  property penable_entering_access_phase_p;
  	@(posedge pclk) disable iff(!preset_n || !has_checks)
    //one cycle after setup_phase so non-overlapping operator |=> 
    setup_phase_s |=> penable == 1;
  endproperty

  PENABLE_ENTERING_ACCESS_PHASE_A : assert property(penable_entering_access_phase_p) else
  	$error("PENABLE is not 1 when entering \"Access Phase\" ");
      
    
    
    
  //Check if penable deasserted (or becomes 0) on exiting access phase
  property penable_exiting_access_phase_p;
  	@(posedge pclk) disable iff(!preset_n || !has_checks)
    //inside access phase and pready becomes 1 then we will exit access phase in the next cycle(|=>) so check penable then
    (access_phase_s and pready == 1) |=> penable == 0;
  endproperty

  PENABLE_EXITING_ACCESS_PHASE_A : assert property(penable_exiting_access_phase_p) else
	$error("PENABLE is not 0 when exiting \"Access Phase\" ");
  
  
  //Check that signals stay stable during the transfer when they should  
  property pwrite_stable_at_access_phase_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //$stable means it will check if signal value in the prev cycle and that in this cycle is the same. So it will check from the setup phase start.
    access_phase_s |-> $stable(pwrite);
  endproperty
    
  PWRITE_STABLE_AT_ACCESS_PHASE_A : assert property(pwrite_stable_at_access_phase_p) else
  $error("PWRITE is not stable in the \"Access Phase\" ");
  
    
    
  property paddr_stable_at_access_phase_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //$stable means it will check if signal value in the prev cycle and that in this cycle is the same. So it will check from the setup phase start.
    access_phase_s |-> $stable(paddr);
  endproperty
    
  PADDR_STABLE_AT_ACCESS_PHASE_A : assert property(paddr_stable_at_access_phase_p) else
  $error("PADDR is not stable in the \"Access Phase\" ");  
    
    
  property pwdata_stable_at_access_phase_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //$stable means it will check if signal value in the prev cycle and that in this cycle is the same. So it will check from the setup phase start.
    access_phase_s and (pwrite==1) |-> $stable(pwdata);
  endproperty
    
  PWDATA_STABLE_AT_ACCESS_PHASE_A : assert property(pwdata_stable_at_access_phase_p) else
      $error("PWDATA is not stable in the \"Access Phase\" during write");    
    
    
      
      
  //Assertions to check that signals do not have unknown values when not expected
  property unknown_value_psel_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //psel can never have an unknown value
    $isunknown(psel) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PSEL_A : assert property(unknown_value_psel_p) else
    $error("APB signal PSEL has an unknown value");
    
    
  property unknown_value_penable_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //penable cannot have an unknown value when APB transfer happening
    (psel == 1) |-> $isunknown(penable) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PNABLE_A : assert property(unknown_value_penable_p) else
    $error("APB signal PENABLE has an unexpected unknown value");
    
    
  property unknown_value_pwrite_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //pwrite cannot have an unknown value when APB transfer happening
    (psel == 1) |-> $isunknown(pwrite) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PWRITE_A : assert property(unknown_value_pwrite_p) else
    $error("APB signal PWRITE has an unexpected unknown value");
    
    
  property unknown_value_paddr_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //paddr cannot have an unknown value when APB transfer happening
    (psel == 1) |-> $isunknown(paddr) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PADDR_A : assert property(unknown_value_paddr_p) else
    $error("APB signal PADDR has an unexpected unknown value");
    
    
  property unknown_value_pwdata_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //pwdata cannot have an unknown value when APB write transfer happening
    (psel == 1 && pwrite == 1) |-> $isunknown(pwdata) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PWDATA_A : assert property(unknown_value_pwdata_p) else
    $error("APB signal PWDATA has an unexpected unknown value");
    
    
  property unknown_value_prdata_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //prdata cannot have an unknown value when APB read transfer happening without error from slave
    (psel == 1 && pwrite == 0 && pslverr == 0 && pready==1) |-> $isunknown(prdata) == 0;   
  endproperty
      
  UNKNOWN_VALUE_PRDATA_A : assert property(unknown_value_prdata_p) else
    $error("APB signal PRDATA has an unexpected unknown value");
    
    
  property unknown_value_pready_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //pready cannot have an unknown value when APB transfer happening
    (psel == 1) |-> $isunknown(pready) == 0;   
  endproperty
      
    UNKNOWN_VALUE_PREADY_A : assert property(unknown_value_pready_p) else
      $error("APB signal PREADY has an unexpected unknown value");
   
  property unknown_value_pslverr_p;
    @(posedge pclk) disable iff(!preset_n || !has_checks)
    //pslverr cannot have an unknown value when APB transfer happening and pready==1
    (psel == 1 && pready == 1) |-> $isunknown(pslverr) == 0;   
  endproperty
      
    UNKNOWN_VALUE_PSLVERR_A : assert property(unknown_value_pslverr_p) else
      $error("APB signal PSLVERR has an unexpected unknown value");    
      
endinterface



`endif
