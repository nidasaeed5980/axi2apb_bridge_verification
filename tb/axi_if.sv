interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 16,
    parameter USER_WIDTH = 10
) (input logic ACLK, input logic ARESETn);

    logic [ID_WIDTH-1:0]      awid;
    logic [ADDR_WIDTH-1:0]    awaddr;
    logic [7:0]               awlen;
    logic [2:0]               awsize;
    logic [1:0]               awburst;
    logic                     awlock;
    logic [3:0]               awcache;
    logic [2:0]               awprot;
    logic [3:0]               awregion;
    logic [USER_WIDTH-1:0]    awuser;
    logic [3:0]               awqos;
    logic                     awvalid;
    logic                     awready;

    logic [DATA_WIDTH-1:0]    wdata;
    logic [DATA_WIDTH/8-1:0]  wstrb;
    logic                     wlast;
    logic [USER_WIDTH-1:0]    wuser;
    logic                     wvalid;
    logic                     wready;

    logic [ID_WIDTH-1:0]      bid;
    logic [1:0]               bresp;
    logic                     bvalid;
    logic [USER_WIDTH-1:0]    buser;
    logic                     bready;

    logic [ID_WIDTH-1:0]      arid;
    logic [ADDR_WIDTH-1:0]    araddr;
    logic [7:0]               arlen;
    logic [2:0]               arsize;
    logic [1:0]               arburst;
    logic                     arlock;
    logic [3:0]               arcache;
    logic [2:0]               arprot;
    logic [3:0]               arregion;
    logic [USER_WIDTH-1:0]    aruser;
    logic [3:0]               arqos;
    logic                     arvalid;
    logic                     arready;

    logic [ID_WIDTH-1:0]      rid;
    logic [DATA_WIDTH-1:0]    rdata;
    logic [1:0]               rresp;
    logic                     rlast;
    logic [USER_WIDTH-1:0]    ruser;
    logic                     rvalid;
    logic                     rready;

    clocking drv_cb @(posedge ACLK);
        default input #1step output #1;
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awuser, awqos, awvalid;
        output wdata, wstrb, wlast, wuser, wvalid;
        output bready;
        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, aruser, arqos, arvalid;
        output rready;
        input  awready, wready, bvalid, bresp, bid, buser, arready, rvalid, rdata, rresp, rlast, rid, ruser;
    endclocking

    clocking mon_cb @(posedge ACLK);
        default input #1step;
        input awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awuser, awqos, awvalid, awready;
        input wdata, wstrb, wlast, wuser, wvalid, wready;
        input bready, bvalid, bresp, bid, buser;
        input arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, aruser, arqos, arvalid, arready;
        input rready, rvalid, rdata, rresp, rlast, rid, ruser;
    endclocking

    modport DRV_MP (clocking drv_cb, input ACLK, ARESETn);
    modport MON_MP (clocking mon_cb, input ACLK, ARESETn);
endinterface