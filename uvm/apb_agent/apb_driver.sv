
class apb_driver extends uvm_driver #(apb_seq_item);
    `uvm_component_utils(apb_driver)
    virtual apb_if vif;
    bit always_ready = 0;   // 1 = PREADY held high all the time (zero-wait slave)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif))
            `uvm_fatal(get_type_name(), "No APB virtual interface found!")
        void'(uvm_config_db#(bit)::get(this, "", "always_ready", always_ready));
    endfunction

    task run_phase(uvm_phase phase);
        apb_seq_item tr;

        vif.drv_cb.pready  <= 1'b0;
        vif.drv_cb.prdata  <= 32'h0;
        vif.drv_cb.pslverr <= 1'b0;
        wait(vif.PRESETn === 1'b0);
        wait(vif.PRESETn == 1'b1);

        // Special mode: slave is ready BEFORE the request arrives
        if (always_ready) begin
            vif.drv_cb.pready  <= 1'b1;
            vif.drv_cb.prdata  <= 32'hA5A5_5A5A;
            vif.drv_cb.pslverr <= 1'b0;
            forever @(vif.drv_cb);
        end

        forever begin
            // PSEL is always 1 in this RTL, so PENABLE marks a real access
            do @(vif.drv_cb); while (vif.drv_cb.penable !== 1'b1);

            seq_item_port.get_next_item(req);
            tr = req;

            repeat(tr.pready_delay) @(vif.drv_cb);

            vif.drv_cb.pready  <= 1'b1;
            vif.drv_cb.prdata  <= tr.prdata;
            vif.drv_cb.pslverr <= tr.pslverr;
            @(vif.drv_cb);

            vif.drv_cb.pready  <= 1'b0;
            vif.drv_cb.pslverr <= 1'b0;
            seq_item_port.item_done();

            do @(vif.drv_cb); while (vif.drv_cb.penable === 1'b1);
        end
    endtask
endclass
