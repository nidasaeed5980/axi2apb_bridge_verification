


class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    virtual axi_if vif;
    uvm_analysis_port #(axi_seq_item) ap;

    // Write-channel capture queues (AW and W can arrive in any order / same cycle)
    bit [31:0] aw_addr_q[$];
    bit [15:0] aw_id_q[$];
    bit [31:0] w_data_q[$];
    bit [7:0]  aw_len_q[$];
    bit [31:0] ar_addr_q[$];
    bit [15:0] ar_id_q[$];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", vif))
            `uvm_fatal(get_type_name(), "No AXI virtual interface found!")
    endfunction

    task run_phase(uvm_phase phase);
        wait(vif.ARESETn == 1'b1); // Wait for reset
        fork
            capture_aw();
            capture_w();
            capture_b();
            monitor_reads();
        join
    endtask

    // ---------------- WRITE: AW channel ----------------
    task capture_aw();
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.awvalid === 1'b1 && vif.mon_cb.awready === 1'b1) begin
                aw_addr_q.push_back(vif.mon_cb.awaddr);
                aw_id_q.push_back(vif.mon_cb.awid);
                aw_len_q.push_back(vif.mon_cb.awlen);
            end
        end
    endtask

    // ---------------- WRITE: W channel ----------------
    task capture_w();
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.wvalid === 1'b1 && vif.mon_cb.wready === 1'b1)
                w_data_q.push_back(vif.mon_cb.wdata);
        end
    endtask

    // ---------------- WRITE: B channel (publishes the transaction) ----------------
    task capture_b();
        axi_seq_item tr;
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.bvalid === 1'b1 && vif.mon_cb.bready === 1'b1) begin
                if (aw_addr_q.size() == 0 || w_data_q.size() == 0) begin
                    `uvm_error(get_type_name(), "B response seen but AW or W was not captured")
                end
                else begin
                    tr = axi_seq_item::type_id::create("mon_wr_tr");
                    tr.is_write = 1;
                    tr.addr     = aw_addr_q.pop_front();
                    tr.id       = aw_id_q.pop_front();
                    tr.len      = aw_len_q.pop_front();
                    tr.wdata    = w_data_q.pop_front();
                    tr.resp     = vif.mon_cb.bresp;
                    `uvm_info(get_type_name(), $sformatf("AXI Write Captured: %s", tr.convert2string()), UVM_LOW)
                    ap.write(tr);
                end
            end
        end
    endtask

    // ---------------- READ (unchanged logic) ----------------
    // task monitor_reads();
    //     axi_seq_item tr;
    //     bit [31:0] cap_addr;
    //     bit [15:0] cap_id;
    //     forever begin
    //         do @(vif.mon_cb); while (!(vif.mon_cb.arvalid === 1'b1 && vif.mon_cb.arready === 1'b1));
    //         cap_addr = vif.mon_cb.araddr; cap_id = vif.mon_cb.arid;
            
    //         do @(vif.mon_cb); while (!(vif.mon_cb.rvalid === 1'b1 && vif.mon_cb.rready === 1'b1));

    //         tr = axi_seq_item::type_id::create("mon_rd_tr");
    //         tr.is_write = 0; tr.addr = cap_addr; tr.id = cap_id;
            
    //         tr.rdata = vif.mon_cb.rdata; tr.resp = vif.mon_cb.rresp; tr.rlast = vif.mon_cb.rlast;
    //         `uvm_info(get_type_name(), $sformatf("AXI Read Captured: %s", tr.convert2string()), UVM_LOW)
    //         ap.write(tr);
    //     end
    // endtask
    // ============================================================
// READ MONITOR - MULTIPLE OUTSTANDING READ SUPPORT
// ============================================================
task monitor_reads();

    fork
        // Capture every accepted AR request
        begin : CAPTURE_AR
            forever begin
                @(vif.mon_cb);

                if (vif.mon_cb.arvalid === 1'b1 &&
                    vif.mon_cb.arready === 1'b1) begin

                    ar_addr_q.push_back(vif.mon_cb.araddr);
                    ar_id_q.push_back(vif.mon_cb.arid);

                end
            end
        end

        // Match each R response with captured AR request
        begin : CAPTURE_R
            axi_seq_item tr;

            forever begin
                @(vif.mon_cb);

                if (vif.mon_cb.rvalid === 1'b1 &&
                    vif.mon_cb.rready === 1'b1) begin

                    if (ar_addr_q.size() == 0 ||
                        ar_id_q.size() == 0) begin

                        `uvm_error(get_type_name(),
                            "R response received without matching AR request")

                    end
                    else begin
                        tr = axi_seq_item::type_id::create("mon_rd_tr");

                        tr.is_write = 1'b0;
                        tr.addr     = ar_addr_q.pop_front();
                        tr.id       = ar_id_q.pop_front();

                        tr.rdata = vif.mon_cb.rdata;
                        tr.resp  = vif.mon_cb.rresp;
                        tr.rlast = vif.mon_cb.rlast;

                        `uvm_info(get_type_name(),
                            $sformatf("AXI Read Captured: %s",
                                      tr.convert2string()),
                            UVM_LOW)

                        ap.write(tr);
                    end
                end
            end
        end
    join

endtask
endclass