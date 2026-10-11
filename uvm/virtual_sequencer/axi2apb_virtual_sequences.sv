`ifndef AXI2APB_VIRTUAL_SEQUENCES_SV
`define AXI2APB_VIRTUAL_SEQUENCES_SV

//============================================================
// AXI2APB VIRTUAL BASE SEQUENCE
//============================================================
class axi2apb_virtual_base_sequence extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils(axi2apb_virtual_base_sequence)

  axi2apb_virtual_sequencer vseqr;

  function new(string name = "axi2apb_virtual_base_sequence");
    super.new(name);
  endfunction

  virtual task body();

    `uvm_info(get_type_name(),
              "Virtual Base Sequence Started",
              UVM_LOW)

    if (!$cast(vseqr, m_sequencer)) begin
      `uvm_fatal(get_type_name(),
                 "Virtual Sequencer Cast Failed")
    end

    if (vseqr.axi_seqr == null)
      `uvm_fatal(get_type_name(), "AXI Sequencer is NULL")

    if (vseqr.apb_seqr == null)
      `uvm_fatal(get_type_name(), "APB Sequencer is NULL")

  endtask

endclass


//============================================================
// TEST 1: RESET / SMOKE
//============================================================
class axi2apb_smoke_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_smoke_vseq)

  function new(string name = "axi2apb_smoke_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_smoke_sequence        axi_seq;
    apb_configurable_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "SMOKE Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_smoke_sequence::type_id::create("axi_seq");
    apb_seq = apb_configurable_sequence::type_id::create("apb_seq");

    apb_seq.num_transfers = 2;
    apb_seq.configured_wait_cycles = 0;
    apb_seq.configured_rdata = 32'h1234_ABCD;
    apb_seq.configured_slverr = 0;

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "SMOKE Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 2: SINGLE WRITE - IMMEDIATE PREADY
//============================================================
class axi2apb_single_write_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_single_write_vseq)

  function new(string name = "axi2apb_single_write_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_single_write_sequence axi_seq;
    apb_immediate_ready_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Single Write Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_single_write_sequence::type_id::create("axi_seq");
    apb_seq = apb_immediate_ready_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Single Write Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 3: SINGLE READ - IMMEDIATE PREADY
//============================================================
class axi2apb_single_read_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_single_read_vseq)

  function new(string name = "axi2apb_single_read_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_single_read_sequence axi_seq;
    apb_immediate_ready_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Single Read Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_single_read_sequence::type_id::create("axi_seq");
    apb_seq = apb_immediate_ready_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Single Read Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 4: WRITE WITH APB WAIT STATES
//============================================================
class axi2apb_write_wait_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_write_wait_vseq)

  function new(string name = "axi2apb_write_wait_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_write_wait_sequence axi_seq;
    apb_write_wait_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Write Wait Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_write_wait_sequence::type_id::create("axi_seq");
    apb_seq = apb_write_wait_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Write Wait Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 5: READ WITH APB WAIT STATES
//============================================================
class axi2apb_read_wait_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_read_wait_vseq)

  function new(string name = "axi2apb_read_wait_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_read_wait_sequence axi_seq;
    apb_read_wait_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Read Wait Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_read_wait_sequence::type_id::create("axi_seq");
    apb_seq = apb_read_wait_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Read Wait Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 6: DELAYED RREADY
//============================================================
class axi2apb_delayed_rready_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_delayed_rready_vseq)

  function new(string name = "axi2apb_delayed_rready_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_delayed_rready_sequence axi_seq;
    apb_delayed_rready_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Delayed RREADY Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_delayed_rready_sequence::type_id::create("axi_seq");
    apb_seq = apb_delayed_rready_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Delayed RREADY Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 7: DELAYED BREADY
//============================================================
class axi2apb_delayed_bready_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_delayed_bready_vseq)

  function new(string name = "axi2apb_delayed_bready_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_delayed_bready_sequence axi_seq;
    apb_delayed_bready_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Delayed BREADY Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_delayed_bready_sequence::type_id::create("axi_seq");
    apb_seq = apb_delayed_bready_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Delayed BREADY Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 8: SIMULTANEOUS READ AND WRITE
//============================================================
class axi2apb_simultaneous_rw_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_simultaneous_rw_vseq)

  function new(string name = "axi2apb_simultaneous_rw_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_simultaneous_rw_sequence axi_seq;
    apb_simultaneous_rw_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Simultaneous RW Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_simultaneous_rw_sequence::type_id::create("axi_seq");
    apb_seq = apb_simultaneous_rw_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Simultaneous RW Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 9: BACK-TO-BACK READS
//============================================================
class axi2apb_back_to_back_reads_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_back_to_back_reads_vseq)

  function new(string name = "axi2apb_back_to_back_reads_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_back_to_back_reads_sequence axi_seq;
    apb_back_to_back_reads_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Back-to-Back Reads Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_back_to_back_reads_sequence::type_id::create("axi_seq");
    apb_seq = apb_back_to_back_reads_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Back-to-Back Reads Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 10: BACK-TO-BACK WRITES
//============================================================
class axi2apb_back_to_back_writes_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_back_to_back_writes_vseq)

  function new(string name = "axi2apb_back_to_back_writes_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_back_to_back_writes_sequence axi_seq;
    apb_back_to_back_writes_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Back-to-Back Writes Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_back_to_back_writes_sequence::type_id::create("axi_seq");
    apb_seq = apb_back_to_back_writes_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Back-to-Back Writes Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 11: MIXED READ / WRITE TRAFFIC
//============================================================
class axi2apb_mixed_traffic_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_mixed_traffic_vseq)

  function new(string name = "axi2apb_mixed_traffic_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_mixed_traffic_sequence axi_seq;
    apb_mixed_traffic_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "Mixed Traffic Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_mixed_traffic_sequence::type_id::create("axi_seq");
    apb_seq = apb_mixed_traffic_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "Mixed Traffic Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 12: DIFFERENT IDs AND USER VALUES
//============================================================
class axi2apb_id_user_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_id_user_vseq)

  function new(string name = "axi2apb_id_user_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_id_user_sequence axi_seq;
    apb_id_user_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "ID/USER Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_id_user_sequence::type_id::create("axi_seq");
    apb_seq = apb_id_user_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "ID/USER Virtual Sequence Completed", UVM_LOW)

  endtask

endclass


//============================================================
// TEST 13: PSLVERR STIMULUS
//============================================================
class axi2apb_pslverr_vseq extends axi2apb_virtual_base_sequence;

  `uvm_object_utils(axi2apb_pslverr_vseq)

  function new(string name = "axi2apb_pslverr_vseq");
    super.new(name);
  endfunction

  virtual task body();

    axi_pslverr_sequence axi_seq;
    apb_pslverr_sequence apb_seq;

    super.body();

    `uvm_info(get_type_name(), "PSLVERR Virtual Sequence Started", UVM_LOW)

    axi_seq = axi_pslverr_sequence::type_id::create("axi_seq");
    apb_seq = apb_pslverr_sequence::type_id::create("apb_seq");

    fork
      axi_seq.start(vseqr.axi_seqr);
      apb_seq.start(vseqr.apb_seqr);
    join

    `uvm_info(get_type_name(), "PSLVERR Virtual Sequence Completed", UVM_LOW)

  endtask

endclass

`endif