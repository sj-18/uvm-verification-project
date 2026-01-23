`ifndef CFS_ALGN_TEST_REG_ACCESS
 `define CFS_ALGN_TEST_REG_ACCESS

class cfs_algn_test_reg_access extends cfs_algn_test_base;
  
  `uvm_component_utils(cfs_algn_test_reg_access)
  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "TEST_DONE");
    
    `uvm_info("DEBUG", "start of test", UVM_LOW)
    #100ns;
    fork
      //Simple sequence
      begin
        cfs_apb_sequence_simple seq_simple = cfs_apb_sequence_simple::type_id::create("seq_simple");

        void'(seq_simple.randomize() with {
          item.addr == 'h222;
        });

        seq_simple.start(env.apb_agent.sequencer);
      end

      //Read Write sequence
      begin
        cfs_apb_sequence_rw seq_rw = cfs_apb_sequence_rw::type_id::create("seq_rw");

        assert(seq_rw.randomize() with {
          //Not item.addr here as we have addr available publicly from that class
          addr == 'h4;
        });

        seq_rw.start(env.apb_agent.sequencer);

      end

      //Random sequence - calls num_item times the simple sequence
      begin
        cfs_apb_sequence_random seq_random = cfs_apb_sequence_random::type_id::create("seq_random");

        void'(seq_random.randomize() with {
          num_items == 3;
        });

        seq_random.start(env.apb_agent.sequencer);

      end
    join
    /*
    for(int i=0; i<10; i++) begin
      cfs_apb_item_drv item = cfs_apb_item_drv::type_id::create("item");
      
      //Using item.randomize() over std randomize helps include pre_randomize and post_randomize methods if needed
      //void'(std::randomize(item));
      void'(item.randomize());
      
      `uvm_info("DEBUG", $sformatf("[%0d] Item : %0s", i, item.convert2string()), UVM_LOW)
   
    end
    */
    
    `uvm_info("DEBUG", "end of test", UVM_LOW)
    
    phase.drop_objection(this, "TEST_DONE");
  endtask
  
  
endclass


`endif
