
interface axi_if(input logic ACLK,input logic ARESETn);


  // AXI Write Address
  logic [15:0] AWID;
  logic [31:0] AWADDR;
  logic [7:0]  AWLEN;
  logic [2:0]  AWSIZE;
  logic [1:0]  AWBURST;
  logic        AWLOCK;
  logic [3:0]  AWCACHE;
  logic [2:0]  AWPROT;
  logic [3:0]  AWREGION;
  logic [9:0]  AWUSER;
  logic [3:0]  AWQOS;
  logic        AWVALID, AWREADY;

  // AXI Write Data
  logic [31:0] WDATA;
  logic [3:0]  WSTRB;
  logic        WLAST;
  logic [9:0]  WUSER;
  logic        WVALID, WREADY;

  // AXI Write Response
  logic [15:0] BID;
  logic [1:0]  BRESP;
  logic [9:0]  BUSER;
  logic        BVALID, BREADY;

  // AXI Read Address
  logic [15:0] ARID;
  logic [31:0] ARADDR;
  logic [7:0]  ARLEN;
  logic [2:0]  ARSIZE;
  logic [1:0]  ARBURST;
  logic        ARLOCK;
  logic [3:0]  ARCACHE;
  logic [2:0]  ARPROT;
  logic [3:0]  ARREGION;
  logic [9:0]  ARUSER;
  logic [3:0]  ARQOS;
  logic        ARVALID, ARREADY;

  // AXI Read Response
  logic [15:0] RID;
  logic [31:0] RDATA;
  logic [1:0]  RRESP;
  logic        RLAST;
  logic [9:0]  RUSER;
  logic        RVALID, RREADY;

endinterface
