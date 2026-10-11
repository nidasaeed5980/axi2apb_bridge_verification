`ifndef AXI_SEQUENCES_SV
`define AXI_SEQUENCES_SV

//============================================================
// AXI BASE SEQUENCE
//============================================================
class axi_base_sequence extends uvm_sequence #(axi_seq_item);

  `uvm_object_utils(axi_base_sequence)

  function new(string name = "axi_base_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Base Sequence Body Executed",
              UVM_LOW)

  endtask : body

endclass : axi_base_sequence


//============================================================
// 1. AXI RESET / SMOKE SEQUENCE
//
// Sends one write and one read after reset.
// Actual reset generation belongs to the testbench/test.
//============================================================
class axi_smoke_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_smoke_sequence)

  function new(string name = "axi_smoke_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Smoke Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_WRITE;
      addr             == 32'h0000_1000;
      data             == 32'h1234_ABCD;
      id               == 16'h0001;
      user             == 10'h001;
      aw_delay         == 0;
      w_delay          == 0;
      resp_ready_delay == 0;
    })

    `uvm_do_with(req, {
      op               == AXI_READ;
      addr             == 32'h0000_1000;
      id               == 16'h0002;
      user             == 10'h002;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI Smoke Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_smoke_sequence


//============================================================
// 2. SINGLE AXI WRITE SEQUENCE
//============================================================
class axi_single_write_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_single_write_sequence)

  function new(string name = "axi_single_write_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Single Write Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_WRITE;
      addr             == 32'h0000_1000;
      data             == 32'hA5A5_5A5A;
      id               == 16'h0011;
      user             == 10'h011;
      aw_delay         == 0;
      w_delay          == 0;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI Single Write Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_single_write_sequence


//============================================================
// 3. SINGLE AXI READ SEQUENCE
//============================================================
class axi_single_read_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_single_read_sequence)

  function new(string name = "axi_single_read_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Single Read Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_READ;
      addr             == 32'h0000_1000;
      id               == 16'h0012;
      user             == 10'h012;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI Single Read Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_single_read_sequence


//============================================================
// 4. AXI WRITE WITH APB WAIT STATES
//
// APB wait cycles are controlled by APB sequences.
//============================================================
class axi_write_wait_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_write_wait_sequence)

  function new(string name = "axi_write_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Write Wait Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_WRITE;
      addr             == 32'h0000_2000;
      data             == 32'hDEAD_BEEF;
      id               == 16'h0021;
      user             == 10'h021;
      aw_delay         == 0;
      w_delay          == 0;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI Write Wait Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_write_wait_sequence


//============================================================
// 5. AXI READ WITH APB WAIT STATES
//============================================================
class axi_read_wait_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_read_wait_sequence)

  function new(string name = "axi_read_wait_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Read Wait Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_READ;
      addr             == 32'h0000_2000;
      id               == 16'h0022;
      user             == 10'h022;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI Read Wait Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_read_wait_sequence


//============================================================
// 6. AXI READ WITH DELAYED RREADY
//============================================================
class axi_delayed_rready_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_delayed_rready_sequence)

  function new(string name = "axi_delayed_rready_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Delayed RREADY Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_READ;
      addr             == 32'h0000_3000;
      id               == 16'h0031;
      user             == 10'h031;
      resp_ready_delay == 5;
    })

    `uvm_info(get_type_name(),
              "AXI Delayed RREADY Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_delayed_rready_sequence


//============================================================
// 7. AXI WRITE WITH DELAYED BREADY
//============================================================
class axi_delayed_bready_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_delayed_bready_sequence)

  function new(string name = "axi_delayed_bready_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Delayed BREADY Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_WRITE;
      addr             == 32'h0000_3004;
      data             == 32'hCAFE_BABE;
      id               == 16'h0032;
      user             == 10'h032;
      aw_delay         == 0;
      w_delay          == 0;
      resp_ready_delay == 5;
    })

    `uvm_info(get_type_name(),
              "AXI Delayed BREADY Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_delayed_bready_sequence


//============================================================
// 8. SIMULTANEOUS AXI READ AND WRITE
//
// Both requests are submitted concurrently.
// Exact same-cycle presentation must be checked using
// the AXI monitor and coordinated by the virtual test.
//============================================================
class axi_simultaneous_rw_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_simultaneous_rw_sequence)

  function new(string name = "axi_simultaneous_rw_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Simultaneous Read/Write Sequence Started",
              UVM_LOW)

    fork

      begin
        axi_seq_item write_req;

        `uvm_do_with(write_req, {
          op               == AXI_WRITE;
          addr             == 32'h0000_4000;
          data             == 32'h1111_2222;
          id               == 16'h0041;
          user             == 10'h041;
          aw_delay         == 0;
          w_delay          == 0;
          resp_ready_delay == 0;
        })
      end

      begin
        axi_seq_item read_req;

        `uvm_do_with(read_req, {
          op               == AXI_READ;
          addr             == 32'h0000_4004;
          id               == 16'h0042;
          user             == 10'h042;
          resp_ready_delay == 0;
        })
      end

    join

    `uvm_info(get_type_name(),
              "AXI Simultaneous Read/Write Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_simultaneous_rw_sequence


//============================================================
// 9. BACK-TO-BACK AXI READS
//============================================================
class axi_back_to_back_reads_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_back_to_back_reads_sequence)

  function new(string name = "axi_back_to_back_reads_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Back-to-Back Reads Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 5; i++) begin

      `uvm_do_with(req, {
        op               == AXI_READ;
        addr             == (32'h0000_5000 + (i * 4));
        id               == (16'h0050 + i);
        user             == 10'h050;
        resp_ready_delay == 0;
      })

    end

    `uvm_info(get_type_name(),
              "AXI Back-to-Back Reads Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_back_to_back_reads_sequence


//============================================================
// 10. BACK-TO-BACK AXI WRITES
//============================================================
class axi_back_to_back_writes_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_back_to_back_writes_sequence)

  function new(string name = "axi_back_to_back_writes_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Back-to-Back Writes Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 5; i++) begin

      `uvm_do_with(req, {
        op               == AXI_WRITE;
        addr             == (32'h0000_6000 + (i * 4));
        data             == (32'hABCD_0000 + i);
        id               == (16'h0060 + i);
        user             == 10'h060;
        aw_delay         == 0;
        w_delay          == 0;
        resp_ready_delay == 0;
      })

    end

    `uvm_info(get_type_name(),
              "AXI Back-to-Back Writes Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_back_to_back_writes_sequence


//============================================================
// 11. MIXED AXI READ / WRITE TRAFFIC
//============================================================
class axi_mixed_traffic_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_mixed_traffic_sequence)

  function new(string name = "axi_mixed_traffic_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI Mixed Traffic Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 10; i++) begin

      if ((i % 2) == 0) begin

        `uvm_do_with(req, {
          op               == AXI_WRITE;
          addr             == (32'h0000_7000 + (i * 4));
          data             == (32'h1234_0000 + i);
          id               == (16'h0070 + i);
          user             == 10'h070;
          aw_delay         == 0;
          w_delay          == 0;
          resp_ready_delay == 0;
        })

      end
      else begin

        `uvm_do_with(req, {
          op               == AXI_READ;
          addr             == (32'h0000_7000 + ((i - 1) * 4));
          id               == (16'h0070 + i);
          user             == 10'h071;
          resp_ready_delay == 0;
        })

      end

    end

    `uvm_info(get_type_name(),
              "AXI Mixed Traffic Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_mixed_traffic_sequence


//============================================================
// 12. DIFFERENT AXI IDs AND USER VALUES
//============================================================
class axi_id_user_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_id_user_sequence)

  function new(string name = "axi_id_user_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI ID/USER Sequence Started",
              UVM_LOW)

    for (int i = 0; i < 5; i++) begin

      `uvm_do_with(req, {
        op               == AXI_WRITE;
        addr             == (32'h0000_8000 + (i * 4));
        data             == (32'hFACE_0000 + i);
        id               == (16'h0100 + i);
        user             == (10'h100 + i);
        aw_delay         == 0;
        w_delay          == 0;
        resp_ready_delay == 0;
      })

      `uvm_do_with(req, {
        op               == AXI_READ;
        addr             == (32'h0000_8000 + (i * 4));
        id               == (16'h0200 + i);
        user             == (10'h200 + i);
        resp_ready_delay == 0;
      })

    end

    `uvm_info(get_type_name(),
              "AXI ID/USER Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_id_user_sequence


//============================================================
// 13. AXI PSLVERR OBSERVATION SEQUENCE
//
// APB agent will assert PSLVERR.
// AXI sequence generates a transaction to observe response.
//============================================================
class axi_pslverr_sequence extends axi_base_sequence;

  `uvm_object_utils(axi_pslverr_sequence)

  function new(string name = "axi_pslverr_sequence");
    super.new(name);
  endfunction : new

  virtual task body();

    `uvm_info(get_type_name(),
              "AXI PSLVERR Sequence Started",
              UVM_LOW)

    `uvm_do_with(req, {
      op               == AXI_WRITE;
      addr             == 32'h0000_9000;
      data             == 32'hBAD0_BAD0;
      id               == 16'h0091;
      user             == 10'h091;
      aw_delay         == 0;
      w_delay          == 0;
      resp_ready_delay == 0;
    })

    `uvm_do_with(req, {
      op               == AXI_READ;
      addr             == 32'h0000_9004;
      id               == 16'h0092;
      user             == 10'h092;
      resp_ready_delay == 0;
    })

    `uvm_info(get_type_name(),
              "AXI PSLVERR Sequence Completed",
              UVM_LOW)

  endtask : body

endclass : axi_pslverr_sequence

`endif