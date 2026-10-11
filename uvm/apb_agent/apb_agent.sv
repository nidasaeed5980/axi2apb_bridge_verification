`ifndef APB_AGENT_SV
`define APB_AGENT_SV

//--------------------------------------------------
// APB AGENT
//--------------------------------------------------
class apb_agent extends uvm_agent;

  //--------------------------------------------------
  // UVM Factory Registration
  //--------------------------------------------------
  `uvm_component_utils(apb_agent)

  //--------------------------------------------------
  // Component Handles
  //--------------------------------------------------
  apb_sequencer seqr;
  apb_driver    drv;
  apb_monitor   mon;

  //--------------------------------------------------
  // Constructor
  //--------------------------------------------------
  function new(string name = "apb_agent",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //--------------------------------------------------
  // Build Phase
  //--------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "APB Agent Build Phase Executed",
              UVM_LOW)

    //------------------------------------------------
    // Create APB Monitor
    // Monitor is required in ACTIVE and PASSIVE modes
    //------------------------------------------------
    mon = apb_monitor::type_id::create("mon", this);

    //------------------------------------------------
    // Create Driver and Sequencer for ACTIVE Agent
    //------------------------------------------------
    if (get_is_active() == UVM_ACTIVE) begin

      seqr = apb_sequencer::type_id::create("seqr", this);

      drv = apb_driver::type_id::create("drv", this);

      `uvm_info(get_type_name(),
                "APB Agent Configured as ACTIVE",
                UVM_LOW)

    end
    else begin

      `uvm_info(get_type_name(),
                "APB Agent Configured as PASSIVE",
                UVM_LOW)

    end

  endfunction : build_phase

  //--------------------------------------------------
  // Connect Phase
  //--------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info(get_type_name(),
              "APB Agent Connect Phase Executed",
              UVM_LOW)

    //------------------------------------------------
    // Connect APB Driver to APB Sequencer
    //------------------------------------------------
    if (get_is_active() == UVM_ACTIVE) begin

      drv.seq_item_port.connect(seqr.seq_item_export);

      `uvm_info(get_type_name(),
                "APB Driver Connected to APB Sequencer",
                UVM_LOW)

    end

  endfunction : connect_phase

endclass : apb_agent

`endif