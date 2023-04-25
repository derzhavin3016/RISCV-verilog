`include "consts.v"

module top (input clk, reset,
                output [31:0] writedata, dataadr,
                output memwrite
               );
    logic [31:0] pc /* verilator public */;
    logic [31:0] instr, readdata;
    logic [2:0] memsize;
    // instantiate processor and memories
    riscv riscv (.clk(clk), .reset(reset),
                 .pc(pc), .instr(instr),
                 .memwrite(memwrite), .memsize(memsize),
                 .aluout(dataadr), .writedata(writedata),
                 .readdata(readdata));
    imem #(18) imem (.a(pc[19:2]), .rd(instr));
    dmem #(18) dmem (.clk(clk), .we(memwrite),
                     .memsize(memsize), .a(dataadr),
                    .wd(writedata), .rd(readdata));
endmodule
