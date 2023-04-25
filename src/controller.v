module controller (input logic[6:0] op,
                     input logic[2:0] funct3, input logic[6:0] funct7,
                       input logic iszero,
                       output logic memtoreg, memwrite,
                       output logic[2:0] memsize,
                       output logic pcsrc,
                       output logic[1:0] alusrcA,
                       output logic[1:0] alusrcB,
                       output logic regwrite,
                       output logic jump,
                       output logic[3:0] alucontrol,
                       output logic jumpsrc, alusrc_a_zero, hlt
                      );
    logic branch, inv_br;
    maindec md (.op(op), .funct3(funct3),
                .memtoreg(memtoreg), .memwrite(memwrite),
                .memsize(memsize), .branch(branch),
                .alusrcA(alusrcA), .alusrcB(alusrcB),
                .alusrc_a_zero(alusrc_a_zero),
                .regwrite(regwrite), .jump(jump),
                .jumpsrc(jumpsrc), .hlt(hlt));
    aludec ad (.opcode(op), .funct3(funct3),
               .funct7(funct7), .alucontrol(alucontrol),
               .inv_br(inv_br));
    assign pcsrc = branch & (iszero ^ inv_br);
endmodule
