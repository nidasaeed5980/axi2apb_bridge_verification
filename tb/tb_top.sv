

`ifndef TB_TOP_SV
`define TB_TOP_SV

module tb_top;

  import uvm_pkg::*;
  import axi2apb_pkg::*;

  //==========================================================
  // 1. CLOCK AND RESET
  //==========================================================

  logic ACLK;
  logic ARESETn;

  initial begin
    ACLK = 1'b0;
  end

  // 100 MHz clock: 10 ns period
  always #5 ACLK = ~ACLK;

  //==========================================================
  // 2. AXI AND APB INTERFACES
  //==========================================================

  axi_if axi_vif (
    .ACLK    (ACLK),
    .ARESETn (ARESETn)
  );

  apb_if apb_vif (
    .PCLK    (ACLK),
    .PRESETn (ARESETn)
  );

  //==========================================================
  // 3. DUT INSTANTIATION
  //==========================================================

  axi2apb #(
    .AXI4_ADDRESS_WIDTH (32),
    .AXI4_RDATA_WIDTH   (32),
    .AXI4_WDATA_WIDTH   (32),
    .AXI4_ID_WIDTH      (16),
    .AXI4_USER_WIDTH    (10),
    .BUFF_DEPTH_SLAVE   (4),
    .APB_ADDR_WIDTH     (32)
  ) dut (

    // -------------------------------------------------------
    // Clock, Reset and Test Enable
    // -------------------------------------------------------

    .ACLK       (ACLK),
    .ARESETn    (ARESETn),
    .test_en_i  (1'b0),

    // -------------------------------------------------------
    // AXI WRITE ADDRESS CHANNEL (AW)
    // -------------------------------------------------------

    .AWID_i     (axi_vif.AWID),
    .AWADDR_i   (axi_vif.AWADDR),
    .AWLEN_i    (axi_vif.AWLEN),
    .AWSIZE_i   (axi_vif.AWSIZE),
    .AWBURST_i  (axi_vif.AWBURST),
    .AWLOCK_i   (axi_vif.AWLOCK),
    .AWCACHE_i  (axi_vif.AWCACHE),
    .AWPROT_i   (axi_vif.AWPROT),
    .AWREGION_i (axi_vif.AWREGION),
    .AWUSER_i   (axi_vif.AWUSER),
    .AWQOS_i    (axi_vif.AWQOS),
    .AWVALID_i  (axi_vif.AWVALID),
    .AWREADY_o  (axi_vif.AWREADY),

    // -------------------------------------------------------
    // AXI WRITE DATA CHANNEL (W)
    // -------------------------------------------------------

    .WDATA_i    (axi_vif.WDATA),
    .WSTRB_i    (axi_vif.WSTRB),
    .WLAST_i    (axi_vif.WLAST),
    .WUSER_i    (axi_vif.WUSER),
    .WVALID_i   (axi_vif.WVALID),
    .WREADY_o   (axi_vif.WREADY),

    // -------------------------------------------------------
    // AXI WRITE RESPONSE CHANNEL (B)
    // -------------------------------------------------------

    .BID_o      (axi_vif.BID),
    .BRESP_o    (axi_vif.BRESP),
    .BUSER_o    (axi_vif.BUSER),
    .BVALID_o   (axi_vif.BVALID),
    .BREADY_i   (axi_vif.BREADY),

    // -------------------------------------------------------
    // AXI READ ADDRESS CHANNEL (AR)
    // -------------------------------------------------------

    .ARID_i     (axi_vif.ARID),
    .ARADDR_i   (axi_vif.ARADDR),
    .ARLEN_i    (axi_vif.ARLEN),
    .ARSIZE_i   (axi_vif.ARSIZE),
    .ARBURST_i  (axi_vif.ARBURST),
    .ARLOCK_i   (axi_vif.ARLOCK),
    .ARCACHE_i  (axi_vif.ARCACHE),
    .ARPROT_i   (axi_vif.ARPROT),
    .ARREGION_i (axi_vif.ARREGION),
    .ARUSER_i   (axi_vif.ARUSER),
    .ARQOS_i    (axi_vif.ARQOS),
    .ARVALID_i  (axi_vif.ARVALID),
    .ARREADY_o  (axi_vif.ARREADY),

    // -------------------------------------------------------
    // AXI READ DATA CHANNEL (R)
    // -------------------------------------------------------

    .RID_o      (axi_vif.RID),
    .RDATA_o    (axi_vif.RDATA),
    .RRESP_o    (axi_vif.RRESP),
    .RLAST_o    (axi_vif.RLAST),
    .RUSER_o    (axi_vif.RUSER),
    .RVALID_o   (axi_vif.RVALID),
    .RREADY_i   (axi_vif.RREADY),

    // -------------------------------------------------------
    // APB MASTER OUTPUTS
    // -------------------------------------------------------

    .PENABLE    (apb_vif.PENABLE),
    .PWRITE     (apb_vif.PWRITE),
    .PADDR      (apb_vif.PADDR),
    .PSEL       (apb_vif.PSEL),
    .PWDATA     (apb_vif.PWDATA),

    // -------------------------------------------------------
    // APB SLAVE INPUTS
    // -------------------------------------------------------

    .PRDATA     (apb_vif.PRDATA),
    .PREADY     (apb_vif.PREADY),
    .PSLVERR    (apb_vif.PSLVERR)

  );

  //==========================================================
  // 4. RESET GENERATION
  //==========================================================

  initial begin

    ARESETn = 1'b0;

    $display("============================================");
    $display("AXI2APB TESTBENCH STARTED");
    $display("RESET ASSERTED");
    $display("============================================");

    repeat (10) @(posedge ACLK);

    @(negedge ACLK);

    ARESETn = 1'b1;

    $display("[%0t] RESET RELEASED", $time);

  end

  //==========================================================
  // 5. UVM CONFIGURATION AND TEST START
  //==========================================================

  initial begin

    // -------------------------------------------------------
    // Set AXI Interface
    // -------------------------------------------------------

    uvm_config_db#(virtual axi_if)::set(
      null,
      "uvm_test_top*",
      "axi_vif",
      axi_vif
    );

    // -------------------------------------------------------
    // Set APB Interface
    // -------------------------------------------------------

    uvm_config_db#(virtual apb_if)::set(
      null,
      "uvm_test_top*",
      "apb_vif",
      apb_vif
    );

    $display("============================================");
    $display("AXI AND APB INTERFACES CONFIGURED");
    $display("STARTING UVM TEST");
    $display("============================================");

    // Test selected using +UVM_TESTNAME
    run_test("axi2apb_smoke_test");

  end

  //==========================================================
  // 6. GLOBAL SIMULATION TIMEOUT
  //==========================================================

  initial begin

    #1000000;

    $display("============================================");
    $display("ERROR: GLOBAL SIMULATION TIMEOUT");
    $display("============================================");

    $fatal(1, "AXI2APB Simulation Timeout");

  end

  //==========================================================
  // 7. WAVEFORM DUMP
  //==========================================================



  initial begin

   $vcdplusfile("axi2apb_wave.vpd");

    $vcdpluson;

  end

endmodule : tb_top

`endif
