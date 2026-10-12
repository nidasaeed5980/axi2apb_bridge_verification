`ifndef AXI2APB_PKG_SV
`define AXI2APB_PKG_SV

//============================================================
// AXI2APB UVM PACKAGE
//
// Verification Environment:
//   - AXI Master Agent
//   - APB Slave Agent
//   - AXI2APB Virtual Sequencer
//   - AXI2APB Virtual Sequences
//   - AXI2APB Scoreboard
//   - AXI2APB Environment
//   - Base Test
//   - 13 Directed Tests
//
// UVM Version: UVM 1.2
// Simulator: Synopsys VCS
//============================================================

package axi2apb_pkg;

  //----------------------------------------------------------
  // Import UVM Package
  //----------------------------------------------------------
  import uvm_pkg::*;

  //----------------------------------------------------------
  // Include UVM Macros
  //----------------------------------------------------------
  `include "uvm_macros.svh"


  //==========================================================
  // 1. AXI AGENT
  //==========================================================

  // AXI Transaction
  `include "axi_agent/axi_seq_item.sv"

  // AXI Sequencer
  `include "axi_agent/axi_sequencer.sv"

  // AXI Driver
  `include "axi_agent/axi_driver.sv"

  // AXI Monitor
  `include "axi_agent/axi_monitor.sv"

  // AXI Agent
  `include "axi_agent/axi_agent.sv"

  // AXI Sequences
  `include "axi_agent/axi_sequences.sv"


  //==========================================================
  // 2. APB AGENT
  //==========================================================

  // APB Transaction
  `include "apb_agent/apb_seq_item.sv"

  // APB Sequencer
  `include "apb_agent/apb_sequencer.sv"

  // APB Driver
  `include "apb_agent/apb_driver.sv"

  // APB Monitor
  `include "apb_agent/apb_monitor.sv"

  // APB Agent
  `include "apb_agent/apb_agent.sv"

  // APB Sequences
  `include "apb_agent/apb_sequences.sv"


  //==========================================================
  // 3. VIRTUAL SEQUENCER
  //==========================================================

  `include "virtual_sequencer/axi2apb_virtual_sequencer.sv"


  //==========================================================
  // 4. VIRTUAL SEQUENCES
  //==========================================================

  `include "virtual_sequencer/axi2apb_virtual_sequences.sv"


  //==========================================================
  // 5. SCOREBOARD
  //==========================================================

  `include "axi2apb_scoreboard.sv"


  //==========================================================
  // 6. ENVIRONMENT
  //==========================================================
  `include "coverage/coverage.sv"

  `include "axi2apb_env.sv"


  //==========================================================
  // 7. BASE TEST
  //==========================================================

  `include "tests/axi2apb_base_test.sv"


  //==========================================================
  // 8. ALL 13 DIRECTED TESTS
  //==========================================================

  `include "tests/axi2apb_tests.sv"


endpackage : axi2apb_pkg

`endif