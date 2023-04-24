module mux3 # (parameter WIDTH = 8)
    (input [WIDTH-1:0] d0, d1, d2, d3
     input [1:0] s,
     output [WIDTH-1:0] y
    );
    always @(*)
    case (s)
        0: y = d0;
        1: y = d1;
        2: y = d2;
        3: y = d3;
    endcase
endmodule
