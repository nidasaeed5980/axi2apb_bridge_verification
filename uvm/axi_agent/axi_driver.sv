`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV

//------------------------------------------------------------
// AXI MASTER DRIVER
//
// Features:
// 1. Single AXI read/write
// 2. Independent read and write execution
// 3. Concurrent AR and AW/W requests
// 4. Parallel AW and W channels
// 5. APB wait-state tolerance
// 6. Delayed RREADY and BREADY after VALID
// 7. Back-to-back transactions
// 8. Mixed read/write traffic
// 9. Different IDs and USER values
// 10. Reset during active transactions
//
// DUT supports single-beat AXI transactions.
//------------------------------------------------------------

class axi_driver extends uvm_driver #(axi_seq_item);

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi_driver)

  //----------------------------------------------------------
  // Virtual Interface
  //----------------------------------------------------------
  virtual axi_if vif;

  //----------------------------------------------------------
  // Transaction Handle
  //----------------------------------------------------------
  axi_seq_item req;

  //----------------------------------------------------------
  // Channel Busy Flags
  //----------------------------------------------------------
  bit read_busy;
  bit write_busy;

  //----------------------------------------------------------
  // Reset Generation Counter
  //----------------------------------------------------------
  int unsigned reset_generation;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi_driver",
               uvm_component parent = null);

    super.new(name, parent);

    read_busy        = 0;
    write_busy       = 0;
    reset_generation = 0;

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Driver Build Phase Executed",
              UVM_LOW)

    if (!uvm_config_db#(virtual axi_if)::get(
          this, "", "axi_vif", vif)) begin

      `uvm_fatal(get_type_name(),
                 "AXI Virtual Interface Not Found")

    end

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
              "AXI Driver Run Phase Executed",
              UVM_LOW)

    initialize_signals();

    fork

      dispatch_transactions();

      monitor_reset();

    join

  endtask : run_phase

  //----------------------------------------------------------
  // Initialize AXI Master Signals
  //----------------------------------------------------------
  virtual task initialize_signals();

    vif.AWID     = '0;
    vif.AWADDR   = '0;
    vif.AWLEN    = '0;
    vif.AWSIZE   = '0;
    vif.AWBURST  = '0;
    vif.AWLOCK   = '0;
    vif.AWCACHE  = '0;
    vif.AWPROT   = '0;
    vif.AWREGION = '0;
    vif.AWUSER   = '0;
    vif.AWQOS    = '0;
    vif.AWVALID  = 1'b0;

    vif.WDATA    = '0;
    vif.WSTRB    = '0;
    vif.WLAST    = 1'b0;
    vif.WUSER    = '0;
    vif.WVALID   = 1'b0;

    vif.BREADY   = 1'b0;

    vif.ARID     = '0;
    vif.ARADDR   = '0;
    vif.ARLEN    = '0;
    vif.ARSIZE   = '0;
    vif.ARBURST  = '0;
    vif.ARLOCK   = '0;
    vif.ARCACHE  = '0;
    vif.ARPROT   = '0;
    vif.ARREGION = '0;
    vif.ARUSER   = '0;
    vif.ARQOS    = '0;
    vif.ARVALID  = 1'b0;

    vif.RREADY   = 1'b0;

    `uvm_info(get_type_name(),
              "AXI Master Signals Initialized",
              UVM_LOW)

  endtask : initialize_signals

  //----------------------------------------------------------
  // Reset Monitor
  //----------------------------------------------------------
  virtual task monitor_reset();

    forever begin

      @(negedge vif.ARESETn);

      reset_generation++;

      `uvm_info(get_type_name(),
                "AXI Reset Asserted - Aborting Active Transactions",
                UVM_MEDIUM)

      initialize_signals();

      wait (vif.ARESETn === 1'b1);

      `uvm_info(get_type_name(),
                "AXI Reset Deasserted",
                UVM_MEDIUM)

    end

  endtask : monitor_reset

  //----------------------------------------------------------
  // Transaction Dispatcher
  //----------------------------------------------------------
  virtual task dispatch_transactions();

    axi_seq_item pending_tr;
    axi_seq_item worker_tr;
    int unsigned worker_generation;

    forever begin

      wait (vif.ARESETn === 1'b1);

      seq_item_port.get_next_item(pending_tr);

      if (pending_tr.op == AXI_READ) begin

        wait ((read_busy == 0) ||
              (vif.ARESETn !== 1'b1));

      end
      else if (pending_tr.op == AXI_WRITE) begin

        wait ((write_busy == 0) ||
              (vif.ARESETn !== 1'b1));

      end
      else begin

        `uvm_error(get_type_name(),
                   "Unknown AXI Operation")

        seq_item_port.item_done();
        continue;

      end

      wait (vif.ARESETn === 1'b1);

      if (pending_tr.op == AXI_READ) begin

        wait (read_busy == 0);
        read_busy = 1;

      end
      else if (pending_tr.op == AXI_WRITE) begin

        wait (write_busy == 0);
        write_busy = 1;

      end

      worker_tr         = pending_tr;
      worker_generation = reset_generation;

      `uvm_info(get_type_name(),
        $sformatf("Dispatching AXI Transaction OP=%s ADDR=%h",
                  worker_tr.op.name(), worker_tr.addr),
        UVM_MEDIUM)

      fork
        begin
          automatic axi_seq_item tr = worker_tr;
          automatic int unsigned gen = worker_generation;

          execute_transaction(tr, gen);
        end
      join_none

      // Item accepted; worker completes transaction independently.
      seq_item_port.item_done();

    end

  endtask : dispatch_transactions

  //----------------------------------------------------------
  // Execute Transaction
  //----------------------------------------------------------
  virtual task execute_transaction(
      axi_seq_item tr,
      int unsigned gen
  );

    bit completed;

    completed = 0;

    fork

      begin : transaction_thread

        case (tr.op)

          AXI_WRITE: drive_write(tr, gen);

          AXI_READ: drive_read(tr, gen);

          default: begin
            `uvm_error(get_type_name(),
                       "Invalid AXI Operation")
          end

        endcase

        completed = 1;

      end

      begin : reset_abort_thread

        wait ((vif.ARESETn !== 1'b1) ||
              (reset_generation != gen));

      end

    join_any

    disable fork;

    if (!completed) begin

      `uvm_info(get_type_name(),
        $sformatf("AXI Transaction Aborted by Reset ADDR=%h",
                  tr.addr),
        UVM_MEDIUM)

    end

    if (tr.op == AXI_READ)
      read_busy = 0;

    else if (tr.op == AXI_WRITE)
      write_busy = 0;

  endtask : execute_transaction

  //----------------------------------------------------------
  // AXI WRITE TRANSACTION
  //----------------------------------------------------------
  virtual task drive_write(
      axi_seq_item tr,
      int unsigned gen
  );

    `uvm_info(get_type_name(),
      $sformatf("AXI WRITE START ADDR=%h DATA=%h ID=%h USER=%h",
                tr.addr, tr.data, tr.id, tr.user),
      UVM_MEDIUM)

    //--------------------------------------------------------
    // AW and W Channels Run in Parallel
    //--------------------------------------------------------
    fork

      begin : aw_channel

        repeat (tr.aw_delay)
          @(negedge vif.ACLK);

        @(negedge vif.ACLK);

        vif.AWID     = tr.id;
        vif.AWADDR   = tr.addr;
        vif.AWLEN    = 8'd0;
        vif.AWSIZE   = 3'd2;
        vif.AWBURST  = 2'b01;
        vif.AWLOCK   = '0;
        vif.AWCACHE  = '0;
        vif.AWPROT   = '0;
        vif.AWREGION = '0;
        vif.AWUSER   = tr.user;
        vif.AWQOS    = '0;
        vif.AWVALID  = 1'b1;

        do begin
          @(posedge vif.ACLK);
        end while (vif.AWREADY !== 1'b1);

        @(negedge vif.ACLK);
        vif.AWVALID = 1'b0;

        `uvm_info(get_type_name(),
                  "AXI AW Handshake Completed",
                  UVM_MEDIUM)

      end

      begin : w_channel

        repeat (tr.w_delay)
          @(negedge vif.ACLK);

        @(negedge vif.ACLK);

        vif.WDATA  = tr.data;
        vif.WSTRB  = tr.strb;
        vif.WLAST  = 1'b1;
        vif.WUSER  = tr.user;
        vif.WVALID = 1'b1;

        do begin
          @(posedge vif.ACLK);
        end while (vif.WREADY !== 1'b1);

        @(negedge vif.ACLK);
        vif.WVALID = 1'b0;

        `uvm_info(get_type_name(),
                  "AXI W Handshake Completed",
                  UVM_MEDIUM)

      end

    join

    //--------------------------------------------------------
    // B Response Channel
    //
    // FIX:
    // First observe BVALID.
    // Then delay BREADY for resp_ready_delay cycles.
    //--------------------------------------------------------

    vif.BREADY = 1'b0;

    // Wait for DUT to present a write response.
    do begin
      @(posedge vif.ACLK);
    end while (vif.BVALID !== 1'b1);

    `uvm_info(get_type_name(),
      $sformatf("AXI BVALID Observed, BREADY Delay=%0d",
                tr.resp_ready_delay),
      UVM_MEDIUM)

    // Apply backpressure while DUT holds BVALID.
    repeat (tr.resp_ready_delay) begin

      @(posedge vif.ACLK);

      if (vif.BVALID !== 1'b1) begin

        `uvm_error(get_type_name(),
                   "BVALID Dropped While BREADY Was LOW")

      end

    end

    // Drive READY away from sampling edge.
    @(negedge vif.ACLK);
    vif.BREADY = 1'b1;

    // Wait for actual B channel handshake.
    do begin
      @(posedge vif.ACLK);
    end while (vif.BVALID !== 1'b1);

    tr.resp    = vif.BRESP;
    tr.resp_id = vif.BID;

    if (tr.resp_id !== tr.id) begin

      `uvm_error(get_type_name(),
        $sformatf("WRITE ID MISMATCH Expected=%h Actual=%h",
                  tr.id, tr.resp_id))

    end

    // Current DUT specification expects OKAY.
    if (tr.resp !== 2'b00) begin

      `uvm_error(get_type_name(),
        $sformatf("WRITE RESPONSE NOT OKAY BRESP=%b",
                  tr.resp))

    end

    `uvm_info(get_type_name(),
      $sformatf("AXI WRITE COMPLETED BID=%h BRESP=%b",
                tr.resp_id, tr.resp),
      UVM_MEDIUM)

    @(negedge vif.ACLK);
    vif.BREADY = 1'b0;

  endtask : drive_write

  //----------------------------------------------------------
  // AXI READ TRANSACTION
  //----------------------------------------------------------
  virtual task drive_read(
      axi_seq_item tr,
      int unsigned gen
  );

    `uvm_info(get_type_name(),
      $sformatf("AXI READ START ADDR=%h ID=%h USER=%h",
                tr.addr, tr.id, tr.user),
      UVM_MEDIUM)

    //--------------------------------------------------------
    // AR Channel
    //--------------------------------------------------------

    @(negedge vif.ACLK);

    vif.ARID     = tr.id;
    vif.ARADDR   = tr.addr;
    vif.ARLEN    = 8'd0;
    vif.ARSIZE   = 3'd2;
    vif.ARBURST  = 2'b01;
    vif.ARLOCK   = '0;
    vif.ARCACHE  = '0;
    vif.ARPROT   = '0;
    vif.ARREGION = '0;
    vif.ARUSER   = tr.user;
    vif.ARQOS    = '0;
    vif.ARVALID  = 1'b1;

    do begin
      @(posedge vif.ACLK);
    end while (vif.ARREADY !== 1'b1);

    @(negedge vif.ACLK);
    vif.ARVALID = 1'b0;

    `uvm_info(get_type_name(),
              "AXI AR Handshake Completed",
              UVM_MEDIUM)

    //--------------------------------------------------------
    // R Response Channel
    //
    // FIX:
    // First observe RVALID.
    // Then delay RREADY for resp_ready_delay cycles.
    //--------------------------------------------------------

    vif.RREADY = 1'b0;

    // Wait for DUT to present read data.
    do begin
      @(posedge vif.ACLK);
    end while (vif.RVALID !== 1'b1);

    `uvm_info(get_type_name(),
      $sformatf("AXI RVALID Observed, RREADY Delay=%0d",
                tr.resp_ready_delay),
      UVM_MEDIUM)

    // Apply backpressure while DUT holds RVALID.
    repeat (tr.resp_ready_delay) begin

      @(posedge vif.ACLK);

      if (vif.RVALID !== 1'b1) begin

        `uvm_error(get_type_name(),
                   "RVALID Dropped While RREADY Was LOW")

      end

    end

    // Drive READY away from sampling edge.
    @(negedge vif.ACLK);
    vif.RREADY = 1'b1;

    // Wait for actual R channel handshake.
    do begin
      @(posedge vif.ACLK);
    end while (vif.RVALID !== 1'b1);

    tr.rdata   = vif.RDATA;
    tr.resp    = vif.RRESP;
    tr.resp_id = vif.RID;

    if (tr.resp_id !== tr.id) begin

      `uvm_error(get_type_name(),
        $sformatf("READ ID MISMATCH Expected=%h Actual=%h",
                  tr.id, tr.resp_id))

    end

    if (tr.resp !== 2'b00) begin

      `uvm_error(get_type_name(),
        $sformatf("READ RESPONSE NOT OKAY RRESP=%b",
                  tr.resp))

    end

    if (vif.RLAST !== 1'b1) begin

      `uvm_error(get_type_name(),
                 "RLAST NOT ASSERTED")

    end

    `uvm_info(get_type_name(),
      $sformatf("AXI READ COMPLETED RDATA=%h RID=%h RRESP=%b",
                tr.rdata, tr.resp_id, tr.resp),
      UVM_MEDIUM)

    @(negedge vif.ACLK);
    vif.RREADY = 1'b0;

  endtask : drive_read

endclass : axi_driver

`endif