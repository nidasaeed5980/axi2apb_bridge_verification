 

// ============================================================
// AXI2APB COVERAGE
// ============================================================
`uvm_analysis_imp_decl(_axi_cov)
`uvm_analysis_imp_decl(_apb_cov)

class axi2apb_cov extends uvm_component;
    `uvm_component_utils(axi2apb_cov)

    // Dono Monitors ke liye alag Imports
    uvm_analysis_imp_axi_cov #(axi_seq_item, axi2apb_cov) axi_imp;
    uvm_analysis_imp_apb_cov #(apb_seq_item, axi2apb_cov) apb_imp;

    axi_seq_item tr_axi;
    apb_seq_item tr_apb;

    // ---------------- AXI Coverage ----------------
    covergroup cg_axi;
        option.per_instance = 1;
        cp_dir : coverpoint tr_axi.is_write { bins wr = {1}; bins rd = {0}; }
        cp_addr: coverpoint tr_axi.addr {
            bins zero    = {32'h0000_0000};
            bins low     = {[32'h0000_0001 : 32'h0000_7FFF]};
            bins high    = {[32'h0000_8000 : 32'h0000_FFFF]};
            bins max     = {32'hFFFF_FFFC};
        }
        cp_data: coverpoint tr_axi.wdata {
            bins zero    = {32'h0000_0000};
            bins ones    = {32'hFFFF_FFFF};
            bins alt     = {32'hAAAA_AAAA, 32'h5555_5555};
            bins walk    = {32'h0000_0001, 32'h0000_0002, 32'h0000_0004};
            bins others  = default;
        }
    endgroup

    // ---------------- APB Coverage ----------------
    covergroup cg_apb;
        option.per_instance = 1;
        cp_pwrite : coverpoint tr_apb.pwrite { bins wr = {1}; bins rd = {0}; }
        cp_wait : coverpoint tr_apb.pready_delay {
            bins immediate = {0};
            bins wait_1    = {1};
            bins wait_more = {[2:10]};
        }
        cp_pslverr : coverpoint tr_apb.pslverr {
            bins no_error = {0};
            bins error    = {1};
        }
    endgroup

    // ---------------- Cross Coverage (own coverpoints, no hierarchy) ----------------
    covergroup cg_cross;
        option.per_instance = 1;
        cp_pwrite : coverpoint tr_apb.pwrite { bins wr = {1}; bins rd = {0}; }
        cp_wait   : coverpoint tr_apb.pready_delay {
            bins immediate = {0};
            bins wait_1    = {1};
            bins wait_more = {[2:10]};
        }
        cross_wait_dir : cross cp_pwrite, cp_wait;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_imp  = new("axi_imp", this);
        apb_imp  = new("apb_imp", this);
        cg_axi   = new();
        cg_apb   = new();
        cg_cross = new();
    endfunction

    // AXI Monitor se data aayega
    function void write_axi_cov(axi_seq_item t);
        tr_axi = t;
        cg_axi.sample();
    endfunction

    // APB Monitor se data aayega
    function void write_apb_cov(apb_seq_item t);
        tr_apb = t;
        cg_apb.sample();
        cg_cross.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf("AXI Coverage = %.2f%%",   cg_axi.get_coverage()),   UVM_LOW)
        `uvm_info("COV", $sformatf("APB Coverage = %.2f%%",   cg_apb.get_coverage()),   UVM_LOW)
        `uvm_info("COV", $sformatf("Cross Coverage = %.2f%%", cg_cross.get_coverage()), UVM_LOW)
    endfunction
endclass
