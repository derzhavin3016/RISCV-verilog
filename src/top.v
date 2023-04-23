module top (input clk, reset,
                output [31:0] writedata, dataadr,
                output memwrite
               );
    logic [31:0] pc /* verilator public */;
    logic [31:0] instr, readdata;
    // instantiate processor and memories
    riscv riscv (clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);
    imem imem (pc[7:2], instr);
    dmem dmem (clk, memwrite, dataadr, writedata, readdata);
endmodule
