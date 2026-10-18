 // ============================================================
// BASE SEQUENCE (Parent class for all tests)
// ============================================================
class axi_base_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_base_sequence)

  function new(string name = "axi_base_sequence");
    super.new(name);
  endfunction : new
endclass : axi_base_sequence

// ============================================================
// Test 1: Reset / Smoke Test (Write followed by Read)
// ============================================================
class axi_smoke_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_smoke_sequence)

  function new(string name = "axi_smoke_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Reset/Smoke Test (WRITE then READ)", UVM_LOW)

    // 1. WRITE
    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_1000; 
      wdata    == 32'h1234_5678;
      id       == 16'h0001;
    })

    // 2. READ (from same address)
    `uvm_do_with(req, {
      is_write == 0; 
      addr     == 32'h0000_1000;
      id       == 16'h0002;
    })
  endtask : body
endclass : axi_smoke_sequence

// ============================================================
// Test 2: Single AXI write with APB ready immediately
// ============================================================
class axi_single_wr_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_single_wr_sequence)

  function new(string name = "axi_single_wr_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 2: Single Write", UVM_LOW)

    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_2000 ; 
      wdata    == 32'hA5A5_A5A5;
    })
  endtask : body
endclass : axi_single_wr_sequence

// ============================================================
// Test 3: Single AXI read with APB ready immediately
// ============================================================
class axi_single_rd_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_single_rd_sequence)

  function new(string name = "axi_single_rd_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 3: Single Read", UVM_LOW)

    `uvm_do_with(req, {
      is_write == 0; 
      addr     == 32'h0000_3000;
    })
  endtask : body
endclass : axi_single_rd_sequence

// ============================================================
// Test 4: AXI Write with APB wait states
// ============================================================
class axi_wr_wait_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_wr_wait_sequence)

  function new(string name = "axi_wr_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 4: Write with Wait States", UVM_LOW)

    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_4000;
    })
  endtask : body
endclass : axi_wr_wait_sequence

// ============================================================
// Test 5: AXI Read with APB wait states
// ============================================================
class axi_rd_wait_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_rd_wait_sequence)

  function new(string name = "axi_rd_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 5: Read with Wait States", UVM_LOW)

    `uvm_do_with(req, {
      is_write == 0; 
      addr     == 32'h0000_5000;
    })
  endtask : body
endclass : axi_rd_wait_sequence

// ============================================================
// Test 6: Read with RREADY delayed
// ============================================================
class axi_rd_rready_delay_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_rd_rready_delay_sequence)

  function new(string name = "axi_rd_rready_delay_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 6: Read with RREADY Delay", UVM_LOW)

    `uvm_do_with(req, {
      is_write     == 0; 
      addr         == 32'h0000_6000;
      rready_delay == 3;
    })
  endtask : body
endclass : axi_rd_rready_delay_sequence

// ============================================================
// Test 7: Write with BREADY delayed
// ============================================================
class axi_wr_bready_delay_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_wr_bready_delay_sequence)

  function new(string name = "axi_wr_bready_delay_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 7: Write with BREADY Delay", UVM_LOW)

    `uvm_do_with(req, {
      is_write     == 1; 
      addr         == 32'h0000_7000;
      bready_delay == 3;
    })
  endtask : body
endclass : axi_wr_bready_delay_sequence

// ============================================================
// TEST 8: Read and write presented at the same time
// WHY: To verify DUT priority (ARVALID > AWVALID).
// ============================================================
class axi_rd_wr_priority_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_rd_wr_priority_sequence)

  function new(string name = "axi_rd_wr_priority_sequence"); super.new(name); endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Test 8: Running Read/Write Priority Test", UVM_LOW)
    
    `uvm_do_with(req, {
      is_write        == 1; 
      addr            == 32'h0000_8000;
      simultaneous_rw == 1; // Trigger special driver mode
    })
  endtask
endclass : axi_rd_wr_priority_sequence


// ============================================================

