`ifndef CFS_APB_COVERAGE_SV
 `define CFS_APB_COVERAGE_SV

//Helps handle connections to multiple analysis ports by adding the suffix(which is _item here)
`uvm_analysis_imp_decl(_item)

//Wrapper class for coverage of indices of addr and data
class cfs_apb_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_component;
  
  `uvm_component_param_utils(cfs_apb_cover_index_wrapper#(MAX_VALUE_PLUS_1))
  
      
  //Addr 0s - out of 16 addr bits which all have been set 0
  //Addr 1s - out of 16 addr bits which all have been set 1
  //Similar for wdata and rdata
  covergroup cover_index with function sample(int unsigned value);
    option.per_instance = 1;
    
    index : coverpoint value{
      option.comment = "Index";
      
      bins values[MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1-1]};  
      
    }
    
  endgroup
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    cover_index = new();
    cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
  endfunction
  
  virtual function void sample(int unsigned value);
    cover_index.sample(value);    
  endfunction
  
  virtual function string coverage2string();
    string result = {
      $sformatf("\n cover_index:     %03.2f%%", cover_index.get_inst_coverage()),
      $sformatf("\n index:           %03.2f%%", cover_index.index.get_inst_coverage())
    };
    
    return result;
  endfunction
  
endclass


//APB coverage class
class cfs_apb_coverage extends uvm_component;
  
  cfs_apb_agent_config agent_config;
  
  //Port for receiving the collected item from the monitor
  uvm_analysis_imp_item #(cfs_apb_item_mon, cfs_apb_coverage) port_item;
  
  //Wrapper over the coverage group covering the indices of PADDR
  //where that bit of PADDR is 0.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_0;
  
  //Wrapper over the coverage group covering the indices of PADDR
  //where that bit of PADDR is 1.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;
  
  //Wrapper over the coverage group covering the indices of PWDATA
  //where that bit of PWDATA is 0.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wdata_0;
  
  //Wrapper over the coverage group covering the indices of PWDATA
  //where that bit of PWDATA is 1.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wdata_1;
  
  //Wrapper over the coverage group covering the indices of PRDATA
  //where that bit of PRDATA is 0.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rdata_0;
  
  //Wrapper over the coverage group covering the indices of PRDATA
  //where that bit of PRDATA is 1.
  cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rdata_1;
  
  `uvm_component_utils(cfs_apb_coverage)
  
  covergroup cover_item with function sample(cfs_apb_item_mon item);
    //We want every instance to have its own coverage separate
    option.per_instance = 1;
    
    //Read/Write
    direction : coverpoint item.dir{
     // The comment shows up in coverage viewers and makes it readable 
     option.comment = "Direction of the APB access"; 
    }
    
    //Error from slave or no error
    response : coverpoint item.response{
     option.comment = "Response of the APB access"; 
    }
    
    //Length of the apb access split into 3 regions
    length : coverpoint item.length{
     option.comment = "Length of the APB access";
      
      bins length_eq_2    = {2};
      bins length_le_10[] = {[3:10]};  //8 bins
      bins length_gt_10   = {[11:$]};  //1 bin
    }
    
    //delay in clock cycles from the previous apb transfer
    prev_item_delay : coverpoint item.prev_item_delay{
     
     option.comment = "Delay in clock cycles between 2 consecutive APB access";
      
      bins back_2_back   = {0};
      bins delay_le_5[]  = {[1:5]};   //5 bins
      bins delay_gt_5    = {[6:$]};  
    }
    
    //cross of response and direction 
    response_x_direction: cross response, direction;
    
    //check that all transitions RR,RW,WR,WW have occured
    trans_direction: coverpoint item.dir{
      option.comment = "Transitions of APB direction";
      
      bins direction_trans[] = (CFS_APB_READ, CFS_APB_WRITE => CFS_APB_READ, CFS_APB_WRITE);
    }
    
  endgroup
  
  //Check for reset when APB transfer ongoing
  covergroup cover_reset with function sample(bit psel);
    option.per_instance = 1;
    
    access_ongoing : coverpoint psel{
      option.comment = "Reset when APB transfer ongoing";
    }
    
  endgroup
  
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    
    port_item = new("port_item", this);
    
    cover_item = new();
    //This instance name will be used to refer to this in verif plans
    cover_item.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_item"));
    
    cover_reset = new();
    cover_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));
    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    wrap_cover_addr_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_0", this);
    wrap_cover_addr_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_1", this);
    wrap_cover_wdata_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wdata_0", this);
    wrap_cover_wdata_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wdata_1", this);
    wrap_cover_rdata_0 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rdata_0", this);
    wrap_cover_rdata_1 = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rdata_1", this);
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    cfs_apb_vif vif = agent_config.get_vif();
    
    //If reset occurs check if APB access ongoing
    forever begin
      @(negedge vif.preset_n);
      
      cover_reset.sample(vif.psel);
    end
    
  endtask  
  
  
  //NOTE : EDA Playground does not have a GUI to show coverage data. Hence, this function helps print some coverage info in the log. It is NOT needed if we have a vendor GUI available
  virtual function string coverage2string();
    string result = {
      $sformatf("\n cover_item:              %03.2f%%", cover_item.get_inst_coverage()),
      $sformatf("\n direction:               %03.2f%%", cover_item.direction.get_inst_coverage()),
      $sformatf("\n response:                %03.2f%%", cover_item.response.get_inst_coverage()),
      $sformatf("\n length:                  %03.2f%%", cover_item.length.get_inst_coverage()),
      $sformatf("\n prev_item_delay:         %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
      $sformatf("\n response_x_direction:    %03.2f%%", cover_item.response_x_direction.get_inst_coverage()),
      $sformatf("\n trans_direction:         %03.2f%%", cover_item.trans_direction.get_inst_coverage()),
      $sformatf("\n"),
      $sformatf("\n cover_reset:             %03.2f%%", cover_reset.get_inst_coverage()),
      $sformatf("\n access_ongoing:          %03.2f%%", cover_reset.access_ongoing.get_inst_coverage()),
      $sformatf("\n"),
      $sformatf("\n addr_0:         %s \n", wrap_cover_addr_0.coverage2string()),
      $sformatf("\n addr_1:         %s \n", wrap_cover_addr_1.coverage2string()),
      $sformatf("\n rdata_0:        %s \n", wrap_cover_rdata_0.coverage2string()),
      $sformatf("\n rdata_1:        %s \n", wrap_cover_rdata_1.coverage2string()),
      $sformatf("\n wdata_0:        %s \n", wrap_cover_wdata_0.coverage2string()),
      $sformatf("\n wdata_1:        %s \n", wrap_cover_wdata_1.coverage2string())
    };
    
    return result;
  endfunction
  
  //Write function with suffix _item for receiving monitor data
  virtual function void write_item(cfs_apb_item_mon item);
    //Sample item received in our covergroup declared above which expects a cfs_apb_item_mon type
    cover_item.sample(item);
    
    for(int i = 0; i < `CFS_APB_MAX_ADDR_WIDTH; i++) begin
      if(item.addr[i]) begin
        wrap_cover_addr_1.sample(i);
      end else begin
        wrap_cover_addr_0.sample(i);
      end
    end
    
    for(int i = 0; i < `CFS_APB_MAX_DATA_WIDTH; i++) begin
      case(item.dir)
        
        CFS_APB_WRITE : begin
          if(item.data[i]) begin
            wrap_cover_wdata_1.sample(i);
          end else begin
            wrap_cover_wdata_0.sample(i);
          end
        end
          
        CFS_APB_READ : begin
          if(item.data[i]) begin
            wrap_cover_rdata_1.sample(i);
          end else begin
            wrap_cover_rdata_0.sample(i);
          end
        end
        
        default: begin
          `uvm_error("ALGO ISSUE", $sformatf("Current algo does not support the item.dir value of %s", item.dir.name()))
        end
      endcase
    end
    
    //NOT NEEDED IN A REAL PROJECT WITH GUI
    `uvm_info("DEBUG", $sformatf("COVERAGE : %0s", coverage2string()), UVM_NONE)
  endfunction
  
  
endclass


`endif
