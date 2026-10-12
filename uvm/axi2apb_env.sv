`ifndef AXI2APB_ENV_SV
`define AXI2APB_ENV_SV

//============================================================
// AXI2APB UVM ENVIRONMENT
//
// Components:
// 1. AXI Agent
// 2. APB Agent
// 3. AXI2APB Scoreboard
// 4. AXI2APB Virtual Sequencer
// 5. AXI2APB Functional Coverage
//
// Connections:
// AXI Monitor --> Scoreboard
// APB Monitor --> Scoreboard
// APB Monitor --> Functional Coverage
// Virtual Sequencer --> AXI Sequencer
// Virtual Sequencer --> APB Sequencer
//============================================================

class axi2apb_env extends uvm_env;

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_env)

  //----------------------------------------------------------
  // Component Handles
  //----------------------------------------------------------

  axi_agent                  axi_agt;
  apb_agent                  apb_agt;
  axi2apb_scoreboard         scb;
  axi2apb_virtual_sequencer  vseqr;
  axi2apb_coverage           cov;

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
    // Configure AXI Agent as ACTIVE
    //--------------------------------------------------------
    uvm_config_db#(uvm_active_passive_enum)::set(
      this,
      "axi_agt",
      "is_active",
      UVM_ACTIVE
    );

    //--------------------------------------------------------
    // Configure APB Agent as ACTIVE
    //--------------------------------------------------------
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

    //--------------------------------------------------------
    // Create Functional Coverage
    //--------------------------------------------------------
    cov = axi2apb_coverage::type_id::create(
      "cov", this
    );

    `uvm_info(get_type_name(),
              "AXI2APB Functional Coverage Created Successfully",
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

    if (cov == null)
      `uvm_fatal(get_type_name(), "Functional Coverage is NULL")

    //--------------------------------------------------------
    // Check AXI Monitor
    //--------------------------------------------------------
    if (axi_agt.mon == null)
      `uvm_fatal(get_type_name(), "AXI Monitor is NULL")

    //--------------------------------------------------------
    // Check APB Monitor
    //--------------------------------------------------------
    if (apb_agt.mon == null)
      `uvm_fatal(get_type_name(), "APB Monitor is NULL")

    //--------------------------------------------------------
    // AXI Monitor --> Scoreboard
    //--------------------------------------------------------
    axi_agt.mon.ap.connect(scb.axi_imp);

    `uvm_info(get_type_name(),
              "AXI Monitor Connected to Scoreboard",
              UVM_LOW)

    //--------------------------------------------------------
    // APB Monitor --> Scoreboard
    //--------------------------------------------------------
    apb_agt.mon.ap.connect(scb.apb_imp);

    `uvm_info(get_type_name(),
              "APB Monitor Connected to Scoreboard",
              UVM_LOW)

    //--------------------------------------------------------
    // APB Monitor --> Functional Coverage
    //--------------------------------------------------------
    apb_agt.mon.ap.connect(cov.analysis_export);

    `uvm_info(get_type_name(),
              "APB Monitor Connected to Functional Coverage",
              UVM_LOW)

    //--------------------------------------------------------
    // Check AXI Sequencer
    //--------------------------------------------------------
    if (axi_agt.seqr == null)
      `uvm_fatal(get_type_name(), "AXI Sequencer is NULL")

    //--------------------------------------------------------
    // AXI Sequencer --> Virtual Sequencer
    //--------------------------------------------------------
    vseqr.axi_seqr = axi_agt.seqr;

    `uvm_info(get_type_name(),
              "AXI Sequencer Connected to Virtual Sequencer",
              UVM_LOW)

    //--------------------------------------------------------
    // Check APB Sequencer
    //--------------------------------------------------------
    if (apb_agt.seqr == null)
      `uvm_fatal(get_type_name(), "APB Sequencer is NULL")

    //--------------------------------------------------------
    // APB Sequencer --> Virtual Sequencer
    //--------------------------------------------------------
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