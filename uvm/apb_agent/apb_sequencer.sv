 

// ============================================================
// APB SEQUENCER
// Purpose: Acts as a bridge between APB Sequences and APB Driver.
//          It holds the response configurations (wait states, errors)
//          until the APB Driver requests them.
// ============================================================
class apb_sequencer extends uvm_sequencer #(apb_seq_item);
    `uvm_component_utils(apb_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "APB Sequencer Build Phase Executed",
              UVM_LOW)

  endfunction : build_phase

endclass
