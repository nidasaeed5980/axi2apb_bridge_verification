
// ============================================================
// VIRTUAL SEQUENCER
// Purpose: It does not drive any pins. Its only job is to hold 
//          handles to the AXI and APB sequencers so that a 
//          Virtual Sequence can control both at the same time.
// ============================================================
class axi2apb_vseqr extends uvm_sequencer;
    `uvm_component_utils(axi2apb_vseqr)

    // Handles (Pointers) to the actual AXI and APB sequencers
    axi_sequencer axi_sqr;
    apb_sequencer apb_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);

    `uvm_info(get_type_name(),
              "AXI2APB Virtual Sequencer End of Elaboration Phase Executed",
              UVM_LOW)

    //--------------------------------------------------------
    // Check AXI Sequencer Handle
    //--------------------------------------------------------
    if (axi_sqr == null) begin

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
    if (apb_sqr== null) begin

      `uvm_fatal(get_type_name(),
                 "APB Sequencer Handle Not Connected")

    end
    else begin

      `uvm_info(get_type_name(),
                "APB Sequencer Handle Connected Successfully",
                UVM_LOW)

    end

  endfunction : end_of_elaboration_phase
endclass