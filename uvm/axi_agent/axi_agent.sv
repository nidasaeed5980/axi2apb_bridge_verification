`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV

//--------------------------------------------------
// AXI AGENT
//--------------------------------------------------
class axi_agent extends uvm_agent;

  //--------------------------------------------------
  // UVM Factory Registration
  //--------------------------------------------------
  `uvm_component_utils(axi_agent)

  //--------------------------------------------------
  // Component Handles
  //--------------------------------------------------
  axi_sequencer seqr;
  axi_driver    drv;
  axi_monitor   mon;

  //--------------------------------------------------
  // Constructor
  //--------------------------------------------------
  function new(string name = "axi_agent",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //--------------------------------------------------
  // Build Phase
  //--------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Agent Build Phase Executed",
              UVM_LOW)

    //------------------------------------------------
    // Create AXI Monitor
    // Monitor is required in active and passive modes
    //------------------------------------------------
    mon = axi_monitor::type_id::create("mon", this);

    //------------------------------------------------
    // Create Driver and Sequencer for Active Agent
    //------------------------------------------------
    if (get_is_active() == UVM_ACTIVE) begin

      seqr = axi_sequencer::type_id::create("seqr", this);

      drv = axi_driver::type_id::create("drv", this);

      `uvm_info(get_type_name(),
                "AXI Agent Configured as ACTIVE",
                UVM_LOW)

    end
    else begin

      `uvm_info(get_type_name(),
                "AXI Agent Configured as PASSIVE",
                UVM_LOW)

    end

  endfunction : build_phase

  //--------------------------------------------------
  // Connect Phase
  //--------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Agent Connect Phase Executed",
              UVM_LOW)

    //------------------------------------------------
    // Connect Driver to Sequencer
    //------------------------------------------------
    if (get_is_active() == UVM_ACTIVE) begin

      drv.seq_item_port.connect(seqr.seq_item_export);

      `uvm_info(get_type_name(),
                "AXI Driver Connected to AXI Sequencer",
                UVM_LOW)

    end

  endfunction : connect_phase

endclass : axi_agent

`endif