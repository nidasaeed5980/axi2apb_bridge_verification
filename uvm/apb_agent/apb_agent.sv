  // ============================================================
// APB AGENT
// Purpose: Container for APB Driver, Monitor, and Sequencer.
//          Acts as an APB Slave in our environment.
// ============================================================
class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    // Agent ke andar ke components (Using our custom sequencer class now)
    apb_driver    drv;
    apb_monitor   mon;
    apb_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase: Create the components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // 1. Monitor hamesha chalta hai (both Active and Passive mode)
        mon = apb_monitor::type_id::create("mon", this);

        // 2. Driver and Sequencer are only created in ACTIVE mode
        if (get_is_active() == UVM_ACTIVE) begin
            drv = apb_driver::type_id::create("drv", this);
            sqr = apb_sequencer::type_id::create("sqr", this);
        end
    endfunction

    // connect_phase: Connect Driver to Sequencer
    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            // Connect driver's port to sequencer's export
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction

endclass
