class axi2apb_base_test extends uvm_test;

  `uvm_component_utils(axi2apb_base_test)

  //---------------------------------------
  // axi2apb_env instance
  //---------------------------------------
  axi2apb_env env;

  //---------------------------------------
  // constructor
  //---------------------------------------
  function new(string name = "axi2apb_base_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //---------------------------------------
  // build_phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create AXI2APB environment
    env = axi2apb_env::type_id::create("env", this);

  endfunction : build_phase

  //---------------------------------------
  // end_of_elaboration_phase
  //---------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // Print UVM topology if required
    // uvm_top.print_topology();

  endfunction : end_of_elaboration_phase

  //---------------------------------------
  // report_phase
  //---------------------------------------
  virtual function void report_phase(uvm_phase phase);

    uvm_report_server svr;

    super.report_phase(phase);

    svr = uvm_report_server::get_server();

    if (svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR) > 0) begin

      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(),
        "----            TEST FAIL          ----", UVM_NONE)
      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)

    end
    else begin

      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)
      `uvm_info(get_type_name(),
        "----            TEST PASS          ----", UVM_NONE)
      `uvm_info(get_type_name(),
        "---------------------------------------", UVM_NONE)

    end

  endfunction : report_phase

endclass : axi2apb_base_test