// ============================================================
// Test 9: Back-to-back reads
// ============================================================
class axi_b2b_rd_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_b2b_rd_sequence)

  function new(string name = "axi_b2b_rd_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 9: Back-to-Back Reads", UVM_LOW)

    `uvm_do_with(req, { is_write == 0; addr == 32'h0000_A000; })
    `uvm_do_with(req, { is_write == 0; addr == 32'h0000_A004; })
  endtask : body
endclass : axi_b2b_rd_sequence

// ============================================================
// Test 10: Back-to-back writes
// ============================================================
class axi_b2b_wr_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_b2b_wr_sequence)

  function new(string name = "axi_b2b_wr_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 10: Back-to-Back Writes", UVM_LOW)

    `uvm_do_with(req, { is_write == 1; addr == 32'h0000_B000; wdata == 32'h1111_1111; })
    `uvm_do_with(req, { is_write == 1; addr == 32'h0000_B004; wdata == 32'h2222_2222; })
  endtask : body
endclass : axi_b2b_wr_sequence

// ============================================================
// Test 11: Mixed read/write traffic
// ============================================================
class axi_mixed_rw_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_mixed_rw_sequence)

  function new(string name = "axi_mixed_rw_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 11: Mixed Traffic", UVM_LOW)

    `uvm_do_with(req, { is_write == 1; addr == 32'h0000_C000; })
    `uvm_do_with(req, { is_write == 0; addr == 32'h0000_C004; })
    `uvm_do_with(req, { is_write == 1; addr == 32'h0000_C008; })
    `uvm_do_with(req, { is_write == 0; addr == 32'h0000_C00C; })
  endtask : body
endclass : axi_mixed_rw_sequence

// ============================================================
// Test 12: Different IDs and USER values
// ============================================================
class axi_diff_id_user_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_diff_id_user_sequence)

  function new(string name = "axi_diff_id_user_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 12: Different IDs and USER", UVM_LOW)

    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_D000;
      id       == 16'hABCD;
      user     == 10'h3FF;
    })
  endtask : body
endclass : axi_diff_id_user_sequence

// ============================================================
// Test 13: PSLVERR stimulus test
// ============================================================
class axi_pslverr_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_pslverr_sequence)

  function new(string name = "axi_pslverr_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Running Test 13: PSLVERR Stimulus", UVM_LOW)
    
    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_E000;
    })
  endtask : body
endclass : axi_pslverr_sequence

// ============================================================
// TEST 14: Burst Experiment (Spec check)
// WHY: To prove that the RTL does NOT support burst transfers 
//      (As spec says it only implements single-beat). 
//      We send LEN=3 and WLAST=0 to see how it reacts.
// ============================================================
class axi_burst_exp_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_burst_exp_sequence)

  function new(string name = "axi_burst_exp_sequence"); super.new(name); endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Test 14: Running Burst Experiment (LEN=3)", UVM_LOW)
    
    `uvm_do_with(req, {
      is_write == 1; 
      addr     == 32'h0000_F000;
      len      == 8'd3;       // 4 beats burst
      wlast    == 1'b0;       // Not the last beat
    })
  endtask : body
endclass : axi_burst_exp_sequence

// ============================================================
// RANDOM AXI TRAFFIC (mixed R/W, corner addresses and data)
// ============================================================
// class axi_random_sequence extends axi_base_sequence;
//   `uvm_object_utils(axi_random_sequence)

//   int unsigned num_trans = 300;

//   function new(string name = "axi_random_sequence");
//     super.new(name);
//   endfunction

//   virtual task body();
//     bit        t_wr;
//     bit [31:0] t_addr, t_data;

//     `uvm_info(get_type_name(), $sformatf("Random test: %0d transactions", num_trans), UVM_LOW)

//     repeat (num_trans) begin
//       t_wr = $urandom_range(0, 1);

//       case ($urandom_range(0, 9))
//         0:       t_addr = 32'h0000_0000;
//         1:       t_addr = 32'hFFFF_FFFC;
//         2,3,4:   t_addr = $urandom_range(32'h4, 32'h7FFC)     & 32'hFFFF_FFFC;
//         default: t_addr = $urandom_range(32'h8000, 32'hFFFC) & 32'hFFFF_FFFC;
//       endcase

//       case ($urandom_range(0, 9))
//         0:       t_data = 32'h0000_0000;
//         1:       t_data = 32'hFFFF_FFFF;
//         2:       t_data = 32'hAAAA_AAAA;
//         3:       t_data = 32'h5555_5555;
//         4:       t_data = 32'h0000_0001;
//         5:       t_data = 32'h0000_0002;
//         6:       t_data = 32'h0000_0004;
//         default: t_data = $urandom;
//       endcase
//         `uvm_do_with(req, {
//         is_write == t_wr;
//         addr     == t_addr;
//         wdata    == t_data;
//         id       inside {[16'h0000 : 16'hFFFF]};
//         user     inside {[10'h000  : 10'h3FF]};
//         wstrb    inside {[4'h0 : 4'hF]};
//         size     inside {[3'd0 : 3'd2]};
//         burst    inside {[2'd0 : 2'd2]};
//         aw_delay     inside {[0:4]};
//         w_delay      inside {[0:4]};
//         ar_delay     inside {[0:4]};
//         bready_delay inside {[0:4]};
//         rready_delay inside {[0:4]};
//       })
//     end
//   endtask
// endclass

