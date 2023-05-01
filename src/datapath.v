`include "consts.v"

module datapath (input clk, reset, hltD,
                     input memtoregD, jumpsrcD,
                     input [1:0] alusrcAD, alusrcBD,
                     input regwriteD, jumpD,
                     input [3:0] alucontrolD,
                     input alusrc_a_zeroD,
                     output [31:0] pcF,
                     input [31:0] instrF,
                     output [31:0] aluoutM, writedataM,
                     input [31:0] readdataM,
                     output memwriteD, memwriteM,
                     input [2:0] memsizeD, memsizeM,
                     input branchD, inv_brD,
                     output [31:0] instrD
                    );
    logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    logic [31:0] imm;
    logic [4:0] ra1;
    logic [31:0] rd1;
    logic [31:0] srca, srcb;
    logic [31:0] result;
    // next PC logic
    // register file logic
    always @(posedge clk)
        if (hlt)
            $finish;

    flopr #(32) pcreg(.clk(clk), .reset(reset), .d(pcnext), .q(pc));
    adder pcadd1(.a(pc), .b(32'd4), .y(pcplus4));
    adder pcadd2(.a(pc), .b(imm), .y(pcbranch));

    mux2 #(32) pcbrmux(.d0(pcplus4), .d1(pcbranch),
                       .s(pcsrc), .y(pcnextbr));
    mux2 #(32) jmpsrcmux(.d0(pc), .d1(rd1),
                         .s(jumpsrc), .y(jmp_base));
    adder jmptar(.a(jmp_base), .b(imm), .y(jmp_pc));
    assign jmp_fin_pc = jmp_pc & ~1;

    mux2 #(32) pcmux(.d0(pcnextbr), .d1(jmp_fin_pc), .s(jump), .y(pcnext));

    immSel immsel(.instr(instr), .imm(imm));
    assign ra1 = instr[19:15] & ~{5{alusrc_a_zero}};
    regfile rf(.clk(clk), .ra1(ra1),
               .ra2(instr[24:20]),
               .we3(regwrite), .wa3(instr[11:7]),
               .wd3(result),
               .rd1(rd1), .rd2(writedata));
    mux2 #(32) resmux(.d0(aluout), .d1(readdata),
                      .s(memtoreg), .y(result));

    // ALU logic
    mux2 #(32) srcamux(.d0(rd1), .d1(pc),
                       .s(alusrcA[0]), .y(srca));
    mux3 #(32) srcbmux(.d0(writedata), .d1(imm),
                       .d2(32'd4),
                       .s(alusrcB), .y(srcb));
    alu alu(.a(srca), .b(srcb),
            .aluctr(alucontrol), .aluout(aluout),
            .iszero(zero));

    wire _unused_ok = &{1'b0,
                        alusrcA,
                        1'b0};
endmodule
