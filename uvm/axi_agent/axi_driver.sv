class axi_driver extends uvm_driver #(axi_seq_item);
    `uvm_component_utils(axi_driver)
    virtual axi_if vif;
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_if)::get(this, "", "axi_vif", vif))
            `uvm_fatal(get_type_name(), "No AXI virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        vif.drv_cb.awvalid <= 0; vif.drv_cb.wvalid <= 0; vif.drv_cb.arvalid <= 0;
        vif.drv_cb.bready  <= 0; vif.drv_cb.rready <= 0;
        wait(vif.ARESETn === 1'b0);
        wait(vif.ARESETn == 1'b1);
       repeat(5) @(vif.drv_cb); 
        
        forever begin
            if (req.fifo_stress_mode) begin
                if (req.is_write)
                    do_write_fifo_stress(req);
                else
                    do_read_fifo_stress(req);
            end
            else if (req.simultaneous_rw)
                do_simultaneous(req);
            else if (req.is_write)
                do_write(req);
            else
                do_read(req);

            seq_item_port.item_done();
        end
    endtask

    // =====================================================================
    // SPECIAL TASK FOR TEST 8: Read/Write Priority
    // =====================================================================
    task do_simultaneous(axi_seq_item tr);
        `uvm_info(get_type_name(), "Driving AWVALID and ARVALID together (Priority Test)", UVM_LOW)
        
        // Drive AW and AR exactly at the same time
        fork
            begin
                @(vif.drv_cb);
                vif.drv_cb.awid    <= tr.id;
                vif.drv_cb.awaddr  <= tr.addr;
                vif.drv_cb.awlen   <= tr.len;
                vif.drv_cb.awsize  <= tr.size;
                vif.drv_cb.awburst <= tr.burst;
                vif.drv_cb.awvalid <= 1'b1;
                
                do @(vif.drv_cb); while (vif.drv_cb.awready !== 1'b1);
                vif.drv_cb.awvalid <= 1'b0;
            end
            begin
                @(vif.drv_cb);
                vif.drv_cb.arid    <= tr.id + 1; // Different ID for read
                vif.drv_cb.araddr  <= tr.addr + 32'h4; // Different address
                vif.drv_cb.arlen   <= tr.len;
                vif.drv_cb.arsize  <= tr.size;
                vif.drv_cb.arburst <= tr.burst;
                vif.drv_cb.arvalid <= 1'b1;
                
                do @(vif.drv_cb); while (vif.drv_cb.arready !== 1'b1);
                vif.drv_cb.arvalid <= 1'b0;
            end
        join

        // Now handle both responses (B and R channels)
        // Since DUT gives priority to Read, we might get R first, then B
        fork
            // Write Data & Response
            begin
                @(vif.drv_cb);
                vif.drv_cb.wdata  <= tr.wdata;
                vif.drv_cb.wstrb  <= tr.wstrb;
                vif.drv_cb.wlast  <= 1'b1;
                vif.drv_cb.wvalid <= 1'b1;
                do @(vif.drv_cb); while (vif.drv_cb.wready !== 1'b1);
                vif.drv_cb.wvalid <= 1'b0;

                vif.drv_cb.bready <= 1'b1;
                do @(vif.drv_cb); while (vif.drv_cb.bvalid !== 1'b1);
                vif.drv_cb.bready <= 1'b0;
            end
            // Read Response
            begin
                vif.drv_cb.rready <= 1'b1;
                do @(vif.drv_cb); while (vif.drv_cb.rvalid !== 1'b1);
                vif.drv_cb.rready <= 1'b0;
            end
        join
    endtask
        // Drive random values on side-band signals the DUT carries but never uses
    task drive_sideband();
        vif.drv_cb.awlock   <= $urandom_range(1);
        vif.drv_cb.awcache  <= $urandom_range(15);
        vif.drv_cb.awprot   <= $urandom_range(7);
        vif.drv_cb.awregion <= $urandom_range(15);
        vif.drv_cb.awqos    <= $urandom_range(15);
        vif.drv_cb.wuser    <= $urandom_range(1023);
        vif.drv_cb.arlock   <= $urandom_range(1);
        vif.drv_cb.arcache  <= $urandom_range(15);
        vif.drv_cb.arprot   <= $urandom_range(7);
        vif.drv_cb.arregion <= $urandom_range(15);
        vif.drv_cb.arqos    <= $urandom_range(15);
    endtask

        // =====================================================================
    // NORMAL WRITE TASK
    // =====================================================================
    task do_write(axi_seq_item tr);
        `uvm_info(get_type_name(), $sformatf("Driving Write: %s", tr.convert2string()), UVM_HIGH)
        drive_sideband();
        fork
            begin
                repeat(tr.aw_delay) @(vif.drv_cb);
                vif.drv_cb.awid    <= tr.id;
                vif.drv_cb.awuser  <= tr.user;
                vif.drv_cb.awaddr  <= tr.addr;
                vif.drv_cb.awlen   <= tr.len;
                vif.drv_cb.awsize  <= tr.size;
                vif.drv_cb.awburst <= tr.burst;
                vif.drv_cb.awvalid <= 1'b1;
                do @(vif.drv_cb); while (vif.drv_cb.awready !== 1'b1);
                vif.drv_cb.awvalid <= 1'b0;
            end
            begin
                repeat(tr.w_delay) @(vif.drv_cb);
                for (int i = 0; i <= tr.len; i++) begin
                    vif.drv_cb.wdata  <= (i == 0) ? tr.wdata : tr.wdata + (i*4);
                    vif.drv_cb.wstrb  <= tr.wstrb;
                    vif.drv_cb.wlast  <= (i == tr.len) ? 1'b1 : 1'b0;
                    vif.drv_cb.wvalid <= 1'b1;
                    do @(vif.drv_cb); while (vif.drv_cb.wready !== 1'b1);
                    vif.drv_cb.wvalid <= 1'b0;
                end
                vif.drv_cb.wlast <= 1'b0;
            end
        join

        // 1. w8 for BVALID  (BREADY low )
        do @(vif.drv_cb); while (vif.drv_cb.bvalid !== 1'b1);

        // 2. BVALID aane ke BAAD BREADY mein delay
        repeat(tr.bready_delay) @(vif.drv_cb);

        // 3. BREADY  high for 1 cycle 
        vif.drv_cb.bready <= 1'b1;
        @(vif.drv_cb);
        vif.drv_cb.bready <= 1'b0;
    endtask
        // =====================================================================
    // NORMAL READ TASK
    // =====================================================================
    task do_read(axi_seq_item tr);
        `uvm_info(get_type_name(), $sformatf("Driving Read: %s", tr.convert2string()), UVM_HIGH)
        drive_sideband();
        repeat(tr.ar_delay) @(vif.drv_cb);
        vif.drv_cb.arid    <= tr.id;
        vif.drv_cb.aruser  <= tr.user;
        vif.drv_cb.araddr  <= tr.addr;
        vif.drv_cb.arlen   <= tr.len;
        vif.drv_cb.arsize  <= tr.size;
        vif.drv_cb.arburst <= tr.burst;
        vif.drv_cb.arvalid <= 1'b1;
        do @(vif.drv_cb); while (vif.drv_cb.arready !== 1'b1);
        vif.drv_cb.arvalid <= 1'b0;

        for (int i = 0; i <= tr.len; i++) begin
            // 1. Pehle RVALID ka intezar (RREADY low rakhte hue)
            do @(vif.drv_cb); while (vif.drv_cb.rvalid !== 1'b1);

            // 2.   delay in RREADY after RVALID
            repeat(tr.rready_delay) @(vif.drv_cb);

            // 3. RREADY  high for 1 cycle
            vif.drv_cb.rready <= 1'b1;
            @(vif.drv_cb);
            vif.drv_cb.rready <= 1'b0;

            if (vif.drv_cb.rlast == 1'b1) break;
        end
    endtask
    // ============================================================
// FIFO STRESS: ISSUE WRITE REQUEST
// ============================================================
task issue_stress_write(axi_seq_item tr, int unsigned index);

    bit [31:0] address;
    bit [31:0] data_value;

    address = tr.addr + (index * 4);
    data_value = tr.wdata ^ (index[0] ? 32'h5555_5555
                                      : 32'hAAAA_AAAA);

    fork
        begin
            @(vif.drv_cb);

            vif.drv_cb.awid    <= tr.id + index;
            vif.drv_cb.awuser  <= tr.user;
            vif.drv_cb.awaddr  <= address;
            vif.drv_cb.awlen   <= 8'd0;
            vif.drv_cb.awsize  <= 3'd2;
            vif.drv_cb.awburst <= 2'd1;
            vif.drv_cb.awvalid <= 1'b1;

            do @(vif.drv_cb);
            while (vif.drv_cb.awready !== 1'b1);

            vif.drv_cb.awvalid <= 1'b0;
        end

        begin
            @(vif.drv_cb);

            vif.drv_cb.wdata  <= data_value;
            vif.drv_cb.wstrb  <= 4'hF;
            vif.drv_cb.wlast  <= 1'b1;
            vif.drv_cb.wvalid <= 1'b1;

            do @(vif.drv_cb);
            while (vif.drv_cb.wready !== 1'b1);

            vif.drv_cb.wvalid <= 1'b0;
            vif.drv_cb.wlast  <= 1'b0;
        end
    join

endtask


// ============================================================
// FIFO STRESS: MULTIPLE WRITES
// ============================================================
task do_write_fifo_stress(axi_seq_item tr);

    int unsigned count;

    count = tr.fifo_stress_count;

    if (count == 0)
        count = 12;

    `uvm_info(get_type_name(),
        "FIFO WRITE STRESS STARTED", UVM_LOW)

    vif.drv_cb.bready <= 1'b0;

    fork
        begin
            drive_sideband();

            for (int unsigned i = 0; i < count; i++)
                issue_stress_write(tr, i);
        end

        begin
            repeat (tr.fifo_ready_hold_cycles)
                @(vif.drv_cb);

            vif.drv_cb.bready <= 1'b1;

            for (int unsigned j = 0; j < count; j++) begin
                do @(vif.drv_cb);
                while (vif.drv_cb.bvalid !== 1'b1);
            end

            vif.drv_cb.bready <= 1'b0;
        end
    join

    `uvm_info(get_type_name(),
        "FIFO WRITE STRESS COMPLETED", UVM_LOW)

endtask


// ============================================================
// FIFO STRESS: ISSUE READ REQUEST
// ============================================================
task issue_stress_read(axi_seq_item tr, int unsigned index);

    @(vif.drv_cb);

    vif.drv_cb.arid    <= tr.id + index;
    vif.drv_cb.aruser  <= tr.user;
    vif.drv_cb.araddr  <= tr.addr + (index * 4);
    vif.drv_cb.arlen   <= 8'd0;
    vif.drv_cb.arsize  <= 3'd2;
    vif.drv_cb.arburst <= 2'd1;
    vif.drv_cb.arvalid <= 1'b1;

    do @(vif.drv_cb);
    while (vif.drv_cb.arready !== 1'b1);

    vif.drv_cb.arvalid <= 1'b0;

endtask


// ============================================================
// FIFO STRESS: MULTIPLE READS
// ============================================================
task do_read_fifo_stress(axi_seq_item tr);

    int unsigned count;

    count = tr.fifo_stress_count;

    if (count == 0)
        count = 12;

    `uvm_info(get_type_name(),
        "FIFO READ STRESS STARTED", UVM_LOW)

    vif.drv_cb.rready <= 1'b0;

    fork
        begin
            drive_sideband();

            for (int unsigned i = 0; i < count; i++)
                issue_stress_read(tr, i);
        end

        begin
            repeat (tr.fifo_ready_hold_cycles)
                @(vif.drv_cb);

            vif.drv_cb.rready <= 1'b1;

            for (int unsigned j = 0; j < count; j++) begin
                do @(vif.drv_cb);
                while (vif.drv_cb.rvalid !== 1'b1);
            end

            vif.drv_cb.rready <= 1'b0;
        end
    join

    `uvm_info(get_type_name(),
        "FIFO READ STRESS COMPLETED", UVM_LOW)

endtask
   
endclass
