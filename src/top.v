`include "consts.v"

module top (input clk, reset    ,
                output [31:0] writedata, dataadr,
                output memwrite
               );
    logic [31:0] pc /* verilator public */;
    logic [31:0] instr, readdata;
    logic [2:0] memsize;
    // instantiate processor and memories
    riscv riscv (clk, reset, pc, instr, memwrite, memsize, dataadr, writedata, readdata);
    imem #(18) imem (pc[19:2], instr);
    dmem #(18) dmem (clk, memwrite, memsize, dataadr, writedata, readdata);
endmodule
