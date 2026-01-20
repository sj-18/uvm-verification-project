`include "cfs_algn_test_pkg.sv" 

module testbench();

  import uvm_pkg::*;
  import cfs_algn_test_pkg::*;
  
  reg clk;
  
  reg reset_n;
  
  cfs_apb_if apb_if(.pclk(clk));
  
  initial begin
    clk = 0;
    //10 ns clock
    forever begin
      clk = #5ns ~clk;
    end
  end
  
  initial begin
    reset_n = 1;
    #6ns;
    reset_n = 0;  //Reset registers etc.
    #30ns;
    reset_n = 1;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
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
