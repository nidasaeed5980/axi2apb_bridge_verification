class apb_seq_item extends uvm_sequence_item;

    // =====================================================================
    // 1. OBSERVED FIELDS (Captured by APB Monitor from DUT)
    // =====================================================================
    bit [31:0] paddr;       // Address from DUT
    bit        pwrite;      // Direction from DUT (1=Write, 0=Read)
    bit [31:0] pwdata;      // Write Data from DUT
    bit        penable;     // Enable signal from DUT

    // =====================================================================
    // 2. STIMULUS FIELDS (Driven by APB Slave Driver)
    // =====================================================================
    rand bit [31:0]     prdata;         // Read Data to send back to DUT
    rand bit            pslverr;        // Error signal (Spec Test 13)
    rand int unsigned   pready_delay;   // Wait states (Spec Test 4 & 5)

    // Default Constraints (Safe values)
    constraint c_defaults {
        soft prdata       inside {32'h0000_0000, 32'hFFFF_FFFF, 32'hA5A5_A5A5};
        soft pslverr      == 1'b0;
        soft pready_delay inside {[0:3]}; // Max 3 wait states by default
    }

    // UVM Factory Registration
    `uvm_object_utils_begin(apb_seq_item)
        `uvm_field_int(paddr,        UVM_ALL_ON)
        `uvm_field_int(pwrite,       UVM_ALL_ON)
        `uvm_field_int(pwdata,       UVM_ALL_ON)
        `uvm_field_int(prdata,       UVM_ALL_ON)
        `uvm_field_int(pslverr,      UVM_ALL_ON)
        `uvm_field_int(pready_delay, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "apb_seq_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("[%s] Addr=0x%08h WData=0x%08h RData=0x%08h Wait=%0d PSLVERR=%0b", 
                         pwrite ? "APB_WR" : "APB_RD", paddr, pwdata, prdata, pready_delay, pslverr);
    endfunction

endclass