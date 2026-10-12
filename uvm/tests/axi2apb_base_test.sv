`ifndef AXI2APB_BASE_TEST_SV
`define AXI2APB_BASE_TEST_SV

//------------------------------------------------------------
// AXI2APB BASE TEST
//
// Responsibilities:
// - Create verification environment
// - Common scoreboard completion handling
// - Timeout protection
// - Final test PASS / FAIL reporting
//------------------------------------------------------------

class axi2apb_base_test extends uvm_test;

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_base_test)

  //----------------------------------------------------------
  // Environment Handle
  //----------------------------------------------------------
  axi2apb_env env;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_base_test",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "BASE TEST BUILD PHASE EXECUTED",
              UVM_LOW)

    env = axi2apb_env::type_id::create("env", this);

  endfunction : build_phase

  //----------------------------------------------------------
  // End of Elaboration Phase
  //----------------------------------------------------------
  virtual function void end_of_elaboration_phase(
      uvm_phase phase
  );

    super.end_of_elaboration_phase(phase);

    `uvm_info(get_type_name(),
              "BASE TEST END OF ELABORATION PHASE EXECUTED",
              UVM_LOW)

    // Uncomment if UVM topology is needed.
    // uvm_top.print_topology();

  endfunction : end_of_elaboration_phase

  //----------------------------------------------------------
  // Common Scoreboard Completion Task
  //
  // Called from child tests:
  //
  // vseq.start(env.vseqr);
  // wait_for_completion(1);
  //
  // This waits for AXI/APB transaction comparisons.
  //----------------------------------------------------------
  virtual task wait_for_completion(
      int unsigned expected_transactions
  );

    bit completed;

    completed = 0;

    `uvm_info(get_type_name(),
      $sformatf(
        "Waiting for %0d AXI/APB completed transactions",
        expected_transactions),
      UVM_LOW)

    //--------------------------------------------------------
    // Wait for scoreboard or timeout
    //--------------------------------------------------------
    fork

      begin : scoreboard_wait

        wait ((env.scb.pass_count +
               env.scb.fail_count) >= expected_transactions);

        completed = 1;

      end

      begin : timeout_watchdog

        #10000ns;

      end

    join_any

    disable fork;

    //--------------------------------------------------------
    // Check Timeout
    //--------------------------------------------------------
    if (!completed) begin

      `uvm_fatal(get_type_name(),
        $sformatf(
          "SCOREBOARD TIMEOUT: EXPECTED=%0d PASS=%0d FAIL=%0d",
          expected_transactions,
          env.scb.pass_count,
          env.scb.fail_count))

    end

    //--------------------------------------------------------
    // Check Scoreboard Failures
    //--------------------------------------------------------
    if (env.scb.fail_count != 0) begin

      `uvm_error(get_type_name(),
        $sformatf(
          "SCOREBOARD FAILURES DETECTED: %0d",
          env.scb.fail_count))

    end

    `uvm_info(get_type_name(),
              "SCOREBOARD COMPLETION WAIT FINISHED",
              UVM_LOW)

  endtask : wait_for_completion

  //----------------------------------------------------------
  // Report Phase
  //----------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);

    uvm_report_server svr;

    super.report_phase(phase);

    `uvm_info(get_type_name(),
              "BASE TEST REPORT PHASE EXECUTED",
              UVM_LOW)

    svr = uvm_report_server::get_server();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) > 0) begin

      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(),
        "----            TEST FAIL          ----", UVM_NONE)
      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)

    end
    else begin

      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(),
        "----            TEST PASS          ----", UVM_NONE)
      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)

    end

  endfunction : report_phase

endclass : axi2apb_base_test

`endif