// ============================================================
// BASE VIRTUAL SEQUENCE
// ============================================================
class axi2apb_vbase_seq extends uvm_sequence;
    `uvm_object_utils(axi2apb_vbase_seq)
    `uvm_declare_p_sequencer(axi2apb_vseqr)

    function new(string name = "axi2apb_vbase_seq");
        super.new(name);
    endfunction

    // Common runner:
    //  - APB side = reactive responder (serves every DUT access, forever)
    //  - AXI side = runs to completion, with a timeout so a hang becomes a FAIL
        task run_axi_apb(uvm_sequence_base axi_s, uvm_sequence_base apb_s, time tmo = 5us);
        bit axi_done = 0;

        fork
            forever apb_s.start(p_sequencer.apb_sqr);
        join_none

        fork
            begin
                axi_s.start(p_sequencer.axi_sqr);
                axi_done = 1;
            end
            begin
                #tmo;
            end
        join_any

        if (!axi_done)
            `uvm_error("VSEQ", "TIMEOUT: AXI sequence did not finish (DUT/driver hang)")

        #200ns;          // drain time for monitors / scoreboard
        disable fork;    // stop APB responder and timeout threads
    endtask
endclass


// ============================================================
// TEST 1: SMOKE TEST (Write + Read)
// ============================================================
class vseq_smoke extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_smoke)
    function new(string name = "vseq_smoke"); super.new(name); endfunction

    virtual task body();
        axi_smoke_sequence        axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_smoke_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 2: SINGLE WRITE
// ============================================================
class vseq_single_wr extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_single_wr)
    function new(string name = "vseq_single_wr"); super.new(name); endfunction

    virtual task body();
        axi_single_wr_sequence    axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_single_wr_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 3: SINGLE READ
// ============================================================
class vseq_single_rd extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_single_rd)
    function new(string name = "vseq_single_rd"); super.new(name); endfunction

    virtual task body();
        axi_single_rd_sequence    axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_single_rd_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 4: WRITE WITH APB WAIT STATES
// ============================================================
class vseq_wr_wait_states extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_wr_wait_states)
    function new(string name = "vseq_wr_wait_states"); super.new(name); endfunction

    virtual task body();
        axi_wr_wait_sequence      axi_seq;
        apb_wait_state_sequence   apb_seq;
        axi_seq = axi_wr_wait_sequence::type_id::create("axi_seq");
        apb_seq = apb_wait_state_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 5: READ WITH APB WAIT STATES
// ============================================================
class vseq_rd_wait_states extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_rd_wait_states)
    function new(string name = "vseq_rd_wait_states"); super.new(name); endfunction

    virtual task body();
        axi_rd_wait_sequence      axi_seq;
        apb_wait_state_sequence   apb_seq;
        axi_seq = axi_rd_wait_sequence::type_id::create("axi_seq");
        apb_seq = apb_wait_state_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 6: READ WITH RREADY DELAY
// ============================================================
class vseq_rd_rready_delay extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_rd_rready_delay)
    function new(string name = "vseq_rd_rready_delay"); super.new(name); endfunction

    virtual task body();
        axi_rd_rready_delay_sequence axi_seq;
        apb_std_response_sequence    apb_seq;
        axi_seq = axi_rd_rready_delay_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 7: WRITE WITH BREADY DELAY
// ============================================================
class vseq_wr_bready_delay extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_wr_bready_delay)
    function new(string name = "vseq_wr_bready_delay"); super.new(name); endfunction

    virtual task body();
        axi_wr_bready_delay_sequence axi_seq;
        apb_std_response_sequence    apb_seq;
        axi_seq = axi_wr_bready_delay_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 8: READ/WRITE PRIORITY
// ============================================================
class vseq_rd_wr_priority extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_rd_wr_priority)
    function new(string name = "vseq_rd_wr_priority"); super.new(name); endfunction

    virtual task body();
        axi_rd_wr_priority_sequence axi_seq;
        apb_std_response_sequence   apb_seq;
        axi_seq = axi_rd_wr_priority_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 9: BACK-TO-BACK READS
// ============================================================
class vseq_b2b_rd extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_b2b_rd)
    function new(string name = "vseq_b2b_rd"); super.new(name); endfunction

    virtual task body();
        axi_b2b_rd_sequence       axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_b2b_rd_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 10: BACK-TO-BACK WRITES
// ============================================================
class vseq_b2b_wr extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_b2b_wr)
    function new(string name = "vseq_b2b_wr"); super.new(name); endfunction

    virtual task body();
        axi_b2b_wr_sequence       axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_b2b_wr_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 11: MIXED TRAFFIC
// ============================================================
class vseq_mixed_rw extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_mixed_rw)
    function new(string name = "vseq_mixed_rw"); super.new(name); endfunction

    virtual task body();
        axi_mixed_rw_sequence     axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_mixed_rw_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 12: DIFFERENT IDs & USER
// ============================================================
class vseq_diff_id extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_diff_id)
    function new(string name = "vseq_diff_id"); super.new(name); endfunction

    virtual task body();
        axi_diff_id_user_sequence axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_diff_id_user_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 13: PSLVERR INJECTION
// ============================================================
class vseq_pslverr extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_pslverr)
    function new(string name = "vseq_pslverr"); super.new(name); endfunction

    virtual task body();
        axi_pslverr_sequence      axi_seq;
        apb_error_sequence        apb_seq;
        axi_seq = axi_pslverr_sequence::type_id::create("axi_seq");
        apb_seq = apb_error_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass


// ============================================================
// TEST 14: BURST EXPERIMENT
// ============================================================
class vseq_burst_exp extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_burst_exp)
    function new(string name = "vseq_burst_exp"); super.new(name); endfunction

    virtual task body();
        axi_burst_exp_sequence    axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_burst_exp_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass

// ============================================================
// RANDOM TEST
// ============================================================
class vseq_random extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_random)
    function new(string name = "vseq_random"); super.new(name); endfunction

    virtual task body();
        axi_random_sequence          axi_seq;
        apb_random_response_sequence apb_seq;
        axi_seq = axi_random_sequence::type_id::create("axi_seq");
        apb_seq = apb_random_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq, 500us);
    endtask
endclass

class vseq_aw_then_w extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_aw_then_w)
    function new(string name = "vseq_aw_then_w"); super.new(name); endfunction

    virtual task body();
        axi_aw_then_w_sequence    axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_aw_then_w_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);
    endtask
endclass

class vseq_always_ready extends axi2apb_vbase_seq;
    `uvm_object_utils(vseq_always_ready)
    function new(string name = "vseq_always_ready"); super.new(name); endfunction

    virtual task body();
        axi_smoke_sequence        axi_seq;
        apb_std_response_sequence apb_seq;
        axi_seq = axi_smoke_sequence::type_id::create("axi_seq");
        apb_seq = apb_std_response_sequence::type_id::create("apb_seq");
        run_axi_apb(axi_seq, apb_seq);   // WRITE then READ against an always-ready APB slave
    endtask
