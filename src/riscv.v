module riscv (input clk, reset,
                  output [31:0] pc,
                  input [31:0] instr,
                  output memwrite, output [2:0] memsize,
                  output [31:0] aluout, writedata,
                  input [31:0] readdata
                 );
    wire memtoreg, regwrite, jump;
    logic [1:0] alusrc;
    logic pcsrc, zero, alusrc_a_zero;
    logic jumpsrc, hlt;
    wire [3:0] alucontrol;
    controller c(.op(instr[6:0]), .funct3(instr[14:12]),
                 .funct7(instr[31:25]), .iszero(zero),
                 .memtoreg(memtoreg), .memwrite(memwrite),
                 .memsize(memsize), .pcsrc(pcsrc),
                 .alusrc(alusrc), .regwrite(regwrite),
                 .jump(jump), .alucontrol(alucontrol),
                 .jumpsrc(jumpsrc), .alusrc_a_zero(alusrc_a_zero),
                 .hlt(hlt));
    datapath dp(.clk(clk), .reset(reset),
                .hlt(hlt), .memtoreg(memtoreg),
                .pcsrc(pcsrc), .jumpsrc(jumpsrc),
                .alusrc(alusrc), .regwrite(regwrite),
                .jump(jump), .alucontrol(alucontrol),
                .alusrc_a_zero(alusrc_a_zero), .zero(zero),
                .pc(pc), .instr(instr),
                .aluout(aluout), .writedata(writedata),
                .readdata(readdata));
endmodule
