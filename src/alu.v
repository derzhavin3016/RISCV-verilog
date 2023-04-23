module alu(
        input [31:0] a, b,
        input [2:0] aluctr,
        output reg [31:0] aluout,
        output reg zero
    );
    always @(*) begin
        case (aluctr)
            3'b010:
                aluout = a + b;
            3'b110:
                aluout = a - b;
            3'b000:
                aluout = a & b;
            3'b001:
                aluout = a | b;
            3'b111:
                aluout = $signed(a) < $signed(b) ? 1 : 0;
            default:
                ;
        endcase
        zero = (aluout == 0);
    end
endmodule
