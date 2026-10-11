`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

//------------------------------------------------------------
// APB MONITOR
//
// Features:
// - Observes APB read/write transfers
// - Captures PADDR, PWDATA, PWRITE
// - Captures PRDATA and PSLVERR
// - Counts APB wait states
// - Supports immediate PREADY
// - Handles reset during active transfers
// - Sends completed transactions to scoreboard
//------------------------------------------------------------

class apb_monitor extends uvm_monitor;

  //----------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(apb_monitor)

  //----------------------------------------------------------
  // Virtual Interface
  //----------------------------------------------------------
  virtual apb_if vif;

  //----------------------------------------------------------
  // Analysis Port
  //----------------------------------------------------------
  uvm_analysis_port #(apb_seq_item) ap;

  //----------------------------------------------------------
  // Transaction Tracking
  //----------------------------------------------------------
  apb_seq_item tr;

  bit transfer_active;
  int unsigned wait_count;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "apb_monitor",
               uvm_component parent = null);

    super.new(name, parent);

    transfer_active = 0;
    wait_count      = 0;

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "APB Monitor Build Phase Executed",
              UVM_LOW)

    ap = new("ap", this);

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "apb_vif", vif)) begin

      `uvm_fatal(get_type_name(),
                 "APB Monitor Virtual Interface Not Found")

    end

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
              "APB Monitor Run Phase Executed",
              UVM_LOW)

    forever begin

      @(posedge vif.PCLK);

      //------------------------------------------------------
      // Reset Handling
      //------------------------------------------------------
      if (vif.PRESETn !== 1'b1) begin

        if (transfer_active) begin

          `uvm_info(get_type_name(),
                    "APB Reset: Pending Transfer Discarded",
                    UVM_MEDIUM)

        end

        transfer_active = 0;
        wait_count      = 0;
        tr              = null;

      end
      else begin

        monitor_transfer();

      end

    end

  endtask : run_phase

  //----------------------------------------------------------
  // Monitor APB Transfer
  //----------------------------------------------------------
  virtual function void monitor_transfer();

    //--------------------------------------------------------
    // APB access phase
    //--------------------------------------------------------
    if (vif.PSEL === 1'b1 &&
        vif.PENABLE === 1'b1) begin

      //------------------------------------------------------
      // Capture new transfer
      //------------------------------------------------------
      if (!transfer_active) begin

        tr = apb_seq_item::type_id::create("tr");

        tr.addr  = vif.PADDR;
        tr.wdata = vif.PWDATA;
        tr.write = vif.PWRITE;

        wait_count      = 0;
        transfer_active = 1;

        `uvm_info(get_type_name(),
          $sformatf(
            "APB Transfer Detected: ADDR=%h WRITE=%b WDATA=%h",
            tr.addr, tr.write, tr.wdata),
          UVM_MEDIUM)

      end

      //------------------------------------------------------
      // APB wait-state observation
      //------------------------------------------------------
      if (vif.PREADY !== 1'b1) begin

        wait_count++;

        `uvm_info(get_type_name(),
          $sformatf(
            "APB Wait State Observed: ADDR=%h COUNT=%0d",
            tr.addr, wait_count),
          UVM_MEDIUM)

      end
      else begin

        //----------------------------------------------------
        // Completed APB handshake
        //----------------------------------------------------
        tr.rdata       = vif.PRDATA;
        tr.slverr      = vif.PSLVERR;
        tr.wait_cycles = wait_count;

        //----------------------------------------------------
        // Protocol consistency checks
        //----------------------------------------------------
        if (vif.PADDR !== tr.addr) begin

          `uvm_error(get_type_name(),
            $sformatf(
              "APB Address Changed During Transfer: OLD=%h NEW=%h",
              tr.addr, vif.PADDR))

        end

        if (vif.PWRITE !== tr.write) begin

          `uvm_error(get_type_name(),
                     "APB PWRITE Changed During Transfer")

        end

        if (tr.write && vif.PWDATA !== tr.wdata) begin

          `uvm_error(get_type_name(),
                     "APB PWDATA Changed During Write Transfer")

        end

        //----------------------------------------------------
        // Send completed transaction to scoreboard
        //----------------------------------------------------
        ap.write(tr);

        `uvm_info(get_type_name(),
          $sformatf(
            "APB TRANSFER COMPLETE: ADDR=%h WRITE=%b WDATA=%h RDATA=%h WAIT=%0d PSLVERR=%b",
            tr.addr,
            tr.write,
            tr.wdata,
            tr.rdata,
            tr.wait_cycles,
            tr.slverr),
          UVM_MEDIUM)

        //----------------------------------------------------
        // Clear tracking state
        //----------------------------------------------------
        transfer_active = 0;
        wait_count      = 0;
        tr              = null;

      end

    end
    else begin

      //------------------------------------------------------
      // Transfer interrupted before completion
      //------------------------------------------------------
      if (transfer_active) begin

        `uvm_warning(get_type_name(),
          "APB Access Phase Ended Before PREADY Handshake")

        transfer_active = 0;
        wait_count      = 0;
        tr              = null;

      end

    end

  endfunction : monitor_transfer

endclass : apb_monitor

`endif