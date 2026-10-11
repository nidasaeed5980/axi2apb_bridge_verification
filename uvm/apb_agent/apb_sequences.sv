`ifndef APB_SEQUENCES_SV
`define APB_SEQUENCES_SV

//============================================================
// APB BASE SEQUENCE
//============================================================
class apb_base_sequence extends uvm_sequence #(apb_seq_item);

  `uvm_object_utils(apb_base_sequence)

  function new(string name = "apb_base_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Base Sequence Body Executed",
              UVM_LOW)

  endtask : body

endclass : apb_base_sequence


//============================================================
// 1. APB IMMEDIATE READY SEQUENCE
//
// PREADY = 1 without programmed wait cycles.
//============================================================
class apb_immediate_ready_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_immediate_ready_sequence)

  function new(string name = "apb_immediate_ready_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Immediate Ready Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 0;
      rdata       == 32'h1234_ABCD;
    })

    `uvm_info(get_type_name(),
              "APB Immediate Ready Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_immediate_ready_sequence


//============================================================
// 2. APB WRITE WAIT STATES SEQUENCE
//
// Generates 5 APB wait cycles.
//============================================================
class apb_write_wait_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_write_wait_sequence)

  function new(string name = "apb_write_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Write Wait Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      wait_cycles == 5;
      slverr      == 0;
      rdata       == 32'h0000_0000;
    })

    `uvm_info(get_type_name(),
              "APB Write Wait Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_write_wait_sequence


//============================================================
// 3. APB READ WAIT STATES SEQUENCE
//
// Generates 5 APB wait cycles and returns read data.
//============================================================
class apb_read_wait_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_read_wait_sequence)

  function new(string name = "apb_read_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Read Wait Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      wait_cycles == 5;
      slverr      == 0;
      rdata       == 32'hDEAD_BEEF;
    })

    `uvm_info(get_type_name(),
              "APB Read Wait Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_read_wait_sequence


//============================================================
// 4. APB DELAYED RREADY SUPPORT SEQUENCE
//
// APB responds immediately.
// AXI sequence controls RREADY delay.
//============================================================
class apb_delayed_rready_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_delayed_rready_sequence)

  function new(string name = "apb_delayed_rready_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Delayed RREADY Support Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 0;
      rdata       == 32'hAABB_CCDD;
    })

    `uvm_info(get_type_name(),
              "APB Delayed RREADY Support Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_delayed_rready_sequence


//============================================================
// 5. APB DELAYED BREADY SUPPORT SEQUENCE
//
// APB responds immediately.
// AXI sequence controls BREADY delay.
//============================================================
class apb_delayed_bready_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_delayed_bready_sequence)

  function new(string name = "apb_delayed_bready_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Delayed BREADY Support Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 0;
      rdata       == 32'h0000_0000;
    })

    `uvm_info(get_type_name(),
              "APB Delayed BREADY Support Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_delayed_bready_sequence


//============================================================
// 6. APB SIMULTANEOUS READ/WRITE SUPPORT SEQUENCE
//
// Provides responses for two APB transfers.
// The DUT determines the actual transfer order.
//============================================================
class apb_simultaneous_rw_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_simultaneous_rw_sequence)

  function new(string name = "apb_simultaneous_rw_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Simultaneous Read/Write Support Started",
              UVM_LOW)

    // First APB response
    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 0;
      rdata       == 32'h1111_2222;
    })

    // Second APB response
    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 0;
      rdata       == 32'h3333_4444;
    })

    `uvm_info(get_type_name(),
              "APB Simultaneous Read/Write Support Completed",
              UVM_LOW)

  endtask : body

endclass : apb_simultaneous_rw_sequence


//============================================================
// 7. APB BACK-TO-BACK READS SEQUENCE
//
// Provides five consecutive APB responses.
//============================================================
class apb_back_to_back_reads_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_back_to_back_reads_sequence)

  function new(string name = "apb_back_to_back_reads_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Back-to-Back Reads Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 5; i++) begin

      `uvm_do_with(req, {
        wait_cycles == 0;
        slverr      == 0;
        rdata       == (32'h1000_0000 + i);
      })

    end

    `uvm_info(get_type_name(),
              "APB Back-to-Back Reads Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_back_to_back_reads_sequence


//============================================================
// 8. APB BACK-TO-BACK WRITES SEQUENCE
//
// Provides five consecutive APB responses.
//============================================================
class apb_back_to_back_writes_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_back_to_back_writes_sequence)

  function new(string name = "apb_back_to_back_writes_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Back-to-Back Writes Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 5; i++) begin

      `uvm_do_with(req, {
        wait_cycles == 0;
        slverr      == 0;
        rdata       == 32'h0000_0000;
      })

    end

    `uvm_info(get_type_name(),
              "APB Back-to-Back Writes Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_back_to_back_writes_sequence


//============================================================
// 9. APB MIXED TRAFFIC SEQUENCE
//
// Provides ten APB responses.
//============================================================
class apb_mixed_traffic_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_mixed_traffic_sequence)

  function new(string name = "apb_mixed_traffic_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB Mixed Traffic Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 10; i++) begin

      `uvm_do_with(req, {
        wait_cycles == 0;
        slverr      == 0;
        rdata       == (32'hABCD_0000 + i);
      })

    end

    `uvm_info(get_type_name(),
              "APB Mixed Traffic Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_mixed_traffic_sequence


//============================================================
// 10. APB DIFFERENT ID/USER SUPPORT SEQUENCE
//
// AXI IDs and USER values are handled by AXI agent.
// APB responds to ten transfers.
//============================================================
class apb_id_user_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_id_user_sequence)

  function new(string name = "apb_id_user_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB ID/USER Support Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 10; i++) begin

      `uvm_do_with(req, {
        wait_cycles == 0;
        slverr      == 0;
        rdata       == (32'hFACE_0000 + i);
      })

    end

    `uvm_info(get_type_name(),
              "APB ID/USER Support Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_id_user_sequence


//============================================================
// 11. APB PSLVERR SEQUENCE
//
// Generates APB error responses for two transfers.
//============================================================
class apb_pslverr_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_pslverr_sequence)

  function new(string name = "apb_pslverr_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "APB PSLVERR Sequence Started",
              UVM_LOW)

    // Error response for AXI write
    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 1;
      rdata       == 32'h0000_0000;
    })

    // Error response for AXI read
    `uvm_do_with(req, {
      wait_cycles == 0;
      slverr      == 1;
      rdata       == 32'hBAD0_BAD0;
    })

    `uvm_info(get_type_name(),
              "APB PSLVERR Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_pslverr_sequence


//============================================================
// 12. APB CONFIGURABLE RESPONSE SEQUENCE
//
// Reusable sequence for custom APB responses.
//============================================================
class apb_configurable_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_configurable_sequence)

  //----------------------------------------------------------
  // Configuration
  //----------------------------------------------------------
  int unsigned num_transfers = 1;
  int unsigned configured_wait_cycles = 0;

  bit [31:0] configured_rdata = 32'h0000_0000;
  bit        configured_slverr = 1'b0;

  function new(string name = "apb_configurable_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
      $sformatf(
        "APB Configurable Sequence Started: TRANSFERS=%0d WAIT=%0d",
        num_transfers, configured_wait_cycles),
      UVM_LOW)

    for (int i = 0; i < num_transfers; i++) begin

      `uvm_do_with(req, {
        wait_cycles == local::configured_wait_cycles;
        slverr      == local::configured_slverr;
        rdata       == local::configured_rdata;
      })

    end

    `uvm_info(get_type_name(),
              "APB Configurable Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : apb_configurable_sequence

`endif