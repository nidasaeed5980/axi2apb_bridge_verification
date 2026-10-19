
class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if vif;
    uvm_analysis_port #(apb_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal(get_type_name(), "No APB virtual interface found!")
    endfunction

    task run_phase(uvm_phase phase);
        apb_seq_item tr;
        int unsigned wait_cnt;

        wait(vif.PRESETn == 1'b1);
        wait_cnt = 0;

        forever begin
            @(vif.mon_cb);

            // A transfer completes when PENABLE && PREADY (PSEL is always 1 in this RTL)
            if (vif.mon_cb.penable === 1'b1 && vif.mon_cb.pready === 1'b1) begin
                tr = apb_seq_item::type_id::create("mon_apb_tr");
                tr.paddr        = vif.mon_cb.paddr;
                tr.pwrite       = vif.mon_cb.pwrite;
                tr.pwdata       = vif.mon_cb.pwdata;
                tr.prdata       = vif.mon_cb.prdata;
                tr.pslverr      = vif.mon_cb.pslverr;
                // first PENABLE cycle is the normal setup cycle, so it is not a wait state
                tr.pready_delay = (wait_cnt > 0) ? wait_cnt - 1 : 0;

                `uvm_info(get_type_name(), $sformatf("APB Captured: %s", tr.convert2string()), UVM_LOW)
                ap.write(tr);
                wait_cnt = 0;
            end
            else if (vif.mon_cb.penable === 1'b1) begin
                wait_cnt++;   // request pending but PREADY still low
            end
            else begin
                wait_cnt = 0;
            end
        end
    endtask
endclass
