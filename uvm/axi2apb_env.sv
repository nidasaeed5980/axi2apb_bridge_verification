



// class axi2apb_env extends uvm_env;
//     `uvm_component_utils(axi2apb_env)

//     axi_agent           axi_agnt;
//     apb_agent           apb_agnt;
//     axi2apb_vseqr       vseqr;
//     axi2apb_scoreboard  scb;
//     axi2apb_cov         cov;

//     function new(string name, uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         axi_agnt = axi_agent::type_id::create("axi_agnt", this);
//         apb_agnt = apb_agent::type_id::create("apb_agnt", this);
//         vseqr    = axi2apb_vseqr::type_id::create("vseqr", this);
//         scb      = axi2apb_scoreboard::type_id::create("scb", this);
//         cov      = axi2apb_cov::type_id::create("cov", this);
//     endfunction

//     function void connect_phase(uvm_phase phase);
//         super.connect_phase(phase);
        
//         // 1. Virtual Sequencer connections
//         vseqr.axi_sqr = axi_agnt.sqr;
//         vseqr.apb_sqr = apb_agnt.sqr;

//         // 2. Connect Monitors to Scoreboard
//         axi_agnt.mon.ap.connect(scb.axi_imp);
//         apb_agnt.mon.ap.connect(scb.apb_imp);

//         // 3. Connect Monitors to Coverage
//         axi_agnt.mon.ap.connect(cov.axi_imp); // Agar cov mein axi_imp hai
//         apb_agnt.mon.ap.connect(cov.apb_imp); // Agar cov mein apb_imp hai
        
//         `uvm_info("ENV", "All connections made successfully!", UVM_LOW)
//     endfunction
// endclass


class axi2apb_env extends uvm_env;
    `uvm_component_utils(axi2apb_env)

    axi_agent           axi_agnt;
    apb_agent           apb_agnt;
    axi2apb_vseqr       vseqr;
    axi2apb_scoreboard  scb;
    axi2apb_cov         cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agnt = axi_agent::type_id::create("axi_agnt", this);
        apb_agnt = apb_agent::type_id::create("apb_agnt", this);
        vseqr    = axi2apb_vseqr::type_id::create("vseqr", this);
        scb      = axi2apb_scoreboard::type_id::create("scb", this);
        cov      = axi2apb_cov::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // 1. Virtual Sequencer connections
        vseqr.axi_sqr = axi_agnt.sqr;
        vseqr.apb_sqr = apb_agnt.sqr;

        // 2. Scoreboard connections
        axi_agnt.mon.ap.connect(scb.axi_imp);
        apb_agnt.mon.ap.connect(scb.apb_imp);

        // 3. Coverage connections (Using Custom Imports)
        axi_agnt.mon.ap.connect(cov.axi_imp); 
        apb_agnt.mon.ap.connect(cov.apb_imp); 
        
        `uvm_info("ENV", "All connections made successfully!", UVM_LOW)
    endfunction
endclass