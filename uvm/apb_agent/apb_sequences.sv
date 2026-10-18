 // ============================================================
// BASE APB SEQUENCE
// All APB sequences inherit from this base class.
// ============================================================
class apb_base_sequence extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_base_sequence)

  function new(string name = "apb_base_sequence");
    super.new(name);
  endfunction : new
endclass : apb_base_sequence

// ============================================================
// SEQUENCE 1: STANDARD RESPONSE
// Test: Test 1 (Smoke), Test 2 (Single Write), Test 3 (Single Read)
// Why: APB Slave responds immediately (0 wait states) with no error.
// ============================================================
class apb_std_response_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_std_response_sequence)
  
  function new(string name = "apb_std_response_sequence"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Standard Response (0 Wait States)", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 0;           // No wait states (immediate PREADY)
      pslverr      == 1'b0;        // No error
      prdata       == 32'hCAFE_BABE; // Default read data
    })
  endtask
endclass

// ============================================================
// SEQUENCE 2: WAIT STATES
// Test: Test 4 (Write with wait states), Test 5 (Read with wait states)
// Why: APB Slave is slow. It takes 5 clock cycles before asserting PREADY.
//      DUT must wait without corrupting data.
// ============================================================
class apb_wait_state_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_wait_state_sequence)
  
  function new(string name = "apb_wait_state_sequence"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Injecting Wait States (Delay = 5)", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 5;           // Wait 5 clock cycles before PREADY
      pslverr      == 1'b0;        // No error
      prdata       == 32'hCAFE_BABE;
    })
  endtask
endclass

// ============================================================
// SEQUENCE 3: ERROR INJECTION
// Test: Test 13 (PSLVERR stimulus)
// Why: To verify if DUT propagates APB error to AXI side.
//      Spec says DUT ignores PSLVERR (BRESP stays OKAY).
// ============================================================
class apb_error_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_error_sequence)
  
  function new(string name = "apb_error_sequence"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Injecting PSLVERR = 1", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 0;           // No wait state
      pslverr      == 1'b1;        // ERROR is injected here
      prdata       == 32'hDEAD_DEAD;
    })
  endtask
endclass

// ============================================================
// SEQUENCE 4: ALL ZERO DATA
// Test: Random/Data pattern coverage
// Why: To test if DUT handles zero data correctly (boundary case).
// ============================================================
class apb_all_zero_data_seq extends apb_base_sequence;
  `uvm_object_utils(apb_all_zero_data_seq)
  
  function new(string name = "apb_all_zero_data_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Returning All-Zero Data", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 0; 
      pslverr      == 1'b0; 
      prdata       == 32'h0000_0000; // All zeros
    })
  endtask
endclass

// ============================================================
// SEQUENCE 5: ALL ONE DATA
// Test: Random/Data pattern coverage
// Why: To test if DUT handles all-one data correctly (boundary case).
// ============================================================
class apb_all_one_data_seq extends apb_base_sequence;
  `uvm_object_utils(apb_all_one_data_seq)
  
  function new(string name = "apb_all_one_data_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Returning All-One Data", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 0; 
      pslverr      == 1'b0; 
      prdata       == 32'hFFFF_FFFF; // All ones
    })
  endtask
endclass

// ============================================================
// SEQUENCE 6: ALTERNATING DATA
// Test: Random/Data pattern coverage
// Why: To test if DUT handles alternating bits correctly.
// ============================================================
class apb_alt_data_seq extends apb_base_sequence;
  `uvm_object_utils(apb_alt_data_seq)
  
  function new(string name = "apb_alt_data_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Returning Alternating Data", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 0; 
      pslverr      == 1'b0; 
      prdata       == 32'hAAAA_AAAA; // Alternating pattern
    })
  endtask
endclass

// ============================================================
// SEQUENCE 7: DELAYED READY (Backpressure)
// Test: Test 6 (RREADY delay), Test 7 (BREADY delay)
// Why: To verify DUT behavior when APB slave takes a small delay.
// ============================================================
class apb_delayed_ready_seq extends apb_base_sequence;
  `uvm_object_utils(apb_delayed_ready_seq)
  
  function new(string name = "apb_delayed_ready_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Small Delay (2 cycles)", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 2;    // Small delay
      pslverr      == 1'b0; 
      prdata       == 32'hCAFE_BABE;
    })
  endtask
endclass

// ============================================================
// SEQUENCE 8: TIMEOUT (Stress)
// Test: Timeout / Stress test
// Why: PREADY never comes. This tests if DUT hangs or times out.
// ============================================================
class apb_timeout_seq extends apb_base_sequence;
  `uvm_object_utils(apb_timeout_seq)
  
  function new(string name = "apb_timeout_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Triggering Timeout (Never Ready)", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay == 1000;   // Very long delay (simulates hang)
      pslverr      == 1'b0; 
      prdata       == 32'hCAFE_BABE;
    })
  endtask
endclass

// ============================================================
// SEQUENCE 9: RANDOM RESPONSE
// Test: Random regression tests
// Why: Random wait states to stress test the DUT.
// ============================================================
class apb_random_response_seq extends apb_base_sequence;
  `uvm_object_utils(apb_random_response_seq)
  
  function new(string name = "apb_random_response_seq"); 
    super.new(name); 
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "APB: Random Response", UVM_LOW)
    
    `uvm_do_with(req, { 
      pready_delay inside {[0:5]};  // Random wait states
      pslverr == 1'b0; 
    })
  endtask
endclass

// ============================================================
// RANDOM APB RESPONSE (wait states 0..10, occasional PSLVERR)
// ============================================================
// class apb_random_response_sequence extends apb_base_sequence;
//   `uvm_object_utils(apb_random_response_sequence)

//   function new(string name = "apb_random_response_sequence");
//     super.new(name);
//   endfunction

//   virtual task body();
//     `uvm_do_with(req, {
//       pready_delay dist {0 := 5, 1 := 2, [2:10] :/ 3};
//       pslverr      dist {1'b0 := 9, 1'b1 := 1};
//     })
//   endtask
// endclass
class apb_random_response_sequence extends apb_base_sequence;
  `uvm_object_utils(apb_random_response_sequence)

  function new(string name = "apb_random_response_sequence");
    super.new(name);
  endfunction

  virtual task body();
    int unsigned t_wait;
    bit          t_err;

    case ($urandom_range(0, 9))
      0,1,2,3,4: t_wait = 0;
      5,6:       t_wait = 1;
      default:   t_wait = $urandom_range(2, 10);
    endcase
    t_err = ($urandom_range(0, 9) == 0);   // ~10% PSLVERR

    `uvm_do_with(req, {
      pready_delay == t_wait;
      pslverr      == t_err;
    })
  endtask
endclass
class apb_fifo_backpressure_sequence extends apb_base_sequence;

  `uvm_object_utils(apb_fifo_backpressure_sequence)

  function new(string name = "apb_fifo_backpressure_sequence");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(),
      "APB BACKPRESSURE: PREADY delayed 8 cycles",
      UVM_LOW)

    `uvm_do_with(req, {
      pready_delay == 8;
      pslverr      == 0;
      prdata       == 32'hCAFE_BABE;
    })

  endtask : body

endclass : apb_fifo_backpressure_sequence
