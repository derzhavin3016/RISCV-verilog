`include "consts.v"

module top (input clk, reset);
    logic [31:0] pcF;
    logic [31:0] instrF, readdataM, writedataM, aluoutM;
    logic [2:0] memsizeM;
    logic memwriteM;

    // Processor
    riscv riscv (.clk(clk), .reset(reset),
                 .pcF(pcF), .instrF(instrF),
                 .memwriteM(memwriteM), .memsizeM(memsizeM),
                 .aluoutM(aluoutM), .writedataM(writedataM),
                 .readdataM(readdataM));
    // Memories
    imem #(18) imem (.a(pcF[19:2]), .rd(instrF));
    dmem #(18) dmem (.clk(clk), .we(memwriteM),
                     .memsize(memsizeM), .a(aluoutM),
                     .wd(writedataM), .rd(readdataM));

    wire _unused_ok = &{1'b0,
                        pcF,
                        1'b0};
endmodule
