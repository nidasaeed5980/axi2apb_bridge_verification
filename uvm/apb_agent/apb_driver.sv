`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_seq_item);

  `uvm_component_utils(apb_driver)

  virtual apb_if vif;
  apb_seq_item req;

  function new(string name = "apb_driver",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "APB DRIVER BUILD PHASE", UVM_LOW)

    if (!uvm_config_db#(virtual apb_if)::get(
          this, "", "apb_vif", vif))
      `uvm_fatal(get_type_name(), "APB Interface Not Found")
  endfunction

  virtual task run_phase(uvm_phase phase);

    `uvm_info(get_type_name(), "APB DRIVER RUN PHASE", UVM_LOW)

    vif.PREADY  = 0;
    vif.PRDATA  = 0;
    vif.PSLVERR = 0;

    forever begin

      wait (vif.PRESETn === 1'b1);

      seq_item_port.get_next_item(req);

      drive_transfer(req);

      seq_item_port.item_done();

    end

  endtask

  virtual task drive_transfer(apb_seq_item tr);

    int unsigned count;

    count = 0;

    // Wait for APB SETUP phase
    do begin
      @(posedge vif.PCLK);
    end while (!(vif.PSEL === 1'b1 &&
                 vif.PENABLE === 1'b0));

    tr.addr  = vif.PADDR;
    tr.wdata = vif.PWDATA;
    tr.write = vif.PWRITE;

    `uvm_info(get_type_name(),
      $sformatf("APB SETUP ADDR=%h WAIT=%0d",
                tr.addr, tr.wait_cycles),
      UVM_MEDIUM)

    // Prepare response before ACCESS
    @(negedge vif.PCLK);

    vif.PRDATA  = tr.rdata;
    vif.PSLVERR = tr.slverr;

    if (tr.wait_cycles == 0)
      vif.PREADY = 1;
    else
      vif.PREADY = 0;

    // Wait for ACCESS
    do begin
      @(posedge vif.PCLK);
    end while (!(vif.PSEL === 1'b1 &&
                 vif.PENABLE === 1'b1));

    // Insert configured wait states
    repeat (tr.wait_cycles) begin

      count++;

      @(negedge vif.PCLK);
      if (count == tr.wait_cycles)
        vif.PREADY = 1;

      @(posedge vif.PCLK);

    end

    if (vif.PSEL === 1'b1 &&
        vif.PENABLE === 1'b1 &&
        vif.PREADY === 1'b1) begin

      `uvm_info(get_type_name(),
        $sformatf("APB COMPLETE ADDR=%h WAIT=%0d",
                  tr.addr, count),
        UVM_MEDIUM)

    end
    else begin

      `uvm_error(get_type_name(), "APB HANDSHAKE FAILED")

    end

    // Clear response after transfer
    @(negedge vif.PCLK);

    vif.PREADY  = 0;
    vif.PSLVERR = 0;

  endtask

endclass : apb_driver

`endif