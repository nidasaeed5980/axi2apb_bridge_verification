`ifndef AXI_SEQ_ITEM_SV
`define AXI_SEQ_ITEM_SV

//---------------------------------------
// AXI Operation Type
//---------------------------------------
typedef enum {
  AXI_READ,
  AXI_WRITE
} axi_op_e;

//---------------------------------------
// AXI Sequence Item
//---------------------------------------
class axi_seq_item extends uvm_sequence_item;

  //---------------------------------------
  // Random transaction fields
  //---------------------------------------
  rand axi_op_e       op;
  rand bit [31:0]     addr;
  rand bit [31:0]     data;
  rand bit [15:0]     id;
  rand bit [9:0]      user;
  rand bit [3:0]      strb;

  //---------------------------------------
  // Transaction delays
  //---------------------------------------
  rand int unsigned aw_delay;
  rand int unsigned w_delay;
  rand int unsigned resp_ready_delay;

  //---------------------------------------
  // Response fields
  //---------------------------------------
  bit [31:0]          rdata;
  bit [1:0]           resp;
  bit [15:0]          resp_id;

  //---------------------------------------
  // UVM Factory Registration
  // Field Automation Macros
  //---------------------------------------
  `uvm_object_utils_begin(axi_seq_item)

    `uvm_field_enum(axi_op_e, op, UVM_ALL_ON)

    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(id,   UVM_ALL_ON)
    `uvm_field_int(user, UVM_ALL_ON)
    `uvm_field_int(strb, UVM_ALL_ON)

    `uvm_field_int(aw_delay,         UVM_ALL_ON)
    `uvm_field_int(w_delay,          UVM_ALL_ON)
    `uvm_field_int(resp_ready_delay, UVM_ALL_ON)

    `uvm_field_int(rdata,   UVM_ALL_ON)
    `uvm_field_int(resp,    UVM_ALL_ON)
    `uvm_field_int(resp_id, UVM_ALL_ON)

  `uvm_object_utils_end

  //---------------------------------------
  // Constraints
  //---------------------------------------
  constraint axi_constraints {

    // 32-bit aligned address
    addr[1:0] == 2'b00;

    // All 4 bytes enabled
    strb == 4'b1111;

    // Transaction delays
    aw_delay inside {[0:5]};
    w_delay inside {[0:5]};
    resp_ready_delay inside {[0:5]};

  }

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "axi_seq_item");
    super.new(name);
  endfunction : new

endclass : axi_seq_item

`endif