///////////////////////////////////////////////////////////////////////////////
// Description: The APB agent sequencer class.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_APB_SEQUENCER_SV
 `define CFS_APB_SEQUENCER_SV

//.REQ is the request sent from sequence to driver. (.RSP is an optional response back that is not included here)
class cfs_apb_sequencer extends uvm_sequencer#(.REQ(cfs_apb_item_drv)) implements cfs_apb_reset_handler;
  
  `uvm_component_utils(cfs_apb_sequencer)
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);    
  endfunction
  
  //Function to handle the reset, stop and restart the sequencer
  virtual function void handle_reset(uvm_phase phase);
    int objections_count;
    
    //Stops all current sequences(and child sequences) bringing it to an ideal state
    stop_sequences();
    
    //Get raised objections count
    objections_count = uvm_test_done.get_objection_count(this);
    
    //Drop all objections
    if(objections_count > 0) begin
      uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
    end
    
    start_phase_sequence(phase);
  endfunction
  
endclass


`endif
