
`ifndef AXI2APB_TESTS_SV
`define AXI2APB_TESTS_SV

//============================================================
// TEST 1: RESET / SMOKE TEST
//============================================================
class axi2apb_smoke_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_smoke_test)

  function new(string name = "axi2apb_smoke_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "SMOKE TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_smoke_vseq vseq;

    `uvm_info(get_type_name(),
              "SMOKE TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_smoke_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "SMOKE VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "SMOKE TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_smoke_test


//============================================================
// TEST 2: SINGLE AXI WRITE - IMMEDIATE APB READY
//============================================================
class axi2apb_single_write_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_single_write_test)

  function new(string name = "axi2apb_single_write_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "SINGLE WRITE TEST BUILD PHASE EXECUTED",
              UVM_LOW)

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);

    axi2apb_single_write_vseq vseq;
    bit completed;

    `uvm_info(get_type_name(),
              "SINGLE WRITE TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_single_write_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "VIRTUAL SEQUENCE CREATION FAILED")

    //--------------------------------------------------------
    // Start virtual sequence
    //--------------------------------------------------------
    vseq.start(env.vseqr);

    //--------------------------------------------------------
    // Wait for scoreboard to compare AXI and APB WRITE
    //--------------------------------------------------------
    completed = 0;

    fork
      begin
        wait ((env.scb.pass_count + env.scb.fail_count) >= 1);
        completed = 1;
      end

      begin
        #10000ns;
      end
    join_any

    disable fork;

    //--------------------------------------------------------
    // Check completion
    //--------------------------------------------------------
    if (!completed)
      `uvm_fatal(get_type_name(),
                 "TIMEOUT: AXI/APB WRITE COMPARISON NOT COMPLETED")

    if (env.scb.pass_count != 1 ||
        env.scb.fail_count != 0 ||
        env.scb.axi_write_count != 1 ||
        env.scb.apb_write_count != 1 ||
        env.scb.axi_read_count != 0 ||
        env.scb.apb_read_count != 0 ||
        env.scb.axi_write_q.size() != 0 ||
        env.scb.apb_write_q.size() != 0 ||
        env.scb.axi_read_q.size() != 0 ||
        env.scb.apb_read_q.size() != 0)
      `uvm_error(get_type_name(),
                 "SINGLE WRITE TEST VALIDATION FAILED")

    `uvm_info(get_type_name(),
              "SINGLE WRITE TEST RUN PHASE COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask : run_phase

endclass : axi2apb_single_write_test

//============================================================
// TEST 3: SINGLE AXI READ - IMMEDIATE APB READY
//============================================================
class axi2apb_single_read_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_single_read_test)

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_single_read_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "SINGLE READ TEST BUILD PHASE EXECUTED",
              UVM_LOW)

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    axi2apb_single_read_vseq vseq;
    bit completed;

    `uvm_info(get_type_name(),
              "SINGLE READ TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    //--------------------------------------------------------
    // Create virtual sequence
    //--------------------------------------------------------
    vseq = axi2apb_single_read_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "SINGLE READ VIRTUAL SEQUENCE CREATION FAILED")

    //--------------------------------------------------------
    // Start virtual sequence
    //--------------------------------------------------------
    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "SINGLE READ VIRTUAL SEQUENCE COMPLETED",
              UVM_LOW)

    //--------------------------------------------------------
    // Wait for AXI/APB READ scoreboard comparison
    //--------------------------------------------------------
    completed = 0;

    fork
      begin : scoreboard_wait
        wait ((env.scb.pass_count + env.scb.fail_count) >= 1);
        completed = 1;
      end

      begin : timeout_watchdog
        #10000ns;
      end
    join_any

    disable fork;

    if (!completed)
      `uvm_fatal(get_type_name(),
                 "TIMEOUT: AXI/APB READ COMPARISON NOT COMPLETED")

    //--------------------------------------------------------
    // Validate single READ transaction
    //--------------------------------------------------------
    if (env.scb.axi_read_count != 1 ||
        env.scb.apb_read_count != 1 ||
        env.scb.axi_write_count != 0 ||
        env.scb.apb_write_count != 0 ||
        env.scb.pass_count != 1 ||
        env.scb.fail_count != 0 ||
        env.scb.apb_wait_count != 0 ||
        env.scb.pslverr_count != 0 ||
        env.scb.axi_read_q.size() != 0 ||
        env.scb.apb_read_q.size() != 0 ||
        env.scb.axi_write_q.size() != 0 ||
        env.scb.apb_write_q.size() != 0) begin

      `uvm_error(get_type_name(),
                 "SINGLE READ TEST VALIDATION FAILED")

    end
    else begin

      `uvm_info(get_type_name(),
                "SINGLE READ TEST VALIDATION PASSED",
                UVM_LOW)

    end

    //--------------------------------------------------------
    // Final summary
    //--------------------------------------------------------
    `uvm_info(get_type_name(),
      $sformatf(
        "READ SUMMARY: AXI_RD=%0d APB_RD=%0d PASS=%0d FAIL=%0d WAIT=%0d PSLVERR=%0d",
        env.scb.axi_read_count,
        env.scb.apb_read_count,
        env.scb.pass_count,
        env.scb.fail_count,
        env.scb.apb_wait_count,
        env.scb.pslverr_count),
      UVM_LOW)

    `uvm_info(get_type_name(),
              "SINGLE READ TEST RUN PHASE COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask : run_phase

endclass : axi2apb_single_read_test


//============================================================
// TEST 4: AXI WRITE WITH APB WAIT STATES
//============================================================
class axi2apb_write_wait_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_write_wait_test)

  function new(string name = "axi2apb_write_wait_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "WRITE WAIT TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_write_wait_vseq vseq;

    `uvm_info(get_type_name(),
              "WRITE WAIT TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_write_wait_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "WRITE WAIT VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    if (env.scb.apb_wait_count == 0) begin
      `uvm_error(get_type_name(),
                 "WRITE WAIT TEST: No APB Wait States Observed")
    end

    `uvm_info(get_type_name(),
              "WRITE WAIT TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_write_wait_test


//============================================================
// TEST 5: AXI READ WITH APB WAIT STATES
//============================================================
class axi2apb_read_wait_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_read_wait_test)

  function new(string name = "axi2apb_read_wait_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "READ WAIT TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_read_wait_vseq vseq;

    `uvm_info(get_type_name(),
              "READ WAIT TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_read_wait_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "READ WAIT VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    if (env.scb.apb_wait_count == 0) begin
      `uvm_error(get_type_name(),
                 "READ WAIT TEST: No APB Wait States Observed")
    end

    `uvm_info(get_type_name(),
              "READ WAIT TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_read_wait_test


//============================================================
// TEST 6: AXI READ WITH DELAYED RREADY
//============================================================
class axi2apb_delayed_rready_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_delayed_rready_test)

  function new(string name = "axi2apb_delayed_rready_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "DELAYED RREADY TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_delayed_rready_vseq vseq;

    `uvm_info(get_type_name(),
              "DELAYED RREADY TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_delayed_rready_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "DELAYED RREADY VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "DELAYED RREADY TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_delayed_rready_test


//============================================================
// TEST 7: AXI WRITE WITH DELAYED BREADY
//============================================================
class axi2apb_delayed_bready_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_delayed_bready_test)

  function new(string name = "axi2apb_delayed_bready_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "DELAYED BREADY TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_delayed_bready_vseq vseq;

    `uvm_info(get_type_name(),
              "DELAYED BREADY TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_delayed_bready_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "DELAYED BREADY VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "DELAYED BREADY TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_delayed_bready_test


//============================================================
// TEST 8: SIMULTANEOUS AXI READ AND WRITE
//============================================================
class axi2apb_simultaneous_rw_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_simultaneous_rw_test)

  function new(string name = "axi2apb_simultaneous_rw_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "SIMULTANEOUS RW TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_simultaneous_rw_vseq vseq;

    `uvm_info(get_type_name(),
              "SIMULTANEOUS RW TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_simultaneous_rw_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "SIMULTANEOUS RW VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    if (env.scb.axi_read_count != 1 ||
        env.scb.axi_write_count != 1) begin

      `uvm_error(get_type_name(),
                 "SIMULTANEOUS RW TEST: Expected One Read and One Write")

    end

    `uvm_info(get_type_name(),
              "SIMULTANEOUS RW TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_simultaneous_rw_test


//============================================================
// TEST 9: BACK-TO-BACK AXI READS
//============================================================
class axi2apb_back_to_back_reads_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_back_to_back_reads_test)

  function new(string name = "axi2apb_back_to_back_reads_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "BACK-TO-BACK READS TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_back_to_back_reads_vseq vseq;

    `uvm_info(get_type_name(),
              "BACK-TO-BACK READS TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_back_to_back_reads_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "BACK-TO-BACK READS VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "BACK-TO-BACK READS TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_back_to_back_reads_test


//============================================================
// TEST 10: BACK-TO-BACK AXI WRITES
//============================================================
class axi2apb_back_to_back_writes_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_back_to_back_writes_test)

  function new(string name = "axi2apb_back_to_back_writes_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "BACK-TO-BACK WRITES TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_back_to_back_writes_vseq vseq;

    `uvm_info(get_type_name(),
              "BACK-TO-BACK WRITES TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_back_to_back_writes_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "BACK-TO-BACK WRITES VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "BACK-TO-BACK WRITES TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_back_to_back_writes_test


//============================================================
// TEST 11: MIXED AXI READ / WRITE TRAFFIC
//============================================================
class axi2apb_mixed_traffic_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_mixed_traffic_test)

  function new(string name = "axi2apb_mixed_traffic_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "MIXED TRAFFIC TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_mixed_traffic_vseq vseq;

    `uvm_info(get_type_name(),
              "MIXED TRAFFIC TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_mixed_traffic_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "MIXED TRAFFIC VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "MIXED TRAFFIC TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_mixed_traffic_test


//============================================================
// TEST 12: DIFFERENT AXI IDs AND USER VALUES
//============================================================
class axi2apb_id_user_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_id_user_test)

  function new(string name = "axi2apb_id_user_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "ID/USER TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_id_user_vseq vseq;

    `uvm_info(get_type_name(),
              "ID/USER TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_id_user_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "ID/USER VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    `uvm_info(get_type_name(),
              "ID/USER TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_id_user_test


//============================================================
// TEST 13: APB PSLVERR STIMULUS
//============================================================
class axi2apb_pslverr_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_pslverr_test)

  function new(string name = "axi2apb_pslverr_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "PSLVERR TEST BUILD PHASE EXECUTED",
              UVM_LOW)
  endfunction

  virtual task run_phase(uvm_phase phase);

    axi2apb_pslverr_vseq vseq;

    `uvm_info(get_type_name(),
              "PSLVERR TEST RUN PHASE EXECUTED",
              UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_pslverr_vseq::type_id::create("vseq");

    if (vseq == null)
      `uvm_fatal(get_type_name(),
                 "PSLVERR VIRTUAL SEQUENCE CREATION FAILED")

    vseq.start(env.vseqr);

    if (env.scb.pslverr_count != 2) begin

      `uvm_error(get_type_name(),
                 $sformatf(
                   "PSLVERR TEST: Expected 2 APB Errors, Observed %0d",
                   env.scb.pslverr_count))

    end

    `uvm_info(get_type_name(),
              "PSLVERR TEST COMPLETED",
              UVM_LOW)

    phase.drop_objection(this);

  endtask

endclass : axi2apb_pslverr_test

`endif
