 

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_apb)

class axi2apb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi2apb_scoreboard)
    
    uvm_analysis_imp_axi #(axi_seq_item, axi2apb_scoreboard) axi_imp;
    uvm_analysis_imp_apb #(apb_seq_item, axi2apb_scoreboard) apb_imp;

    axi_seq_item axi_wr_q[$], axi_rd_q[$];
    apb_seq_item apb_wr_q[$], apb_rd_q[$];

    int pass_cnt = 0, fail_cnt = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_imp = new("axi_imp", this);
        apb_imp = new("apb_imp", this);
    endfunction

    function void write_axi(axi_seq_item tr);
        if (tr.is_write) axi_wr_q.push_back(tr);
        else             axi_rd_q.push_back(tr);
        check_pairing();
    endfunction

    function void write_apb(apb_seq_item tr);
        if (tr.pwrite) apb_wr_q.push_back(tr);
        else           apb_rd_q.push_back(tr);
        check_pairing();
    endfunction

    function void check_pairing();
        // WRITE CHECK
        if (axi_wr_q.size() > 0 && apb_wr_q.size() > 0) begin
            axi_seq_item a = axi_wr_q.pop_front();
            apb_seq_item p = apb_wr_q.pop_front();
            
            if (a.addr !== p.paddr) begin
                `uvm_error("SB_WR", $sformatf("Address mismatch: AXI=0x%0h, APB=0x%0h", a.addr, p.paddr))
                fail_cnt++;
            end
            else if (a.wdata !== p.pwdata) begin
                `uvm_error("SB_WR", $sformatf("Data mismatch: AXI=0x%0h, APB=0x%0h", a.wdata, p.pwdata))
                fail_cnt++;
            end
            else begin
                `uvm_info("SB_WR", $sformatf("PASS: Write Addr=0x%0h Data=0x%0h", a.addr, a.wdata), UVM_LOW)
                pass_cnt++;
            end
        end

        // READ CHECK
        if (axi_rd_q.size() > 0 && apb_rd_q.size() > 0) begin
            axi_seq_item a = axi_rd_q.pop_front();
            apb_seq_item p = apb_rd_q.pop_front();
            
            if (a.addr !== p.paddr) begin
                `uvm_error("SB_RD", $sformatf("Address mismatch: AXI=0x%0h, APB=0x%0h", a.addr, p.paddr))
                fail_cnt++;
            end
            else if (a.rdata !== p.prdata) begin
                `uvm_error("SB_RD", $sformatf("Data mismatch: AXI=0x%0h, APB=0x%0h", a.rdata, p.prdata))
                fail_cnt++;
            end
            else begin
                `uvm_info("SB_RD", $sformatf("PASS: Read Addr=0x%0h Data=0x%0h", a.addr, a.rdata), UVM_LOW)
                pass_cnt++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf("Scoreboard Summary: PASS=%0d FAIL=%0d", pass_cnt, fail_cnt), UVM_LOW)
    endfunction
endclass




// `uvm_analysis_imp_decl(_axi)
// `uvm_analysis_imp_decl(_apb)

// class axi2apb_scoreboard extends uvm_scoreboard;
//     `uvm_component_utils(axi2apb_scoreboard)
    
//     uvm_analysis_imp_axi #(axi_seq_item, axi2apb_scoreboard) axi_imp;
//     uvm_analysis_imp_apb #(apb_seq_item, axi2apb_scoreboard) apb_imp;

//     function new(string name, uvm_component parent);
//         super.new(name, parent);
//         axi_imp = new("axi_imp", this);
//         apb_imp = new("apb_imp", this);
//     endfunction

//     // Jab bhi AXI Monitor data bhejega
//     function void write_axi(axi_seq_item tr);
//         `uvm_info("SCB", $sformatf("Received from AXI: %s", tr.convert2string()), UVM_LOW)
//     endfunction

//     // Jab bhi APB Monitor data bhejega
//     function void write_apb(apb_seq_item tr);
//         `uvm_info("SCB", $sformatf("Received from APB: %s", tr.convert2string()), UVM_LOW)
//     endfunction
// endclass
