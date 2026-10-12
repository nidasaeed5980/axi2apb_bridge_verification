`ifndef AXI2APB_COVERAGE_SV
`define AXI2APB_COVERAGE_SV

//============================================================
// AXI2APB FUNCTIONAL COVERAGE
//
// Covers:
// 1. Immediate Read
// 2. Immediate Write
// 3. Read with Wait States
// 4. Write with Wait States
// 5. Read with PSLVERR
// 6. Write with PSLVERR
//
// Smoke test coverage:
//   Smoke generates basic read/write transactions.
//   Both are tracked using immediate read/write bins.
//
// Coverage source:
//   APB Monitor -> Analysis Port -> Coverage Subscriber
//============================================================

class axi2apb_coverage extends uvm_subscriber #(apb_seq_item);

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_coverage)

  //----------------------------------------------------------
  // Coverage Sampling Variables
  //----------------------------------------------------------
  bit          cov_write;
  int unsigned cov_wait_cycles;
  bit          cov_slverr;

  int unsigned total_samples;

  //----------------------------------------------------------
  // Scenario Hit Counters
  //----------------------------------------------------------
  int unsigned immediate_read_count;
  int unsigned immediate_write_count;
  int unsigned read_wait_count;
  int unsigned write_wait_count;
  int unsigned read_slverr_count;
  int unsigned write_slverr_count;

  //----------------------------------------------------------
  // Functional Coverage Group
  //----------------------------------------------------------
  covergroup apb_cg;

    option.per_instance = 1;

    //--------------------------------------------------------
    // READ / WRITE
    //--------------------------------------------------------
    cp_operation: coverpoint cov_write {
      bins READ  = {0};
      bins WRITE = {1};
    }

    //--------------------------------------------------------
    // WAIT CYCLES
    //--------------------------------------------------------
    cp_wait: coverpoint cov_wait_cycles {
      bins IMMEDIATE  = {0};
      bins ONE_WAIT   = {1};
      bins MULTI_WAIT = {[2:10]};
      bins LONG_WAIT  = {[11:1000000]};
    }

    //--------------------------------------------------------
    // SLAVE ERROR
    //--------------------------------------------------------
    cp_slverr: coverpoint cov_slverr {
      bins NO_ERROR = {0};
      bins ERROR    = {1};
    }

    //--------------------------------------------------------
    // READ / WRITE x WAIT
    //--------------------------------------------------------
    operation_wait_cross: cross cp_operation, cp_wait;

    //--------------------------------------------------------
    // READ / WRITE x ERROR
    //--------------------------------------------------------
    operation_error_cross: cross cp_operation, cp_slverr;

    //--------------------------------------------------------
    // MAIN SCENARIO COVERAGE
    //--------------------------------------------------------
    cp_scenarios: coverpoint {
      cov_write,
      (cov_wait_cycles != 0),
      cov_slverr
    } {

      // {write, has_wait, slverr}

      bins IMMEDIATE_READ  = {3'b000};
      bins IMMEDIATE_WRITE = {3'b100};

      bins READ_WAIT       = {3'b010};
      bins WRITE_WAIT      = {3'b110};

      bins READ_SLVERR     = {3'b001, 3'b011};
      bins WRITE_SLVERR    = {3'b101, 3'b111};

    }

  endgroup : apb_cg

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_coverage",
               uvm_component parent = null);

    super.new(name, parent);

    apb_cg = new();

    total_samples         = 0;
    immediate_read_count  = 0;
    immediate_write_count = 0;
    read_wait_count       = 0;
    write_wait_count      = 0;
    read_slverr_count     = 0;
    write_slverr_count    = 0;

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "COVERAGE BUILD PHASE EXECUTED",
              UVM_LOW)

  endfunction : build_phase

  //----------------------------------------------------------
  // Connect Phase
  //----------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info(get_type_name(),
              "COVERAGE CONNECT PHASE EXECUTED",
              UVM_LOW)

  endfunction : connect_phase

  //----------------------------------------------------------
  // Write Function
  //
  // Receives completed APB transactions from monitor.
  //----------------------------------------------------------
  virtual function void write(apb_seq_item t);

    if (t == null) begin
      `uvm_error(get_type_name(),
                 "NULL APB TRANSACTION RECEIVED")
      return;
    end

    //--------------------------------------------------------
    // Capture Observed APB Values
    //--------------------------------------------------------
    cov_write       = t.write;
    cov_wait_cycles = t.wait_cycles;
    cov_slverr      = t.slverr;

    //--------------------------------------------------------
    // Sample Covergroup
    //--------------------------------------------------------
    apb_cg.sample();

    total_samples++;

    //--------------------------------------------------------
    // Update Scenario Counters
    //--------------------------------------------------------

    if (cov_slverr == 1'b1) begin

      if (cov_write == 1'b0)
        read_slverr_count++;
      else
        write_slverr_count++;

    end
    else if (cov_wait_cycles > 0) begin

      if (cov_write == 1'b0)
        read_wait_count++;
      else
        write_wait_count++;

    end
    else begin

      if (cov_write == 1'b0)
        immediate_read_count++;
      else
        immediate_write_count++;

    end

    //--------------------------------------------------------
    // Coverage Log
    //--------------------------------------------------------
    `uvm_info(get_type_name(),
      $sformatf(
        "COVERAGE SAMPLE: OP=%s WAIT=%0d PSLVERR=%0b COVERAGE=%0.2f%%",
        cov_write ? "WRITE" : "READ",
        cov_wait_cycles,
        cov_slverr,
        apb_cg.get_inst_coverage()),
      UVM_LOW)

  endfunction : write

  //----------------------------------------------------------
  // Report Phase
  //----------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
              "COVERAGE REPORT PHASE EXECUTED",
              UVM_LOW)

    `uvm_info(get_type_name(),
      "==============================================",
      UVM_NONE)

    `uvm_info(get_type_name(),
      "       AXI2APB FUNCTIONAL COVERAGE REPORT       ",
      UVM_NONE)

    `uvm_info(get_type_name(),
      "==============================================",
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("TOTAL APB SAMPLES     = %0d",
                total_samples),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("IMMEDIATE READ        = %0d",
                immediate_read_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("IMMEDIATE WRITE       = %0d",
                immediate_write_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("READ WITH WAIT        = %0d",
                read_wait_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("WRITE WITH WAIT       = %0d",
                write_wait_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("READ PSLVERR          = %0d",
                read_slverr_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("WRITE PSLVERR         = %0d",
                write_slverr_count),
      UVM_NONE)

    `uvm_info(get_type_name(),
      $sformatf("FUNCTIONAL COVERAGE   = %0.2f%%",
                apb_cg.get_inst_coverage()),
      UVM_NONE)

    `uvm_info(get_type_name(),
      "==============================================",
      UVM_NONE)

  endfunction : report_phase

endclass : axi2apb_coverage

`endif