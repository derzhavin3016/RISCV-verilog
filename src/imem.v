`include "consts.v"

module imem (input [(`IMEM_POWER - 1):0] a,
                 output [31:0] rd
                );
    reg [31:0] RAM[((1 << `IMEM_POWER) - 1):0] /* verilator public */;
    // initial begin
    //     $readmemh ("memfile.dat",RAM);
    // end
    assign rd = RAM[a] ; // word aligned
endmodule
