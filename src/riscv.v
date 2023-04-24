module riscv (input clk, reset,
                  output [31:0] pc,
                  input [31:0] instr,
                  output memwrite,
                  output [31:0] aluout, writedata,
                  input [31:0] readdata
                 );
    wire memtoreg, branch, regwrite, jump;
    wire [2:0] memsize;
    logic [1:0] alusrc;
    logic pcsrc, zero;
    wire [3:0] alucontrol;
    controller c(instr[6:0], instr[14:12], instr[31:25], zero,
                 memtoreg, memwrite, memsize, pcsrc,
                 alusrc, regwrite, jump,
                 alucontrol);
    datapath dp(clk, reset, memtoreg, pcsrc,
                alusrc, regwrite, jump,
                alucontrol,
                zero, pc, instr,
                aluout, writedata, readdata);
endmodule
