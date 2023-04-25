`include "consts.v"

module datapath (input clk, reset, hlt,
                     input memtoreg, pcsrc, jumpsrc,
                     input [1:0] alusrc,
                     input regwrite, jump,
                     input [3:0] alucontrol,
                     input alusrc_a_zero,
                     output zero,
                     output [31:0] pc,
                     input [31:0] instr,
                     output [31:0] aluout, writedata,
                     input [31:0] readdata
                    );
    wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch, jmp_base, jmp_pc, jmp_fin_pc;
    wire [31:0] imm;
    wire [4:0] ra1;
    wire [31:0] srca, srcb;
    wire [31:0] result;
    // next PC logic
    // register file logic
    always @(posedge clk)
        if (hlt)
            $finish;

    flopr #(32) pcreg(clk, reset, pcnext, pc);
    adder pcadd1(pc, 32'd4, pcplus4);
    adder pcadd2(pc, imm, pcbranch);

    mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
    mux2 #(32) jmpsrcmux(pc, srca, jumpsrc, jmp_base);
    adder jmptar(jmp_base, imm, jmp_pc);
    assign jmp_fin_pc = jmp_pc & ~1;

    mux2 #(32) pcmux(pcnextbr, jmp_fin_pc, jump, pcnext);

    immSel immsel(instr, imm);
    assign ra1 = instr[19:15] & ~{5{alusrc_a_zero}};
    regfile rf(clk, ra1,
               instr[24:20],
               regwrite, instr[11:7],
               result,
               srca, writedata);
    mux2 #(32) resmux(aluout, readdata, memtoreg, result);

    // ALU logic
    mux4 #(32) srcbmux(writedata, imm, pcbranch, pcplus4, alusrc, srcb);
    alu alu(srca, srcb, alucontrol, aluout, zero);
endmodule
