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
    maindec md (op, funct3, memtoreg, memwrite, memsize,
                branch, alusrc, alusrc_a_zero, regwrite, jump, jumpsrc, hlt);
    aludec ad (op, funct3, funct7, alucontrol, inv_br);
    assign pcsrc = branch & (iszero ^ inv_br);
endmodule
