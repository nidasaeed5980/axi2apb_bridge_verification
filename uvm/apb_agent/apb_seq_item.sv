`ifndef APB_SEQ_ITEM_SV
`define APB_SEQ_ITEM_SV

//--------------------------------------------------
// APB SEQUENCE ITEM
//--------------------------------------------------
class apb_seq_item extends uvm_sequence_item;

  //--------------------------------------------------
  // APB Request Information
  // Captured from DUT by APB Driver / Monitor
  //--------------------------------------------------
  bit [31:0] addr;
  bit [31:0] wdata;
  bit        write;

  //--------------------------------------------------
  // APB Response Stimulus
  //--------------------------------------------------
  rand bit [31:0] rdata;
  rand bit        slverr;
  rand int unsigned wait_cycles;

  //--------------------------------------------------
  // UVM Factory Registration + Field Macros
  //--------------------------------------------------
  `uvm_object_utils_begin(apb_seq_item)

    `uvm_field_int(addr,        UVM_ALL_ON)
    `uvm_field_int(wdata,       UVM_ALL_ON)
    `uvm_field_int(write,       UVM_ALL_ON)

    `uvm_field_int(rdata,       UVM_ALL_ON)
    `uvm_field_int(slverr,      UVM_ALL_ON)
    `uvm_field_int(wait_cycles, UVM_ALL_ON)

  `uvm_object_utils_end

  //--------------------------------------------------
  // Constraints
  //--------------------------------------------------
  constraint apb_constraints {

    // APB wait states: 0 to 10 cycles
    wait_cycles inside {[0:10]};

    // Default APB response: no error
    soft slverr == 1'b0;

  }

  //--------------------------------------------------
  // Constructor
  //--------------------------------------------------
  function new(string name = "apb_seq_item");

    super.new(name);

  endfunction : new

endclass : apb_seq_item

`endif