class axi_random_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_random_sequence)

  int unsigned num_trans = 300;

  function new(string name = "axi_random_sequence");
    super.new(name);
  endfunction

  virtual task body();

    bit        t_wr;
    bit [31:0] t_addr;
    bit [31:0] t_data;
    bit [15:0] t_id;
    bit [9:0]  t_user;
    bit [3:0]  t_strb;
    bit [2:0]  t_size;
    bit [1:0]  t_burst;

    bit [31:0] addr_patterns[8];
    bit [31:0] data_patterns[8];

    addr_patterns[0] = 32'h0000_0000;
    addr_patterns[1] = 32'hFFFF_FFFC;
    addr_patterns[2] = 32'hAAAA_AAA8;
    addr_patterns[3] = 32'h5555_5554;
    addr_patterns[4] = 32'h8000_0000;
    addr_patterns[5] = 32'h7FFF_FFFC;
    addr_patterns[6] = 32'h1234_5678;
    addr_patterns[7] = 32'hEDCB_A984;

    data_patterns[0] = 32'h0000_0000;
    data_patterns[1] = 32'hFFFF_FFFF;
    data_patterns[2] = 32'hAAAA_AAAA;
    data_patterns[3] = 32'h5555_5555;
    data_patterns[4] = 32'h8000_0001;
    data_patterns[5] = 32'h7FFF_FFFE;
    data_patterns[6] = 32'h1234_5678;
    data_patterns[7] = 32'hEDCB_A987;

    `uvm_info(get_type_name(),
      $sformatf("Enhanced random test: %0d transactions", num_trans),
      UVM_LOW)

    for (int i = 0; i < num_trans; i++) begin

      // Default: alternate read and write.
      t_wr = (i % 2 == 0);

      // =====================================================
      // DIRECTED WALKING-ONE DATA PATTERNS
      //
      // Targets:
      // bins walk = {32'h1, 32'h2, 32'h4};
      //
      // First 3 transactions are forced writes.
      // =====================================================

      if (i < 3) begin

        t_wr   = 1'b1;
        t_addr = 32'h0000_0100 + (i * 4);

        case (i)
          0: t_data = 32'h0000_0001;
          1: t_data = 32'h0000_0002;
          2: t_data = 32'h0000_0004;
          default: t_data = 32'h0000_0001;
        endcase

        t_id    = i;
        t_user  = 10'h000;
        t_strb  = 4'hF;
        t_size  = 3'd2;
        t_burst = 2'd1;

        `uvm_info(get_type_name(),
          $sformatf("WALK BIN: WRITE addr=%08h data=%08h",
                    t_addr, t_data),
          UVM_LOW)

      end

      // =====================================================
      // EXISTING DIRECTED TOGGLE PATTERNS
      // =====================================================

      else if (i < 64) begin

        t_addr  = addr_patterns[i % 8];
        t_data  = data_patterns[i % 8];

        t_id    = (i % 4 == 0) ? 16'h0000 :
                  (i % 4 == 1) ? 16'hFFFF :
                  (i % 4 == 2) ? 16'hAAAA : 16'h5555;

        t_user  = (i % 2 == 0) ? 10'h3FF : 10'h000;

        t_strb  = i % 16;
        t_size  = i % 3;
        t_burst = i % 3;

      end

      // =====================================================
      // EXISTING RANDOM TRAFFIC
      // =====================================================

      else begin

        case ($urandom_range(0, 9))

          0:       t_addr = 32'h0000_0000;

          1:       t_addr = 32'hFFFF_FFFC;

          2,3,4:   t_addr =
                     $urandom_range(32'h4, 32'h7FFC)
                     & 32'hFFFF_FFFC;

          default: t_addr =
                     $urandom_range(32'h8000, 32'hFFFC)
                     & 32'hFFFF_FFFC;

        endcase

        t_data  = $urandom;
        t_id    = $urandom;
        t_user  = $urandom_range(0, 1023);
        t_strb  = $urandom_range(0, 15);
        t_size  = $urandom_range(0, 2);
        t_burst = $urandom_range(0, 2);

      end

      // =====================================================
      // SEND AXI TRANSACTION
      // =====================================================

      `uvm_do_with(req, {

        is_write == t_wr;

        addr     == t_addr;
        wdata    == t_data;
        id       == t_id;
        user     == t_user;
        wstrb    == t_strb;

        len      == 0;

        size     == t_size;
        burst    == t_burst;

        simultaneous_rw == 0;

        aw_delay     inside {[0:4]};
        w_delay      inside {[0:4]};
        ar_delay     inside {[0:4]};
        bready_delay inside {[0:4]};
        rready_delay inside {[0:4]};

      })

    end

    `uvm_info(get_type_name(),
      "Enhanced random sequence completed", UVM_LOW)

  endtask

