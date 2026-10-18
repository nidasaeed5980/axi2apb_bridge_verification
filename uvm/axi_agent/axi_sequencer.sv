 

// ============================================================
// AXI SEQUENCER
// Purpose: Acts as a bridge between AXI Sequences and AXI Driver.
//          It holds the transactions until the driver is ready.
// ============================================================
class axi_sequencer extends uvm_sequencer #(axi_seq_item);
    `uvm_component_utils(axi_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI Sequencer Build Phase Executed",
              UVM_LOW)

  endfunction : build_phase

endclass
