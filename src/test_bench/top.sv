`include "apb_pkg.sv"
`include "design.sv"
`include "interface.sv"

module top;
    import apb_pkg::*;

    bit clock = 0;
    bit reset;
    apb_if vif(clock, reset);
    test t;

    initial begin
        forever #10 clock = ~clock;
    end

    initial begin
        @(posedge clock);
        reset = 0;
        @(posedge clock);
        reset = 1;
    end

    apb_slave dut(
        .PCLK(vif.PCLK), .PRESETn(vif.PRESETn), .PADDR(vif.PADDR),
        .PSEL(vif.PSEL), .PENABLE(vif.PENABLE), .PWRITE(vif.PWRITE),
        .PWDATA(vif.PWDATA), .PSTRB(vif.PSTRB), .PRDATA(vif.PRDATA),
        .PREADY(vif.PREADY), .PSLVERR(vif.PSLVERR)
    );

    initial begin
        t = new(vif);
        t.run();
        #10000 $finish;
    end

    final begin
        t.report();
    end
endmodule
