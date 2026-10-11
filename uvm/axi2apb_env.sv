`ifndef AXI2APB_ENV_SV
`define AXI2APB_ENV_SV

//============================================================
// AXI2APB UVM ENVIRONMENT
//
// Components:
//   1. AXI Agent
//   2. APB Agent
//   3. AXI2APB Scoreboard
//   4. AXI2APB Virtual Sequencer
//
// Connections:
//   AXI Monitor --> Scoreboard AXI Analysis Imp
//   APB Monitor --> Scoreboard APB Analysis Imp
//
//   Virtual Sequencer --> AXI Sequencer
//   Virtual Sequencer --> APB Sequencer
//============================================================

class axi2apb_env extends uvm_env;

  //----------------------------------------------------------
  // UVM Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_env)

  //----------------------------------------------------------
  // Component Handles
  //----------------------------------------------------------

  // AXI Agent
  axi_agent axi_agt;

  // APB Agent
  apb_agent apb_agt;

  // Scoreboard
  axi2apb_scoreboard scb;

  // Virtual Sequencer
  axi2apb_virtual_sequencer vseqr;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_env",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Environment Build Phase Executed",
              UVM_LOW)

    //--------------------------------------------------------
    // Configure Both Agents as ACTIVE
    //--------------------------------------------------------
    uvm_config_db#(uvm_active_passive_enum)::set(
      this,
      "axi_agt",
      "is_active",
      UVM_ACTIVE
    );

    uvm_config_db#(uvm_active_passive_enum)::set(
      this,
      "apb_agt",
      "is_active",
      UVM_ACTIVE
    );

    //--------------------------------------------------------
    // Create AXI Agent
    //--------------------------------------------------------
    axi_agt = axi_agent::type_id::create(
      "axi_agt", this
    );

    `uvm_info(get_type_name(),
              "AXI Agent Created Successfully",
              UVM_LOW)

    //--------------------------------------------------------
    // Create APB Agent
    //--------------------------------------------------------
    apb_agt = apb_agent::type_id::create(
      "apb_agt", this
    );

    `uvm_info(get_type_name(),
              "APB Agent Created Successfully",
              UVM_LOW)

    //--------------------------------------------------------
    // Create Scoreboard
    //--------------------------------------------------------
    scb = axi2apb_scoreboard::type_id::create(
      "scb", this
    );

    `uvm_info(get_type_name(),
              "AXI2APB Scoreboard Created Successfully",
              UVM_LOW)

    //--------------------------------------------------------
    // Create Virtual Sequencer
    //--------------------------------------------------------
    vseqr = axi2apb_virtual_sequencer::type_id::create(
      "vseqr", this
    );

    `uvm_info(get_type_name(),
              "AXI2APB Virtual Sequencer Created Successfully",
              UVM_LOW)

  endfunction : build_phase

  //----------------------------------------------------------
  // Connect Phase
  //----------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Environment Connect Phase Executed",
              UVM_LOW)

    //--------------------------------------------------------
    // Check Component Handles
    //--------------------------------------------------------
    if (axi_agt == null)
      `uvm_fatal(get_type_name(), "AXI Agent is NULL")

    if (apb_agt == null)
      `uvm_fatal(get_type_name(), "APB Agent is NULL")

    if (scb == null)
      `uvm_fatal(get_type_name(), "Scoreboard is NULL")

    if (vseqr == null)
      `uvm_fatal(get_type_name(), "Virtual Sequencer is NULL")

    //--------------------------------------------------------
    // Connect AXI Monitor to Scoreboard
    //--------------------------------------------------------
    if (axi_agt.mon == null)
      `uvm_fatal(get_type_name(), "AXI Monitor is NULL")

    axi_agt.mon.ap.connect(scb.axi_imp);

    `uvm_info(get_type_name(),
              "AXI Monitor Connected to Scoreboard",
              UVM_LOW)

    //--------------------------------------------------------
    // Connect APB Monitor to Scoreboard
    //--------------------------------------------------------
    if (apb_agt.mon == null)
      `uvm_fatal(get_type_name(), "APB Monitor is NULL")

    apb_agt.mon.ap.connect(scb.apb_imp);

    `uvm_info(get_type_name(),
              "APB Monitor Connected to Scoreboard",
              UVM_LOW)

    //--------------------------------------------------------
    // Connect AXI Sequencer to Virtual Sequencer
    //--------------------------------------------------------
    if (axi_agt.seqr == null)
      `uvm_fatal(get_type_name(), "AXI Sequencer is NULL")

    vseqr.axi_seqr = axi_agt.seqr;

    `uvm_info(get_type_name(),
              "AXI Sequencer Connected to Virtual Sequencer",
              UVM_LOW)

    //--------------------------------------------------------
    // Connect APB Sequencer to Virtual Sequencer
    //--------------------------------------------------------
    if (apb_agt.seqr == null)
      `uvm_fatal(get_type_name(), "APB Sequencer is NULL")

    vseqr.apb_seqr = apb_agt.seqr;

    `uvm_info(get_type_name(),
              "APB Sequencer Connected to Virtual Sequencer",
              UVM_LOW)

    //--------------------------------------------------------
    // Final Connection Confirmation
    //--------------------------------------------------------
    `uvm_info(get_type_name(),
              "All AXI2APB Environment Connections Completed",
              UVM_LOW)

  endfunction : connect_phase

endclass : axi2apb_env

`endif