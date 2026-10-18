 // ============================================================
// TEST 1: SMOKE (Write + Read)
// ============================================================
class test_smoke extends axi2apb_base_test;
    `uvm_component_utils(test_smoke)
    vseq_smoke seq;

    function new(string name = "test_smoke", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_smoke::type_id::create("seq");
        `uvm_info(get_type_name(), "Build Phase Executed", UVM_LOW)
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Smoke Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr); // Start on Virtual Sequencer
        phase.drop_objection(this);
        
        `uvm_info(get_type_name(), "Smoke Test Finished", UVM_LOW)
        #100;
        $finish;
    endtask
endclass


// ============================================================
// TEST 2: SINGLE WRITE
// ============================================================
class test_single_wr extends axi2apb_base_test;
    `uvm_component_utils(test_single_wr)
    vseq_single_wr seq;

    function new(string name = "test_single_wr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_single_wr::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Single Write Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Single Write Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 3: SINGLE READ
// ============================================================
class test_single_rd extends axi2apb_base_test;
    `uvm_component_utils(test_single_rd)
    vseq_single_rd seq;

    function new(string name = "test_single_rd", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_single_rd::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Single Read Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Single Read Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 4: WRITE WITH APB WAIT STATES
// ============================================================
class test_wr_wait extends axi2apb_base_test;
    `uvm_component_utils(test_wr_wait)
    vseq_wr_wait_states seq;

    function new(string name = "test_wr_wait", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_wr_wait_states::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Write with Wait States Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Write with Wait States Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 5: READ WITH APB WAIT STATES
// ============================================================
class test_rd_wait extends axi2apb_base_test;
    `uvm_component_utils(test_rd_wait)
    vseq_rd_wait_states seq;

    function new(string name = "test_rd_wait", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_rd_wait_states::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Read with Wait States Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Read with Wait States Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 6: READ WITH RREADY DELAY
// ============================================================
class test_rd_rready_delay extends axi2apb_base_test;
    `uvm_component_utils(test_rd_rready_delay)
    vseq_rd_rready_delay seq;

    function new(string name = "test_rd_rready_delay", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_rd_rready_delay::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Read with RREADY Delay Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Read with RREADY Delay Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 7: WRITE WITH BREADY DELAY
// ============================================================
class test_wr_bready_delay extends axi2apb_base_test;
    `uvm_component_utils(test_wr_bready_delay)
    vseq_wr_bready_delay seq;

    function new(string name = "test_wr_bready_delay", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_wr_bready_delay::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Write with BREADY Delay Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Write with BREADY Delay Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 8: READ/WRITE PRIORITY
// ============================================================
class test_rd_wr_priority extends axi2apb_base_test;
    `uvm_component_utils(test_rd_wr_priority)
    vseq_rd_wr_priority seq;

    function new(string name = "test_rd_wr_priority", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_rd_wr_priority::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Read/Write Priority Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Read/Write Priority Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 9: BACK-TO-BACK READS
// ============================================================
class test_b2b_rd extends axi2apb_base_test;
    `uvm_component_utils(test_b2b_rd)
    vseq_b2b_rd seq;

    function new(string name = "test_b2b_rd", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_b2b_rd::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Back-to-Back Reads Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Back-to-Back Reads Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 10: BACK-TO-BACK WRITES
// ============================================================
class test_b2b_wr extends axi2apb_base_test;
    `uvm_component_utils(test_b2b_wr)
    vseq_b2b_wr seq;

    function new(string name = "test_b2b_wr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_b2b_wr::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Back-to-Back Writes Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Back-to-Back Writes Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 11: MIXED TRAFFIC
// ============================================================
class test_mixed_rw extends axi2apb_base_test;
    `uvm_component_utils(test_mixed_rw)
    vseq_mixed_rw seq;

    function new(string name = "test_mixed_rw", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_mixed_rw::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Mixed Traffic Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Mixed Traffic Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 12: DIFFERENT IDs
// ============================================================
class test_diff_id extends axi2apb_base_test;
    `uvm_component_utils(test_diff_id)
    vseq_diff_id seq;

    function new(string name = "test_diff_id", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_diff_id::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Different IDs Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Different IDs Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 13: PSLVERR
// ============================================================
class test_pslverr extends axi2apb_base_test;
    `uvm_component_utils(test_pslverr)
    vseq_pslverr seq;

    function new(string name = "test_pslverr", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_pslverr::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "PSLVERR Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "PSLVERR Test Finished", UVM_LOW)
    endtask
endclass


// ============================================================
// TEST 14: BURST EXPERIMENT
// ============================================================
class test_burst_exp extends axi2apb_base_test;
    `uvm_component_utils(test_burst_exp)
    vseq_burst_exp seq;

    function new(string name = "test_burst_exp", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_burst_exp::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Burst Experiment Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Burst Experiment Test Finished", UVM_LOW)
    endtask
endclass
// ============================================================
// TEST 15: RANDOM
// ============================================================
class test_random extends axi2apb_base_test;
    `uvm_component_utils(test_random)
    vseq_random seq;

    function new(string name = "test_random", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_random::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Random Test Started", UVM_LOW)
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "Random Test Finished", UVM_LOW)
    endtask
endclass

class test_aw_then_w extends axi2apb_base_test;
    `uvm_component_utils(test_aw_then_w)
    vseq_aw_then_w seq;

    function new(string name = "test_aw_then_w", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        seq = vseq_aw_then_w::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
endclass
class test_always_ready extends axi2apb_base_test;
    `uvm_component_utils(test_always_ready)
    vseq_always_ready seq;

    function new(string name = "test_always_ready", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(bit)::set(this, "env.apb_agnt.drv", "always_ready", 1'b1);
        seq = vseq_always_ready::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.vseqr);
        phase.drop_objection(this);
    endtask
endclass

class test_fifo_backpressure extends axi2apb_base_test;

  `uvm_component_utils(test_fifo_backpressure)

  vseq_fifo_backpressure seq;

  function new(string name = "test_fifo_backpressure",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
      "BACKPRESSURE BUILD PHASE",
      UVM_LOW)

    seq =
      vseq_fifo_backpressure::type_id::create("seq");

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
      "BACKPRESSURE RUN PHASE",
      UVM_LOW)

    phase.raise_objection(this);

    seq.start(env.vseqr);

    phase.drop_objection(this);

  endtask : run_phase

  virtual function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
      "BACKPRESSURE REPORT PHASE",
      UVM_LOW)

  endfunction : report_phase

endclass : test_fifo_backpressure


class test_toggle_boost extends axi2apb_base_test;
  `uvm_component_utils(test_toggle_boost)

  vseq_toggle_boost seq;

  function new(string name = "test_toggle_boost",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "TOGGLE BOOST BUILD PHASE", UVM_LOW)
    seq = vseq_toggle_boost::type_id::create("seq");
  endfunction

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "TOGGLE BOOST RUN PHASE", UVM_LOW)
    phase.raise_objection(this);
    seq.start(env.vseqr);
    phase.drop_objection(this);
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "TOGGLE BOOST REPORT PHASE", UVM_LOW)
  endfunction
endclass
