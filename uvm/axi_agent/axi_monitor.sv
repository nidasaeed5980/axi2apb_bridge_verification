`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV

//------------------------------------------------------------
// AXI MONITOR
//
// Features:
// - Monitors AXI AW, W, B, AR and R channels
// - Captures independent READ and WRITE requests
// - Supports simultaneous READ/WRITE observation
// - Captures response IDs, data and response codes
// - Observes delayed BREADY and RREADY handshakes
// - Clears pending observations on reset
// - Sends completed transactions through analysis port
//------------------------------------------------------------

class axi_monitor extends uvm_monitor;

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi_monitor)

  //----------------------------------------------------------
  // Virtual Interface
  //----------------------------------------------------------
  virtual axi_if vif;

  //----------------------------------------------------------
  // Analysis Port
  //----------------------------------------------------------
  uvm_analysis_port #(axi_seq_item) ap;

  //----------------------------------------------------------
  // Pending Write Address and Data
  //----------------------------------------------------------
  axi_seq_item aw_queue[$];
  axi_seq_item w_queue[$];

  //----------------------------------------------------------
  // Pending Read Requests
  //----------------------------------------------------------
  axi_seq_item read_queue[$];

  //----------------------------------------------------------
  // Pending Write Responses
  //----------------------------------------------------------
  axi_seq_item write_queue[$];

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi_monitor",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Monitor Build Phase Executed",
              UVM_LOW)

    ap = new("ap", this);

    if (!uvm_config_db#(virtual axi_if)::get(
          this, "", "axi_vif", vif)) begin

      `uvm_fatal(get_type_name(),
                 "AXI Monitor Virtual Interface Not Found")

    end

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
              "AXI Monitor Run Phase Executed",
              UVM_LOW)

    forever begin

      @(posedge vif.ACLK);

      if (vif.ARESETn !== 1'b1) begin

        clear_queues();

      end
      else begin

        monitor_aw();
        monitor_w();
        monitor_ar();

        pair_write_requests();

        monitor_b();
        monitor_r();

      end

    end

  endtask : run_phase

  //----------------------------------------------------------
  // Monitor AW Channel
  //----------------------------------------------------------
  virtual function void monitor_aw();

    axi_seq_item tr;

    if (vif.AWVALID === 1'b1 &&
        vif.AWREADY === 1'b1) begin

      tr = axi_seq_item::type_id::create("aw_tr");

      tr.op   = AXI_WRITE;
      tr.addr = vif.AWADDR;
      tr.id   = vif.AWID;
      tr.user = vif.AWUSER;

      aw_queue.push_back(tr);

      `uvm_info(get_type_name(),
        $sformatf("AXI AW Captured ADDR=%h ID=%h USER=%h",
                  tr.addr, tr.id, tr.user),
        UVM_MEDIUM)

    end

  endfunction : monitor_aw

  //----------------------------------------------------------
  // Monitor W Channel
  //----------------------------------------------------------
  virtual function void monitor_w();

    axi_seq_item tr;

    if (vif.WVALID === 1'b1 &&
        vif.WREADY === 1'b1) begin

      tr = axi_seq_item::type_id::create("w_tr");

      tr.op   = AXI_WRITE;
      tr.data = vif.WDATA;
      tr.strb = vif.WSTRB;

      w_queue.push_back(tr);

      if (vif.WLAST !== 1'b1) begin

        `uvm_error(get_type_name(),
                   "AXI WLAST Not Asserted")

      end

      `uvm_info(get_type_name(),
        $sformatf("AXI W Captured DATA=%h STRB=%h",
                  tr.data, tr.strb),
        UVM_MEDIUM)

    end

  endfunction : monitor_w

  //----------------------------------------------------------
  // Pair AW and W Transactions
  //----------------------------------------------------------
  virtual function void pair_write_requests();

    axi_seq_item aw_tr;
    axi_seq_item w_tr;
    axi_seq_item full_tr;

    while (aw_queue.size() > 0 &&
           w_queue.size() > 0) begin

      aw_tr = aw_queue.pop_front();
      w_tr  = w_queue.pop_front();

      full_tr = axi_seq_item::type_id::create("write_tr");

      full_tr.op   = AXI_WRITE;
      full_tr.addr = aw_tr.addr;
      full_tr.id   = aw_tr.id;
      full_tr.user = aw_tr.user;

      full_tr.data = w_tr.data;
      full_tr.strb = w_tr.strb;

      write_queue.push_back(full_tr);

      `uvm_info(get_type_name(),
        $sformatf("AXI WRITE Request Paired ADDR=%h DATA=%h",
                  full_tr.addr, full_tr.data),
        UVM_MEDIUM)

    end

  endfunction : pair_write_requests

  //----------------------------------------------------------
  // Monitor AR Channel
  //----------------------------------------------------------
  virtual function void monitor_ar();

    axi_seq_item tr;

    if (vif.ARVALID === 1'b1 &&
        vif.ARREADY === 1'b1) begin

      tr = axi_seq_item::type_id::create("read_tr");

      tr.op   = AXI_READ;
      tr.addr = vif.ARADDR;
      tr.id   = vif.ARID;
      tr.user = vif.ARUSER;

      read_queue.push_back(tr);

      `uvm_info(get_type_name(),
        $sformatf("AXI AR Captured ADDR=%h ID=%h USER=%h",
                  tr.addr, tr.id, tr.user),
        UVM_MEDIUM)

    end

  endfunction : monitor_ar

  //----------------------------------------------------------
  // Monitor B Channel
  //----------------------------------------------------------
  virtual function void monitor_b();

    axi_seq_item tr;

    if (vif.BVALID === 1'b1 &&
        vif.BREADY === 1'b1) begin

      if (write_queue.size() == 0) begin

        `uvm_error(get_type_name(),
                   "AXI B Response Without Write Request")

      end
      else begin

        tr = write_queue.pop_front();

        tr.resp    = vif.BRESP;
        tr.resp_id = vif.BID;

        if (tr.resp_id !== tr.id) begin

          `uvm_error(get_type_name(),
            $sformatf("WRITE ID MISMATCH Expected=%h Actual=%h",
                      tr.id, tr.resp_id))

        end

        ap.write(tr);

        `uvm_info(get_type_name(),
          $sformatf(
            "AXI WRITE Completed ADDR=%h DATA=%h BID=%h BRESP=%b",
            tr.addr, tr.data, tr.resp_id, tr.resp),
          UVM_MEDIUM)

      end

    end

  endfunction : monitor_b

  //----------------------------------------------------------
  // Monitor R Channel
  //----------------------------------------------------------
  virtual function void monitor_r();

    axi_seq_item tr;

    if (vif.RVALID === 1'b1 &&
        vif.RREADY === 1'b1) begin

      if (read_queue.size() == 0) begin

        `uvm_error(get_type_name(),
                   "AXI R Response Without Read Request")

      end
      else begin

        tr = read_queue.pop_front();

        tr.rdata   = vif.RDATA;
        tr.resp    = vif.RRESP;
        tr.resp_id = vif.RID;

        if (tr.resp_id !== tr.id) begin

          `uvm_error(get_type_name(),
            $sformatf("READ ID MISMATCH Expected=%h Actual=%h",
                      tr.id, tr.resp_id))

        end

        if (vif.RLAST !== 1'b1) begin

          `uvm_error(get_type_name(),
                     "AXI RLAST Not Asserted")

        end

        ap.write(tr);

        `uvm_info(get_type_name(),
          $sformatf(
            "AXI READ Completed ADDR=%h RDATA=%h RID=%h RRESP=%b",
            tr.addr, tr.rdata, tr.resp_id, tr.resp),
          UVM_MEDIUM)

      end

    end

  endfunction : monitor_r

  //----------------------------------------------------------
  // Clear Pending Transactions on Reset
  //----------------------------------------------------------
  virtual function void clear_queues();

    if (aw_queue.size()    > 0 ||
        w_queue.size()     > 0 ||
        read_queue.size()  > 0 ||
        write_queue.size() > 0) begin

      `uvm_info(get_type_name(),
                "AXI Reset: Clearing Pending Transactions",
                UVM_MEDIUM)

    end

    aw_queue.delete();
    w_queue.delete();
    read_queue.delete();
    write_queue.delete();

  endfunction : clear_queues

endclass : axi_monitor

`endif