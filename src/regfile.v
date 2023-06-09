module regfile (input clk,
                    input [4:0] ra1, ra2,
                    input we3,
                    input [4:0] wa3,
                    input [31:0] wd3,
                    output [31:0] rd1, rd2
                   );
    reg [31:0] regf[31:0];
    // three ported register file
    // read two ports combinationally
    // write third port on rising edge of clock
    // register 0 hardwired to 0

    assign rd1 = (ra1 != 0) ? regf[ra1] : 0;
    assign rd2 = (ra2 != 0) ? regf[ra2] : 0;

    always @ (negedge clk)
        if (we3)
            regf[wa3] <= wd3;
endmodule
