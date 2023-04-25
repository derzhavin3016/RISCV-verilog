module mux3 # (parameter WIDTH = 8)
    (input [WIDTH-1:0] d0, d1, d2,
     input [1:0] s,
     output [WIDTH-1:0] y
    );
    assign y = (s == 0) ? d0 : (s == 1) ? d1 : d2;
endmodule