endclass


// ============================================================
// AW FIRST, W LATER (write address without write data)
// ============================================================
class axi_aw_then_w_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_aw_then_w_sequence)

  function new(string name = "axi_aw_then_w_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Test 16: AW first, W 6 cycles later", UVM_LOW)
    `uvm_do_with(req, {
      is_write == 1;
      addr     == 32'h0000_9000;
      wdata    == 32'h1234_ABCD;
      aw_delay == 0;
      w_delay  == 6;
    })
  endtask
endclass

class axi_fifo_backpressure_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_fifo_backpressure_sequence)

  function new(string name = "axi_fifo_backpressure_sequence");
    super.new(name);
  endfunction

virtual task body();

    `uvm_info(get_type_name(),
        "FIFO BACKPRESSURE STRESS TEST STARTED",
        UVM_LOW)

    // --------------------------------------------------------
    // PHASE 1: MULTIPLE OUTSTANDING WRITES
    // --------------------------------------------------------
    `uvm_info(get_type_name(),
        "PHASE 1: FIFO WRITE STRESS",
        UVM_LOW)

    `uvm_do_with(req, {
        is_write               == 1'b1;
        fifo_stress_mode       == 1'b1;
        fifo_stress_count      == 12;
        fifo_ready_hold_cycles == 20;

        addr                   == 32'h0000_D000;
        wdata                  == 32'hAAAA_5555;
        id                     == 16'h0001;
        user                   == 10'h000;
        len                    == 8'd0;
        size                   == 3'd2;
        burst                  == 2'd1;
        wstrb                  == 4'hF;
        wlast                  == 1'b1;
        simultaneous_rw        == 1'b0;
    })

    // --------------------------------------------------------
    // PHASE 2: MULTIPLE OUTSTANDING READS
    // --------------------------------------------------------
    `uvm_info(get_type_name(),
        "PHASE 2: FIFO READ STRESS",
        UVM_LOW)

    `uvm_do_with(req, {
        is_write               == 1'b0;
        fifo_stress_mode       == 1'b1;
        fifo_stress_count      == 12;
        fifo_ready_hold_cycles == 20;

        addr                   == 32'h0000_E000;
        id                     == 16'h0002;
        user                   == 10'h3FF;
        len                    == 8'd0;
        size                   == 3'd2;
        burst                  == 2'd1;
        simultaneous_rw        == 1'b0;
    })

    `uvm_info(get_type_name(),
        "FIFO BACKPRESSURE STRESS TEST COMPLETED",
        UVM_LOW)

endtask : body

endclass : axi_fifo_backpressure_sequence
class axi_toggle_boost_sequence extends axi_base_sequence;
  `uvm_object_utils(axi_toggle_boost_sequence)

  function new(string name = "axi_toggle_boost_sequence");
    super.new(name);
  endfunction

  virtual task body();
    bit [31:0] patterns[8] = '{
      32'h00000000, 32'hFFFFFFFF,
      32'hAAAAAAAA, 32'h55555555,
      32'h80000001, 32'h7FFFFFFE,
      32'h12345678, 32'hEDCBA987
    };

    `uvm_info(get_type_name(),
      "TOGGLE BOOST SEQUENCE STARTED", UVM_LOW)

    for (int i = 0; i < 32; i++) begin
      `uvm_do_with(req, {
        is_write        == 1'b1;
        addr            == (32'h00001000 + (i * 4));
        wdata           == patterns[i % 8];
        id              == ((i % 2) ? 16'hFFFF : 16'h0000);
        user            == ((i % 2) ? 10'h3FF : 10'h000);
        wstrb           == ((i % 2) ? 4'hF : 4'h5);
        len             == 0;
        simultaneous_rw == 0;
        bready_delay    == (i % 3);
      })

      `uvm_do_with(req, {
        is_write        == 1'b0;
        addr            == (32'h00001000 + (i * 4));
        id              == ((i % 2) ? 16'h0000 : 16'hFFFF);
        user            == ((i % 2) ? 10'h000 : 10'h3FF);
        len             == 0;
        simultaneous_rw == 0;
        rready_delay    == (i % 3);
      })
    end
  endtask
endclass
