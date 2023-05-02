module pcReg (
        input clk,
        input en,
        input clr,
        input [31:0] pcIn,
        output [31:0] pcOut
    );
    reg [31:0] pc /* verilator public */;
    assign pcOut = pc;

    always @(posedge clk)
        if (clr)
            pc <= 0;
        else if (en)
            pc <= pcIn;

endmodule
