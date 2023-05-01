module hazard (
        input [4:0] ra1D, ra2D, ra1E, ra2E, rdE, rdM, rdW,
        input controlChange, memtoregE, regwriteM, regwriteW,
        output stallF, stallD, flushD, flushE,
        output [1:0] forwardAE, forwardBE
    );
    // Bypasses
    setForward setA(.raE(ra1E), .rdM(rdM), .rdW(rdW),
                    .regwriteM(regwriteM), .regwriteW(regwriteW),
                    .forward(forwardAE));

    setForward setB(.raE(ra2E), .rdM(rdM), .rdW(rdW),
                    .regwriteM(regwriteM), .regwriteW(regwriteW),
                    .forward(forwardBE));

    // Stall pipeline
    logic lwStall;
    assign lwStall = memtoregE & ((ra1D == rdE) || (ra2D == rdE));
    assign stallF = lwStall;
    assign stallD = lwStall;

    // Control hazards
    assign flushD = controlChange;
    assign flushE = lwStall | controlChange;
endmodule
