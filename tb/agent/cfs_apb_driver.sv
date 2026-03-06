///////////////////////////////////////////////////////////////////////////////
// Description: The APB driver class. 
//              1. Drives the signals on to the DUT
//              based on the sequence items it receives via the sequencer.
//              2. Reset handling kills the drive_transactions process and restarts.
///////////////////////////////////////////////////////////////////////////////

`ifndef CFS_APB_DRIVER_SV
 `define CFS_APB_DRIVER_SV

class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv)) implements cfs_apb_reset_handler;
  
  cfs_apb_agent_config agent_config;
  
  //Process for drive_transactions() task - pointer to it
  protected process process_drive_transactions;
  
  `uvm_component_utils(cfs_apb_driver)
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);    
  endfunction
    
  virtual task wait_reset_end();
    agent_config.wait_reset_end();
  endtask
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      fork 
        begin
          wait_reset_end();
          drive_transactions();
          
          //This will execute when drive_transactions is killed.
          //This in turn will kill the fork and the forever loop restarts the drive_transactions as it is in a forever loop
          disable fork;
        end
      join
    end
  endtask

  //"protected virtual" means only sub-classes can override
  protected virtual task drive_transactions();
    
    fork
      begin     
        //Process of drive transactions for reset handling
        process_drive_transactions = process::self();
        
        //Drive transactions after reset
        forever begin
          cfs_apb_item_drv item;
          
          //seq_item_port is in-built
          seq_item_port.get_next_item(item);

          drive_transaction(item);

          seq_item_port.item_done();

        end  
      end
    join
  endtask
  
  
  //Logic to drive the APB transaction as per protocol
  protected virtual task drive_transaction(cfs_apb_item_drv item);
    
    cfs_apb_vif vif = agent_config.get_vif();
    
    //Print the item info using convert2string
    `uvm_info("DEBUG", $sformatf("Driving \"%s\" : %s", item.get_full_name(), item.convert2string()) ,UVM_NONE);
    
    //Pre_drive delay before the APB transaction
    for(int i=0; i<item.pre_drive_delay; i++) begin
      @(posedge vif.pclk);
    end
    
    //Setup phase start
    vif.psel   <= 1'b1;
    vif.paddr  <= item.addr;
    vif.pwrite <= bit'(item.dir);
    
    if(item.dir == CFS_APB_WRITE) begin
      vif.pwdata <= item.data;
    end
    
    //After this clk edge we enter into setup phase
    @(posedge vif.pclk);
    
    //Access phase start
    vif.penable <= 1'b1;
    
    //After this clk edge we enter into access phase
    @(posedge vif.pclk);
    
    //Wait for slave to be ready after which transaction is over in the same cycle
    while(vif.pready != 1) begin
      @(posedge vif.pclk);
    end
    
    //After the transaction drive back all signals to 0
    vif.psel    <= 0;
    vif.penable <= 0;
    vif.pwrite  <= 0;
    vif.paddr   <= 0;
    vif.pwdata  <= 0;    
    
    //Post_drive delay after the ABP transaction
    for(int i=0; i<item.post_drive_delay; i++) begin
      @(posedge vif.pclk);
    end
    
  endtask

  //Function to handle the reset
  virtual function void handle_reset(uvm_phase phase);
    //We could use uvm_config_db, but usage of that is better kept minimal in run_phase() to avoid performance issues. 
    cfs_apb_vif vif = agent_config.get_vif();

    //Kill drive transactions
    if(process_drive_transactions != null) begin
      process_drive_transactions.kill();
      
      process_drive_transactions = null;
    end
    
    //Reset (use non-blocking statements to avoid race conditions) 
    vif.psel    <= 0;
    vif.penable <= 0;
    vif.pwrite  <= 0;
    vif.paddr   <= 0;
    vif.pwdata  <= 0;
    
    
  endfunction
  
  
endclass


`endif
