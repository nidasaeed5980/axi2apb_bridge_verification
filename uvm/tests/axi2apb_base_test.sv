 // ============================================================
// AXI2APB BASE TEST
// Purpose: Parent class for all tests. 
//          Prints TEST PASS / TEST FAIL at the end.
// ============================================================
class axi2apb_base_test extends uvm_test;
    `uvm_component_utils(axi2apb_base_test)
    
    // Environment instance
    axi2apb_env env;

    function new(string name = "axi2apb_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi2apb_env::type_id::create("env", this);
    endfunction : build_phase

    // End of Elaboration
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Uncomment below line to see the UVM topology
        // print();
    endfunction

    // Report Phase (Prints PASS or FAIL)
    function void report_phase(uvm_phase phase);
        uvm_report_server svr;
        super.report_phase(phase);
        
        svr = uvm_report_server::get_server();
        
        if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        end
        else begin
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
            `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
            `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
        end
    endfunction 
endclass : axi2apb_base_test
