///////////////////////////////////////////////////////////////////////////////
// Description: Register access test. Targets APB accesses to DUT registers.
//              This test includes 3 different sequences.
///////////////////////////////////////////////////////////////////////////////

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
    #105ns;
    
    //Reset logic and 3 different sequences in the fork....join
    fork
      
      //Reset after 3 APB transfers in middle of APB transfer to check reset handling
      begin
        cfs_apb_vif vif = env.apb_agent.agent_config.get_vif();
        
        repeat(3) begin
          @(posedge vif.psel);
        end
        
        #11ns;
        
        vif.preset_n <= 0;
        
        repeat(4) begin
          @(posedge vif.pclk);
        end
        
        vif.preset_n <= 1;
      end
      
      //Simple sequence
      begin
        
        //Step 1 Create the sequence
        cfs_apb_sequence_simple seq_simple = cfs_apb_sequence_simple::type_id::create("seq_simple");

        // Step 2 Randomize the sequence, here we also have in-line randomization using "with" keyword
        void'(seq_simple.randomize() with {
          //Address 0 corresponds to CTRL register
          item.addr == 'h0;
          item.dir  == CFS_APB_WRITE;
          item.data == 'h11;
        });

        //Step 3 Start the sequence
        seq_simple.start(env.apb_agent.sequencer);
      end

      //Read Write sequence
      begin
        cfs_apb_sequence_rw seq_rw = cfs_apb_sequence_rw::type_id::create("seq_rw");

        assert(seq_rw.randomize() with {
          //Not item.addr here as we have addr available publicly from that class
          //Address C corresponds to status register
          addr == 'hC;
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
    
    //After reset, the sequencer is empty as per our reset handling and this goes in.
      begin
        cfs_apb_sequence_random seq_random = cfs_apb_sequence_random::type_id::create("seq_random");

        void'(seq_random.randomize() with {
          num_items == 3;
        });

        seq_random.start(env.apb_agent.sequencer);

      end
    
    
    `uvm_info("DEBUG", "end of test", UVM_LOW)
    
    phase.drop_objection(this, "TEST_DONE");
  endtask
  
  
endclass


`endif- Clean-up + Comments
