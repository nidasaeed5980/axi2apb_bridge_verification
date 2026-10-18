class axi_seq_item extends uvm_sequence_item;

    rand bit        is_write;
    rand bit [31:0] addr;       
    rand bit [15:0] id;         
    rand bit [9:0]  user;       
    rand bit [31:0] wdata;      
    rand bit [3:0]  wstrb;      
     
    // --- NEW FIELDS FOR BURST EXPERIMENT ---
    rand bit [7:0]  len;        // Burst Length (0 = single beat, >0 = burst)
    rand bit [2:0]  size;       // 3'b010 = 4 bytes
    rand bit [1:0]  burst;      // 2'b01 = INCR
    rand bit        wlast;      // Last beat indicator
   
    rand bit simultaneous_rw; // If 1, driver sends AW and AR together
    // FIFO coverage stress controls
    rand bit          fifo_stress_mode;
    rand int unsigned fifo_stress_count;
    rand int unsigned fifo_ready_hold_cycles;
    // Response Fields

    bit [31:0] rdata;           
    bit [1:0]  resp;            
    bit        rlast;
    // Timing / Delay Fields
    rand int unsigned aw_delay;
    rand int unsigned w_delay;
    rand int unsigned ar_delay;
    rand int unsigned bready_delay;
    rand int unsigned rready_delay;

    // Default Constraints (Safe values for normal tests)
    constraint c_defaults {
        soft addr[1:0] == 2'b00; 
        soft wstrb == 4'hF;  
        soft len  == 8'd0;  // Default is single beat
        soft size == 3'b010;
        soft burst == 2'b01;
        soft wlast == 1'b1;
        
        soft id   inside {[16'h0000 : 16'h000F]};
        soft user inside {[10'h000 : 10'h00F]};
        soft aw_delay     == 0;
        soft w_delay      == 0;
        soft ar_delay     == 0;
        soft bready_delay == 0;
        soft rready_delay == 0;
        soft simultaneous_rw == 1'b0;
        soft fifo_stress_mode == 1'b0;
        soft fifo_stress_count == 12;
        soft fifo_ready_hold_cycles == 20;
    }

    `uvm_object_utils_begin(axi_seq_item)
        `uvm_field_int(is_write, UVM_ALL_ON)
        `uvm_field_int(addr,     UVM_ALL_ON)
        `uvm_field_int(len,      UVM_ALL_ON)
        `uvm_field_int(wdata,    UVM_ALL_ON)
        `uvm_field_int(wlast,    UVM_ALL_ON)
        `uvm_field_int(rdata,    UVM_ALL_ON)
        `uvm_field_int(fifo_stress_mode, UVM_ALL_ON)
        `uvm_field_int(fifo_stress_count, UVM_ALL_ON)
        `uvm_field_int(fifo_ready_hold_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction


    function string convert2string();
        return $sformatf("[%s] Addr=0x%08h ID=0x%04h LEN=%0d WLAST=%0b WData=0x%08h RData=0x%08h Resp=%0b", 
                         is_write ? "WRITE" : "READ", addr, id, len, wlast, wdata, rdata, resp);
    endfunction
endclass


