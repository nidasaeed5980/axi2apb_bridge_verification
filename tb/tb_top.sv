`ifndef TB_TOP_SV
`define TB_TOP_SV



import uvm_pkg::*;
`include "uvm_macros.svh"
import axi2apb_pkg::*;

module tb_top;

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
  // 2. AXI AND APB INTERFACES (Lowercase matching your axi_if)
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
    .ACLK       (ACLK),
    .ARESETn    (ARESETn),
    .test_en_i  (1'b0),

    // AXI WRITE ADDRESS CHANNEL (AW)
    .AWID_i     (axi_vif.awid),
    .AWADDR_i   (axi_vif.awaddr),
    .AWLEN_i    (axi_vif.awlen),
    .AWSIZE_i   (axi_vif.awsize),
    .AWBURST_i  (axi_vif.awburst),
    .AWLOCK_i   (axi_vif.awlock),
    .AWCACHE_i  (axi_vif.awcache),
    .AWPROT_i   (axi_vif.awprot),
    .AWREGION_i (axi_vif.awregion),
    .AWUSER_i   (axi_vif.awuser),
    .AWQOS_i    (axi_vif.awqos),
    .AWVALID_i  (axi_vif.awvalid),
    .AWREADY_o  (axi_vif.awready),

    // AXI WRITE DATA CHANNEL (W)
    .WDATA_i    (axi_vif.wdata),
    .WSTRB_i    (axi_vif.wstrb),
    .WLAST_i    (axi_vif.wlast),
    .WUSER_i    (axi_vif.wuser),
    .WVALID_i   (axi_vif.wvalid),
    .WREADY_o   (axi_vif.wready),

    // AXI WRITE RESPONSE CHANNEL (B)
    .BID_o      (axi_vif.bid),
    .BRESP_o    (axi_vif.bresp),
    .BUSER_o    (axi_vif.buser),
    .BVALID_o   (axi_vif.bvalid),
    .BREADY_i   (axi_vif.bready),

    // AXI READ ADDRESS CHANNEL (AR)
    .ARID_i     (axi_vif.arid),
    .ARADDR_i   (axi_vif.araddr),
    .ARLEN_i    (axi_vif.arlen),
    .ARSIZE_i   (axi_vif.arsize),
    .ARBURST_i  (axi_vif.arburst),
    .ARLOCK_i   (axi_vif.arlock),
    .ARCACHE_i  (axi_vif.arcache),
    .ARPROT_i   (axi_vif.arprot),
    .ARREGION_i (axi_vif.arregion),
    .ARUSER_i   (axi_vif.aruser),
    .ARQOS_i    (axi_vif.arqos),
    .ARVALID_i  (axi_vif.arvalid),
    .ARREADY_o  (axi_vif.arready),

    // AXI READ DATA CHANNEL (R)
    .RID_o      (axi_vif.rid),
    .RDATA_o    (axi_vif.rdata),
    .RRESP_o    (axi_vif.rresp),
    .RLAST_o    (axi_vif.rlast),
    .RUSER_o    (axi_vif.ruser),
    .RVALID_o   (axi_vif.rvalid),
    .RREADY_i   (axi_vif.rready),

    // APB MASTER OUTPUTS
    .PENABLE    (apb_vif.penable),
    .PWRITE     (apb_vif.pwrite),
    .PADDR      (apb_vif.paddr),
    .PSEL       (apb_vif.psel),
    .PWDATA     (apb_vif.pwdata),

    // APB SLAVE INPUTS
    .PRDATA     (apb_vif.prdata),
    .PREADY     (apb_vif.pready),
    .PSLVERR    (apb_vif.pslverr)
  );

  //==========================================================
  // 4. RESET GENERATION (Runs in parallel with UVM)
  //==========================================================
  // initial begin
  //   // ARESETn = 1'b1;
  //   // #5;
  //   ARESETn = 1'b0;
  //   $display("============================================");
  //   $display("AXI2APB TESTBENCH STARTED - RESET ASSERTED");
  //   $display("============================================");
    
  //   repeat (10) @(posedge ACLK);
  //   @(negedge ACLK);
    
  //   ARESETn = 1'b1;
  //   $display("[%0t] RESET RELEASED", $time);
  // end
initial begin
    // Start reset deasserted
    ARESETn = 1'b1;

    // Wait so 1 -> 0 transition is visible
    repeat (2) @(negedge ACLK);

    // Assert reset
    ARESETn = 1'b0;

    $display("============================================");
    $display("[%0t] AXI2APB RESET ASSERTED (1 -> 0)", $time);
    $display("============================================");

    // Hold reset low for 10 clock cycles
    repeat (10) @(posedge ACLK);

    // Release reset safely on falling edge
    @(negedge ACLK);
    ARESETn = 1'b1;

    $display("[%0t] RESET RELEASED (0 -> 1)", $time);
end
  //==========================================================
  // 5. UVM CONFIGURATION AND TEST START (At Time 0)
  //==========================================================
  initial begin
    // Pass Interfaces to config DB
    uvm_config_db#(virtual axi_if)::set(null, "*", "axi_vif", axi_vif);
    uvm_config_db#(virtual apb_if)::set(null, "*", "apb_vif", apb_vif);

    $display("============================================");
    $display("INTERFACES CONFIGURED - STARTING UVM TEST");
    $display("============================================");

    // Start Test
    run_test(); // Test is selected via +UVM_TESTNAME command line
  end

  //==========================================================
  // 6. WAVEFORM DUMP
  //==========================================================
  initial begin
    $vcdplusfile("axi2apb_wave.vpd");
    $vcdpluson;
  end

endmodule : tb_top

`endif
