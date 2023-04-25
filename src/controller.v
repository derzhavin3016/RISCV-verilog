module controller (input [6:0] op, input [2:0] funct3, input [6:0] funct7,
                       input iszero,
                       output memtoreg, memwrite,
                       output [2:0] memsize,
                       output pcsrc, output [1:0] alusrc,
                       output regwrite,
                       output jump,
                       output [3:0] alucontrol,
                       output jumpsrc, alusrc_a_zero, hlt
                      );
    logic branch, inv_br;
    maindec md (.op(op), .funct3(funct3),
                .memtoreg(memtoreg), .memwrite(memwrite),
                .memsize(memsize), .branch(branch),
                .alusrc(alusrc), .alusrc_a_zero(alusrc_a_zero),
                .regwrite(regwrite), .jump(jump),
                .jumpsrc(jumpsrc), .hlt(hlt));
    aludec ad (.opcode(op), .funct3(funct3),
               .funct7(funct7), .alucontrol(alucontrol),
               .inv_br(inv_br));
    assign pcsrc = branch & (iszero ^ inv_br);
endmodule
