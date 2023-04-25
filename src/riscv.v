module riscv (input logic clk, reset,
                  output logic[31:0] pc,
                  input logic [31:0] instr,
                  output logic memwrite, output logic [2:0] memsize,
                  output logic[31:0] aluout, writedata,
                  input logic[31:0] readdata
                 );
    logic memtoreg, regwrite, jump;
    logic[1:0] alusrc;
    logic pcsrc, zero, alusrc_a_zero;
    logic jumpsrc, hlt;
    logic[3:0] alucontrol;
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
