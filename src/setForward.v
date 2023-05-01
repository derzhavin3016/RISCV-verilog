`define FORWARD_NO 2'b00
`define FORWARD_W 2'b01
`define FORWARD_M 2'b10

module setForward (
        input [4:0] raE, rdM, rdW,
        input regwriteM, regwriteW,
        output [1:0] forward
    );
    assign forward = ((raE == rdM) && regwriteM && (raE != 0)) ? `FORWARD_M :
           ((raE == rdW) && regwriteW && (raE != 0)) ? `FORWARD_W :
           `FORWARD_NO;

endmodule
