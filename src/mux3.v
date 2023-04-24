module mux3 # (parameter WIDTH = 8)
    (input [WIDTH-1:0] d0, d1, d2,
     input [1:0] s,
     output [WIDTH-1:0] y
    );
    always @(*)
        if (s == 0)
            y = d0;
        else if (s == 1)
            y = d1;
        else if (s == 2)
            y = d2;
endmodule
