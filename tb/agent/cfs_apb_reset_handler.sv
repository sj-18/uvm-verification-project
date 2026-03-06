///////////////////////////////////////////////////////////////////////////////
// Description: The APB reset handler interface class.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_APB_RESET_HANDLER_SV
 `define CFS_APB_RESET_HANDLER_SV

//Allows multiple inheritance for apb agent classes which will all implement the handle_reset method as per their needs
//Whichever class implements this, needs to have implementations of the methods declared as "pure virtual" here
interface class cfs_apb_reset_handler;
  
  //Function to handle the reset
  pure virtual function void handle_reset(uvm_phase phase);
  
endclass


`endif
