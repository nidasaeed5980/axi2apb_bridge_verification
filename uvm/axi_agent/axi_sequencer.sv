`ifndef AXI_SEQUENCER_SV
`define AXI_SEQUENCER_SV

//---------------------------------------
// AXI Sequencer
//---------------------------------------
class axi_sequencer extends uvm_sequencer #(axi_seq_item);

  //---------------------------------------
  // UVM Factory Registration
  //---------------------------------------
  `uvm_component_utils(axi_sequencer)

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "axi_sequencer",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // Build Phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Sequencer Build Phase Executed",
              UVM_LOW)

  endfunction : build_phase

endclass : axi_sequencer

`endif