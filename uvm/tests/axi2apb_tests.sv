`ifndef AXI2APB_TESTS_SV
`define AXI2APB_TESTS_SV

//------------------------------------------------------------
// TEST 1: SMOKE TEST
//------------------------------------------------------------
class axi2apb_smoke_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_smoke_test)

  function new(string name = "axi2apb_smoke_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "SMOKE BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_smoke_vseq vseq;

    `uvm_info(get_type_name(), "SMOKE RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_smoke_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_smoke_test


//------------------------------------------------------------
// TEST 2: SINGLE WRITE
//------------------------------------------------------------
class axi2apb_single_write_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_single_write_test)

  function new(string name = "axi2apb_single_write_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "SINGLE WRITE BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_single_write_vseq vseq;

    `uvm_info(get_type_name(), "SINGLE WRITE RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_single_write_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_single_write_test


//------------------------------------------------------------
// TEST 3: SINGLE READ
//------------------------------------------------------------
class axi2apb_single_read_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_single_read_test)

  function new(string name = "axi2apb_single_read_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "SINGLE READ BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_single_read_vseq vseq;

    `uvm_info(get_type_name(), "SINGLE READ RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_single_read_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_single_read_test


//------------------------------------------------------------
// TEST 4: WRITE WITH APB WAIT STATES
//------------------------------------------------------------
class axi2apb_write_wait_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_write_wait_test)

  function new(string name = "axi2apb_write_wait_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "WRITE WAIT BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_write_wait_vseq vseq;

    `uvm_info(get_type_name(), "WRITE WAIT RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_write_wait_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_write_wait_test


//------------------------------------------------------------
// TEST 5: READ WITH APB WAIT STATES
//------------------------------------------------------------
class axi2apb_read_wait_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_read_wait_test)

  function new(string name = "axi2apb_read_wait_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "READ WAIT BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_read_wait_vseq vseq;

    `uvm_info(get_type_name(), "READ WAIT RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_read_wait_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_read_wait_test


//------------------------------------------------------------
// TEST 6: DELAYED RREADY
//------------------------------------------------------------
class axi2apb_delayed_rready_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_delayed_rready_test)

  function new(string name = "axi2apb_delayed_rready_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "DELAYED RREADY BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_delayed_rready_vseq vseq;

    `uvm_info(get_type_name(), "DELAYED RREADY RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_delayed_rready_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_delayed_rready_test


//------------------------------------------------------------
// TEST 7: DELAYED BREADY
//------------------------------------------------------------
class axi2apb_delayed_bready_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_delayed_bready_test)

  function new(string name = "axi2apb_delayed_bready_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "DELAYED BREADY BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_delayed_bready_vseq vseq;

    `uvm_info(get_type_name(), "DELAYED BREADY RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_delayed_bready_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(1);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_delayed_bready_test


//------------------------------------------------------------
// TEST 8: SIMULTANEOUS READ AND WRITE
//------------------------------------------------------------
class axi2apb_simultaneous_rw_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_simultaneous_rw_test)

  function new(string name = "axi2apb_simultaneous_rw_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "SIMULTANEOUS RW BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_simultaneous_rw_vseq vseq;

    `uvm_info(get_type_name(), "SIMULTANEOUS RW RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_simultaneous_rw_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_simultaneous_rw_test


//------------------------------------------------------------
// TEST 9: BACK-TO-BACK READS
//------------------------------------------------------------
class axi2apb_back_to_back_reads_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_back_to_back_reads_test)

  function new(string name = "axi2apb_back_to_back_reads_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "BACK-TO-BACK READS BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_back_to_back_reads_vseq vseq;

    `uvm_info(get_type_name(), "BACK-TO-BACK READS RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_back_to_back_reads_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_back_to_back_reads_test


//------------------------------------------------------------
// TEST 10: BACK-TO-BACK WRITES
//------------------------------------------------------------
class axi2apb_back_to_back_writes_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_back_to_back_writes_test)

  function new(string name = "axi2apb_back_to_back_writes_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "BACK-TO-BACK WRITES BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_back_to_back_writes_vseq vseq;

    `uvm_info(get_type_name(), "BACK-TO-BACK WRITES RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_back_to_back_writes_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_back_to_back_writes_test


//------------------------------------------------------------
// TEST 11: MIXED TRAFFIC
//------------------------------------------------------------
class axi2apb_mixed_traffic_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_mixed_traffic_test)

  function new(string name = "axi2apb_mixed_traffic_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "MIXED TRAFFIC BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_mixed_traffic_vseq vseq;

    `uvm_info(get_type_name(), "MIXED TRAFFIC RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_mixed_traffic_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    // Set N to the actual number of transactions
    // generated by the mixed traffic virtual sequence.
    // Example below assumes 4 transactions.
    wait_for_completion(4);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_mixed_traffic_test


//------------------------------------------------------------
// TEST 12: DIFFERENT AXI ID AND USER VALUES
//------------------------------------------------------------
class axi2apb_id_user_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_id_user_test)

  function new(string name = "axi2apb_id_user_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "ID USER BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_id_user_vseq vseq;

    `uvm_info(get_type_name(), "ID USER RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_id_user_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_id_user_test


//------------------------------------------------------------
// TEST 13: APB PSLVERR
//------------------------------------------------------------
class axi2apb_pslverr_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_pslverr_test)

  function new(string name = "axi2apb_pslverr_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "PSLVERR BUILD PHASE", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    axi2apb_pslverr_vseq vseq;

    `uvm_info(get_type_name(), "PSLVERR RUN PHASE", UVM_LOW)

    phase.raise_objection(this);

    vseq = axi2apb_pslverr_vseq::type_id::create("vseq");
    vseq.start(env.vseqr);

    wait_for_completion(2);

    phase.drop_objection(this);
  endtask : run_phase

endclass : axi2apb_pslverr_test

`endif