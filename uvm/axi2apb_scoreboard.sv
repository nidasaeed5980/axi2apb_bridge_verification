`ifndef AXI2APB_SCOREBOARD_SV
`define AXI2APB_SCOREBOARD_SV

//------------------------------------------------------------
// AXI2APB SCOREBOARD
//
// - Receives completed AXI transactions
// - Receives completed APB transactions
// - Compares address, direction, write/read data
// - Checks AXI response IDs and response codes
// - Observes APB wait states and PSLVERR
// - Detects missing or unmatched transactions
// - Prints PASS/FAIL summary
//
// IMPORTANT:
// AXI and APB monitor callbacks can arrive in either order.
// Separate queues are used to pair completed transactions.
//------------------------------------------------------------

// Two different analysis implementation types
`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_apb)

class axi2apb_scoreboard extends uvm_scoreboard;

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_scoreboard)

  //----------------------------------------------------------
  // Analysis Implementation Ports
  //----------------------------------------------------------
  uvm_analysis_imp_axi #(axi_seq_item, axi2apb_scoreboard) axi_imp;
  uvm_analysis_imp_apb #(apb_seq_item, axi2apb_scoreboard) apb_imp;

  //----------------------------------------------------------
  // Transaction Queues
  //----------------------------------------------------------
  axi_seq_item axi_read_q[$];
  axi_seq_item axi_write_q[$];

  apb_seq_item apb_read_q[$];
  apb_seq_item apb_write_q[$];

  //----------------------------------------------------------
  // Counters
  //----------------------------------------------------------
  int unsigned pass_count;
  int unsigned fail_count;

  int unsigned axi_read_count;
  int unsigned axi_write_count;
  int unsigned apb_read_count;
  int unsigned apb_write_count;

  int unsigned apb_wait_count;
  int unsigned pslverr_count;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_scoreboard",
               uvm_component parent = null);

    super.new(name, parent);

    pass_count       = 0;
    fail_count       = 0;

    axi_read_count   = 0;
    axi_write_count  = 0;
    apb_read_count   = 0;
    apb_write_count  = 0;

    apb_wait_count   = 0;
    pslverr_count    = 0;

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Scoreboard Build Phase Executed",
              UVM_LOW)

    axi_imp = new("axi_imp", this);
    apb_imp = new("apb_imp", this);

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
              "AXI2APB Scoreboard Run Phase Executed",
              UVM_LOW)

  endtask : run_phase

  //----------------------------------------------------------
  // AXI Monitor Callback
  //----------------------------------------------------------
  virtual function void write_axi(axi_seq_item tr);

    axi_seq_item copy_tr;

    copy_tr = axi_seq_item::type_id::create("axi_copy");

    copy_tr.copy(tr);

    if (copy_tr.op == AXI_READ) begin

      axi_read_count++;
      axi_read_q.push_back(copy_tr);

      `uvm_info(get_type_name(),
        $sformatf(
          "AXI READ Received ADDR=%h RDATA=%h ID=%h",
          copy_tr.addr, copy_tr.rdata, copy_tr.id),
        UVM_MEDIUM)

    end
    else if (copy_tr.op == AXI_WRITE) begin

      axi_write_count++;
      axi_write_q.push_back(copy_tr);

      `uvm_info(get_type_name(),
        $sformatf(
          "AXI WRITE Received ADDR=%h WDATA=%h ID=%h",
          copy_tr.addr, copy_tr.data, copy_tr.id),
        UVM_MEDIUM)

    end
    else begin

      fail_count++;

      `uvm_error(get_type_name(),
                 "Unknown AXI Transaction Type")

    end

    compare_transactions();

  endfunction : write_axi

  //----------------------------------------------------------
  // APB Monitor Callback
  //----------------------------------------------------------
  virtual function void write_apb(apb_seq_item tr);

    apb_seq_item copy_tr;

    copy_tr = apb_seq_item::type_id::create("apb_copy");

    copy_tr.copy(tr);

    if (copy_tr.write == 1'b1) begin

      apb_write_count++;
      apb_write_q.push_back(copy_tr);

      `uvm_info(get_type_name(),
        $sformatf(
          "APB WRITE Received ADDR=%h WDATA=%h WAIT=%0d",
          copy_tr.addr, copy_tr.wdata, copy_tr.wait_cycles),
        UVM_MEDIUM)

    end
    else begin

      apb_read_count++;
      apb_read_q.push_back(copy_tr);

      `uvm_info(get_type_name(),
        $sformatf(
          "APB READ Received ADDR=%h RDATA=%h WAIT=%0d",
          copy_tr.addr, copy_tr.rdata, copy_tr.wait_cycles),
        UVM_MEDIUM)

    end

    if (copy_tr.wait_cycles > 0)
      apb_wait_count++;

    if (copy_tr.slverr == 1'b1) begin

      pslverr_count++;

      `uvm_info(get_type_name(),
        $sformatf(
          "APB PSLVERR Observed ADDR=%h WRITE=%b",
          copy_tr.addr, copy_tr.write),
        UVM_MEDIUM)

    end

    compare_transactions();

  endfunction : write_apb

  //----------------------------------------------------------
  // Compare Completed AXI and APB Transactions
  //----------------------------------------------------------
  virtual function void compare_transactions();

    axi_seq_item axi_tr;
    apb_seq_item apb_tr;

    bit match_ok;

    //--------------------------------------------------------
    // Compare WRITES
    //--------------------------------------------------------
    while (axi_write_q.size() > 0 &&
           apb_write_q.size() > 0) begin

      axi_tr = axi_write_q.pop_front();
      apb_tr = apb_write_q.pop_front();

      match_ok = 1'b1;

      if (axi_tr.addr !== apb_tr.addr) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "WRITE ADDRESS MISMATCH AXI=%h APB=%h",
            axi_tr.addr, apb_tr.addr))

      end

      if (axi_tr.data !== apb_tr.wdata) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "WRITE DATA MISMATCH AXI=%h APB=%h",
            axi_tr.data, apb_tr.wdata))

      end

      if (axi_tr.resp_id !== axi_tr.id) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "WRITE RESPONSE ID MISMATCH Expected=%h Actual=%h",
            axi_tr.id, axi_tr.resp_id))

      end

      // Actual DUT behavior: BRESP remains OKAY.
      if (axi_tr.resp !== 2'b00) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "WRITE RESPONSE MISMATCH BRESP=%b",
            axi_tr.resp))

      end

      if (match_ok) begin

        pass_count++;

        `uvm_info(get_type_name(),
          $sformatf(
            "SCOREBOARD PASS: AXI WRITE ADDR=%h DATA=%h",
            axi_tr.addr, axi_tr.data),
          UVM_LOW)

      end
      else begin

        fail_count++;

        `uvm_error(get_type_name(),
          $sformatf(
            "SCOREBOARD FAIL: AXI WRITE ADDR=%h",
            axi_tr.addr))

      end

    end

    //--------------------------------------------------------
    // Compare READS
    //--------------------------------------------------------
    while (axi_read_q.size() > 0 &&
           apb_read_q.size() > 0) begin

      axi_tr = axi_read_q.pop_front();
      apb_tr = apb_read_q.pop_front();

      match_ok = 1'b1;

      if (axi_tr.addr !== apb_tr.addr) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "READ ADDRESS MISMATCH AXI=%h APB=%h",
            axi_tr.addr, apb_tr.addr))

      end

      if (axi_tr.rdata !== apb_tr.rdata) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "READ DATA MISMATCH AXI=%h APB=%h",
            axi_tr.rdata, apb_tr.rdata))

      end

      if (axi_tr.resp_id !== axi_tr.id) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "READ RESPONSE ID MISMATCH Expected=%h Actual=%h",
            axi_tr.id, axi_tr.resp_id))

      end

      // Actual DUT behavior: RRESP remains OKAY.
      if (axi_tr.resp !== 2'b00) begin

        match_ok = 1'b0;

        `uvm_error(get_type_name(),
          $sformatf(
            "READ RESPONSE MISMATCH RRESP=%b",
            axi_tr.resp))

      end

      if (match_ok) begin

        pass_count++;

        `uvm_info(get_type_name(),
          $sformatf(
            "SCOREBOARD PASS: AXI READ ADDR=%h DATA=%h",
            axi_tr.addr, axi_tr.rdata),
          UVM_LOW)

      end
      else begin

        fail_count++;

        `uvm_error(get_type_name(),
          $sformatf(
            "SCOREBOARD FAIL: AXI READ ADDR=%h",
            axi_tr.addr))

      end

    end

  endfunction : compare_transactions

  //----------------------------------------------------------
  // Report Phase
  //----------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Scoreboard Report Phase Executed",
              UVM_LOW)

    //--------------------------------------------------------
    // Detect unmatched completed transactions
    //--------------------------------------------------------
    if (axi_read_q.size()  != 0 ||
        axi_write_q.size() != 0 ||
        apb_read_q.size()  != 0 ||
        apb_write_q.size() != 0) begin

      fail_count++;

      `uvm_error(get_type_name(),
        $sformatf(
          "UNMATCHED TRANSACTIONS: AXI_RD=%0d AXI_WR=%0d APB_RD=%0d APB_WR=%0d",
          axi_read_q.size(),
          axi_write_q.size(),
          apb_read_q.size(),
          apb_write_q.size()))

    end

    //--------------------------------------------------------
    // Detect AXI/APB transaction-count mismatches
    //--------------------------------------------------------
    if (axi_read_count != apb_read_count ||
        axi_write_count != apb_write_count) begin

      fail_count++;

      `uvm_error(get_type_name(),
        $sformatf(
          "TRANSACTION COUNT MISMATCH AXI_RD=%0d APB_RD=%0d AXI_WR=%0d APB_WR=%0d",
          axi_read_count,
          apb_read_count,
          axi_write_count,
          apb_write_count))

    end

    //--------------------------------------------------------
    // Final Summary
    //--------------------------------------------------------
    `uvm_info(get_type_name(),
      $sformatf(
        "\n==================================================\n"
        // String concatenation continues below
        ),
      UVM_LOW)

    $display("==================================================");
    $display("          AXI2APB SCOREBOARD REPORT");
    $display("==================================================");
    $display("AXI READ Transactions   = %0d", axi_read_count);
    $display("AXI WRITE Transactions  = %0d", axi_write_count);
    $display("APB READ Transactions   = %0d", apb_read_count);
    $display("APB WRITE Transactions  = %0d", apb_write_count);
    $display("APB Transfers With Wait = %0d", apb_wait_count);
    $display("APB PSLVERR Transfers   = %0d", pslverr_count);
    $display("SCOREBOARD PASS         = %0d", pass_count);
    $display("SCOREBOARD FAIL         = %0d", fail_count);
    $display("==================================================");

    if (fail_count == 0 &&
        pass_count > 0) begin

      `uvm_info(get_type_name(),
                "FINAL SCOREBOARD RESULT: PASS",
                UVM_NONE)

    end
    else begin

      `uvm_error(get_type_name(),
                 "FINAL SCOREBOARD RESULT: FAIL")

    end

  endfunction : report_phase

endclass : axi2apb_scoreboard

`endif