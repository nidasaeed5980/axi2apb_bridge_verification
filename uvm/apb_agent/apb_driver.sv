`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

//------------------------------------------------------------
// APB SLAVE DRIVER
//------------------------------------------------------------

class apb_driver extends uvm_driver #(apb_seq_item);

  `uvm_component_utils(apb_driver)

  virtual apb_if vif;

  apb_seq_item req;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "apb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "APB Driver Build Phase Executed",
              UVM_LOW)

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "apb_vif", vif))
      `uvm_fatal(get_type_name(),
                 "APB Virtual Interface Not Found")

  endfunction : build_phase

  //----------------------------------------------------------
  // Run Phase
  //----------------------------------------------------------
  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(),
              "APB Driver Run Phase Executed",
              UVM_LOW)

    initialize_signals();

    forever begin

      wait (vif.PRESETn === 1'b1);

      seq_item_port.get_next_item(req);

      `uvm_info(get_type_name(),
        $sformatf(
          "APB Response Config Received: RDATA=%h WAIT=%0d PSLVERR=%b",
          req.rdata, req.wait_cycles, req.slverr),
        UVM_MEDIUM)

      fork

        begin : transfer_thread
          drive_transfer(req);
        end

        begin : reset_thread
          @(negedge vif.PRESETn);

          `uvm_info(get_type_name(),
                    "APB Reset Detected - Transfer Aborted",
                    UVM_MEDIUM)
        end

      join_any

      disable fork;

      initialize_signals();

      seq_item_port.item_done();

    end

  endtask : run_phase

  //----------------------------------------------------------
  // Initialize Slave Outputs
  //----------------------------------------------------------
  virtual task initialize_signals();

    vif.PREADY  = 1'b0;
    vif.PRDATA  = '0;
    vif.PSLVERR = 1'b0;

    `uvm_info(get_type_name(),
              "APB Slave Signals Initialized",
              UVM_LOW)

  endtask : initialize_signals

  //----------------------------------------------------------
  // Drive APB Transfer
  //----------------------------------------------------------
  virtual task drive_transfer(apb_seq_item tr);

    int unsigned wait_count;

    wait_count = 0;

    //--------------------------------------------------------
    // Wait for SETUP phase
    //--------------------------------------------------------
    do begin
      @(negedge vif.PCLK);
    end while (!(vif.PSEL === 1'b1 &&
                 vif.PENABLE === 1'b0));

    //--------------------------------------------------------
    // Capture APB request
    //--------------------------------------------------------
    tr.addr  = vif.PADDR;
    tr.wdata = vif.PWDATA;
    tr.write = vif.PWRITE;

    `uvm_info(get_type_name(),
      $sformatf(
        "APB SETUP Detected: ADDR=%h WRITE=%b WDATA=%h",
        tr.addr, tr.write, tr.wdata),
      UVM_MEDIUM)

    //--------------------------------------------------------
    // Prepare response during SETUP
    //--------------------------------------------------------
    vif.PRDATA  = tr.rdata;
    vif.PSLVERR = tr.slverr;

    if (tr.wait_cycles == 0)
      vif.PREADY = 1'b1;
    else
      vif.PREADY = 1'b0;

    //--------------------------------------------------------
    // Wait for ACCESS phase
    //--------------------------------------------------------
    do begin
      @(posedge vif.PCLK);
    end while (!(vif.PSEL === 1'b1 &&
                 vif.PENABLE === 1'b1));

    //--------------------------------------------------------
    // Count requested wait cycles
    //--------------------------------------------------------
    while (wait_count < tr.wait_cycles) begin

      wait_count++;

      `uvm_info(get_type_name(),
        $sformatf(
          "APB Wait State %0d/%0d",
          wait_count, tr.wait_cycles),
        UVM_MEDIUM)

      @(negedge vif.PCLK);

      if (wait_count == tr.wait_cycles)
        vif.PREADY = 1'b1;

      @(posedge vif.PCLK);

    end

    //--------------------------------------------------------
    // Wait for handshake
    //--------------------------------------------------------
    if (tr.wait_cycles == 0) begin

      // First ACCESS posedge already reached.
      // PREADY was asserted during SETUP.

    end
    else begin

      // Last ACCESS posedge reached with PREADY asserted.

    end

    if (!(vif.PSEL === 1'b1 &&
          vif.PENABLE === 1'b1 &&
          vif.PREADY === 1'b1))
      `uvm_error(get_type_name(),
                 "APB HANDSHAKE NOT DETECTED")

    else
      `uvm_info(get_type_name(),
        $sformatf(
          "APB Transfer Completed: ADDR=%h WRITE=%b RDATA=%h PSLVERR=%b WAIT=%0d",
          tr.addr,
          tr.write,
          tr.rdata,
          tr.slverr,
          wait_count),
        UVM_MEDIUM)

    //--------------------------------------------------------
    // Return outputs to idle after handshake
    //--------------------------------------------------------
    @(negedge vif.PCLK);

    vif.PREADY  = 1'b0;
    vif.PSLVERR = 1'b0;

  endtask : drive_transfer

endclass : apb_driver

`endif
