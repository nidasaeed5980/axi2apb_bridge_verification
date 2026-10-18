interface apb_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (input logic PCLK, input logic PRESETn);

    logic                  penable;
    logic                  pwrite;
    logic [ADDR_WIDTH-1:0] paddr;
    logic                  psel;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH-1:0] prdata;
    logic                  pready;
    logic                  pslverr;

    clocking drv_cb @(posedge PCLK);
        default input #1step output #1;
        output prdata, pready, pslverr;
        input  penable, pwrite, paddr, psel, pwdata;
    endclocking

    clocking mon_cb @(posedge PCLK);
        default input #1step;
        input penable, pwrite, paddr, psel, pwdata, prdata, pready, pslverr;
    endclocking

    modport DRV_MP (clocking drv_cb, input PCLK, PRESETn);
    modport MON_MP (clocking mon_cb, input PCLK, PRESETn);
endinterface