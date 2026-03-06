///////////////////////////////////////////////////////////////////////////////
// Description: Testbench top module. It contains the DUT //              instance and run_test() for UVM
///////////////////////////////////////////////////////////////////////////////

`include "cfs_algn_test_pkg.sv" 

module testbench();

  import uvm_pkg::*;
  import cfs_algn_test_pkg::*;
  
  reg clk;
  
  //APB interface instance
  cfs_apb_if apb_if(.pclk(clk));
  
  //Clock generation
  initial begin
    clk = 0;
    //10 ns clock
    forever begin
      clk = #5ns ~clk;
    end
  end
  
  //Initial Reset
  initial begin
    apb_if.preset_n = 1;
    #3ns;
    apb_if.preset_n = 0;  //Reset registers etc.
    #30ns;
    apb_if.preset_n = 1;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    //Set apb interface in the config_db
    uvm_config_db#(virtual cfs_apb_if)::set(null, "uvm_test_top.env.apb_agent", "vif", apb_if);
    
    //Start UVM test
    run_test("");
  end
  
  // Aligner DUT instance
  cfs_aligner dut(
    .clk      (clk),
    .reset_n  (apb_if.preset_n),
    
    .paddr    (apb_if.paddr),
    .pwrite   (apb_if.pwrite),
    .psel     (apb_if.psel),
    .penable  (apb_if.penable),
    .pwdata   (apb_if.pwdata),
    .prdata   (apb_if.prdata),
    .pready   (apb_if.pready),
    .pslverr  (apb_if.pslverr)    
  );
  
endmodule
