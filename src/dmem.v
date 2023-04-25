module dmem #(parameter DMEM_POWER = 18)
    (input clk, we,
     input [2:0] memsize,
     input [31:0] a, wd,
     output [31:0] rd
    );
    reg [31:0] RAM[((1 << DMEM_POWER) - 1):0];
    assign rd = RAM[a[(DMEM_POWER + 1):2]]; // word aligned
    always @ (posedge clk)
        if (we)
            RAM[a[(DMEM_POWER + 1):2]] <= wd;

    wire _unused_ok = &{1'b0,
                        a,
                        memsize,
                        1'b0};
endmodule
