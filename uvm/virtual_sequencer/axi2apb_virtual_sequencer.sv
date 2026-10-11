`ifndef AXI2APB_VIRTUAL_SEQUENCER_SV
`define AXI2APB_VIRTUAL_SEQUENCER_SV

//------------------------------------------------------------
// AXI2APB VIRTUAL SEQUENCER
//
// Purpose:
// - Holds AXI Sequencer handle
// - Holds APB Sequencer handle
// - Coordinates AXI and APB virtual sequences
//
// Handles are assigned by axi2apb_env connect_phase.
// Validation is performed in end_of_elaboration_phase.
//------------------------------------------------------------

class axi2apb_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

  //----------------------------------------------------------
  // Factory Registration
  //----------------------------------------------------------
  `uvm_component_utils(axi2apb_virtual_sequencer)

  //----------------------------------------------------------
  // Sequencer Handles
  //----------------------------------------------------------
  axi_sequencer axi_seqr;
  apb_sequencer apb_seqr;

  //----------------------------------------------------------
  // Constructor
  //----------------------------------------------------------
  function new(string name = "axi2apb_virtual_sequencer",
               uvm_component parent = null);

    super.new(name, parent);

  endfunction : new

  //----------------------------------------------------------
  // Build Phase
  //----------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Virtual Sequencer Build Phase Executed",
              UVM_LOW)

  endfunction : build_phase

  //----------------------------------------------------------
  // Connect Phase
  //
  // Do not check handles here because parent environment
  // assigns them in its connect_phase.
  //----------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Virtual Sequencer Connect Phase Executed",
              UVM_LOW)

  endfunction : connect_phase

  //----------------------------------------------------------
  // End of Elaboration Phase
  //
  // At this point environment connect_phase is complete.
  // Safe to validate both sequencer handles.
  //----------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Virtual Sequencer End of Elaboration Phase Executed",
              UVM_LOW)

    //--------------------------------------------------------
    // Check AXI Sequencer Handle
    //--------------------------------------------------------
    if (axi_seqr == null) begin

      `uvm_fatal(get_type_name(),
                 "AXI Sequencer Handle Not Connected")

    end
    else begin

      `uvm_info(get_type_name(),
                "AXI Sequencer Handle Connected Successfully",
                UVM_LOW)

    end

    //--------------------------------------------------------
    // Check APB Sequencer Handle
    //--------------------------------------------------------
    if (apb_seqr == null) begin

      `uvm_fatal(get_type_name(),
                 "APB Sequencer Handle Not Connected")

    end
    else begin

      `uvm_info(get_type_name(),
                "APB Sequencer Handle Connected Successfully",
                UVM_LOW)

    end

  endfunction : end_of_elaboration_phase

endclass : axi2apb_virtual_sequencer

`endif
