`ifndef APB_SEQUENCER_SV
`define APB_SEQUENCER_SV

//--------------------------------------------------
// APB SEQUENCER
//--------------------------------------------------
class apb_sequencer extends uvm_sequencer #(apb_seq_item);

  //--------------------------------------------------
  // UVM Factory Registration
  //--------------------------------------------------
  `uvm_component_utils(apb_sequencer)

  //--------------------------------------------------
  // Constructor
  //--------------------------------------------------
  function new(string name = "apb_sequencer",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //--------------------------------------------------
  // Build Phase
  //--------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "APB Sequencer Build Phase Executed",
              UVM_LOW)

  endfunction : build_phase

endclass : apb_sequencer

`endif