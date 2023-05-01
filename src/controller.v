module controller (input logic[6:0] op,
                     input logic[2:0] funct3, input logic[6:0] funct7,
                       output logic memtoregD, memwriteD,
                       output logic[2:0] memsizeD,
                       output logic[1:0] alusrcAD,
                       output logic[1:0] alusrcBD,
                       output logic regwriteD,
                       output logic jumpD,
                       output logic[3:0] alucontrolD,
                       output logic jumpsrcD, alusrc_a_zeroD, hltD, branchD, inv_brD
                      );
    maindec md (.op(op), .funct3(funct3),
                .memtoreg(memtoregD), .memwrite(memwriteD),
                .memsize(memsizeD), .branch(branchD),
                .alusrcA(alusrcAD), .alusrcB(alusrcBD),
                .alusrc_a_zero(alusrc_a_zeroD),
                .regwrite(regwriteD), .jump(jumpD),
                .jumpsrc(jumpsrcD), .hlt(hltD));
    aludec ad (.opcode(op), .funct3(funct3),
               .funct7(funct7), .alucontrol(alucontrolD),
               .inv_br(inv_brD));
endmodule