endclass

class vseq_fifo_backpressure extends axi2apb_vbase_seq;

  `uvm_object_utils(vseq_fifo_backpressure)

  function new(string name = "vseq_fifo_backpressure");
    super.new(name);
  endfunction

  virtual task body();

    axi_fifo_backpressure_sequence axi_seq;
    apb_fifo_backpressure_sequence apb_seq;

    `uvm_info(get_type_name(),
      "VIRTUAL BACKPRESSURE SEQUENCE STARTED",
      UVM_LOW)

    axi_seq =
      axi_fifo_backpressure_sequence::type_id::create("axi_seq");

    apb_seq =
      apb_fifo_backpressure_sequence::type_id::create("apb_seq");

    run_axi_apb(axi_seq, apb_seq, 100us);

  endtask : body

endclass : vseq_fifo_backpressure
class vseq_toggle_boost extends axi2apb_vbase_seq;
  `uvm_object_utils(vseq_toggle_boost)

  function new(string name = "vseq_toggle_boost");
    super.new(name);
  endfunction

  virtual task body();
    axi_toggle_boost_sequence axi_seq;
    apb_std_response_sequence apb_seq;

    `uvm_info(get_type_name(),
      "TOGGLE BOOST VIRTUAL SEQUENCE STARTED", UVM_LOW)

    axi_seq = axi_toggle_boost_sequence::type_id::create("axi_seq");
    apb_seq = apb_std_response_sequence::type_id::create("apb_seq");

    run_axi_apb(axi_seq, apb_seq, 100us);
  endtask
endclass