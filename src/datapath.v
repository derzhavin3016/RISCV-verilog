`include "consts.v"

module datapath (input clk, reset, hltD,
                     input memtoregD, jumpsrcD,
                     input [1:0] alusrcAD, alusrcBD,
                     input regwriteD, jumpD,
                     input [3:0] alucontrolD,
                     input alusrc_a_zeroD,
                     output [31:0] pcF,
                     input [31:0] instrF,
                     output [31:0] aluoutM, writedataM,
                     input [31:0] readdataM,
                     input memwriteD,
                     output memwriteM,
                     input [2:0] memsizeD,
                     output [2:0] memsizeM,
                     input branchD, inv_brD,
                     output [31:0] instrD
                    );
    logic hltW, jumpE, regwriteW;
    logic [4:0] rdW;
    logic [31:0] jmp_fin_pcE, resultW;
    logic stallF, stallD, flushD, flushE;
    logic [1:0] forwardAE, forwardBE;

    // FETCH
    logic [31:0] pcD, pcnextF, pcplus4F, pcbranchE, pcnextbrF;
    pcReg pcreg(.clk(clk), .en(!stallF), .clr(reset),
                .pcIn(pcnextF), .pcOut(pcF));
    adder pcadd1(.a(pcF), .b(32'd4), .y(pcplus4F));

    logic pcsrcE;
    mux2 #(32) pcbrmux(.d0(pcplus4F), .d1(pcbranchE),
                       .s(pcsrcE), .y(pcnextbrF));

    mux2 #(32) pcmux(.d0(pcnextbrF), .d1(jmp_fin_pcE), .s(jumpE), .y(pcnextF));

    rPipe #(64) FtoD(.clk(clk), .en(!stallD), .clr(flushD),
                     .inpData({instrF, pcF}),
                     .outData({instrD, pcD}));

    // DECODE
    logic [31:0] immD, rd1D, rd2D;
    logic [4:0] ra1D, ra2D, rdD;
    logic hltE, memtoregE, jumpsrcE, regwriteE,
          memwriteE, branchE, inv_brE;
    logic [1:0] alusrcAE, alusrcBE;
    logic [2:0] memsizeE;
    logic [3:0] alucontrolE;
    logic [4:0] ra1E, ra2E, rdE;
    logic [31:0] pcE, rd1E, rd2E, immE;

    immSel immsel(.instr(instrD), .imm(immD));

    assign rdD = instrD[11:7];
    assign ra1D = instrD[19:15] & ~{5{alusrc_a_zeroD}};
    assign ra2D = instrD[24:20];


    regfile rf(.clk(clk), .ra1(ra1D),
               .ra2(ra2D),
               .we3(regwriteW), .wa3(rdW),
               .wd3(resultW),
               .rd1(rd1D), .rd2(rd2D));
    rPipe #(162) DtoE(.clk(clk), .en(1), .clr(flushE),
                      .inpData({hltD, memtoregD, jumpsrcD, alusrcAD, alusrcBD,
                                regwriteD, jumpD, alucontrolD, pcD, memwriteD,
                                memsizeD, branchD, inv_brD, rd1D, rd2D, ra1D, ra2D, rdD,
                                immD}),
                      .outData({hltE, memtoregE, jumpsrcE, alusrcAE, alusrcBE,
                                regwriteE, jumpE, alucontrolE, pcE, memwriteE,
                                memsizeE, branchE, inv_brE, rd1E, rd2E, ra1E, ra2E, rdE,
                                immE}));

    // EXECUTE
    logic [31:0] srcAE, srcBE, aluoutE, rd1Efrw, rd2Efrw;
    logic zeroE;
    logic controlChange;
    assign pcsrcE = branchE & (zeroE ^ inv_brE);
    assign controlChange = pcsrcE | jumpE;

    mux3 #(32) forwardAmux(.d0(rd1E), .d1(resultW), .d2(aluoutM),
                           .s(forwardAE), .y(rd1Efrw));

    mux3 #(32) forwardBmux(.d0(rd2E), .d1(resultW), .d2(aluoutM),
                           .s(forwardBE), .y(rd2Efrw));


    mux2 #(32) srcamux(.d0(rd1Efrw), .d1(pcE),
                       .s(alusrcAE[0]), .y(srcAE));

    mux3 #(32) srcbmux(.d0(rd2Efrw), .d1(immE),
                       .d2(32'd4),
                       .s(alusrcBE), .y(srcBE));

    alu alu(.a(srcAE), .b(srcBE),
            .aluctr(alucontrolE), .aluout(aluoutE),
            .iszero(zeroE));

    logic [31:0] jmp_baseE, jmp_pcE;
    adder pcaddimm(.a(pcE), .b(immE), .y(pcbranchE));
    mux2 #(32) jmpsrcmux(.d0(pcE), .d1(rd1E),
                         .s(jumpsrcE), .y(jmp_baseE));
    adder jmptar(.a(jmp_baseE), .b(immE), .y(jmp_pcE));
    assign jmp_fin_pcE = jmp_pcE & ~1;
    logic [31:0] writedataE;
    assign writedataE = rd2Efrw;

    logic regwriteM, memtoregM, hltM;
    logic [4:0] rdM;
    logic [31:0] pcM;

    rPipe #(108) EtoM(.clk(clk), .en(1), .clr(reset),
                      .inpData({regwriteE, memtoregE, memwriteE,
                                hltE, memsizeE, rdE, writedataE, aluoutE, pcE}),
                      .outData({regwriteM, memtoregM, memwriteM,
                                hltM, memsizeM, rdM, writedataM, aluoutM, pcM}));

    // MEMORY
    logic memtoregW, memwriteW, validW;
    logic [31:0] aluoutW, readdataW, writedataW, pcW;

    rPipe #(138) MtoW(.clk(clk), .en(1), .clr(reset),
                      .inpData({regwriteM, memtoregM, hltM, rdM,
                                aluoutM, readdataM, memwriteM,
                                writedataM, pcM != 0, pcM}),
                      .outData({regwriteW, memtoregW, hltW, rdW,
                                aluoutW, readdataW, memwriteW,
                                writedataW, validW, pcW}));

    // WRITEBACK

    mux2 #(32) resmux(.d0(aluoutW), .d1(readdataW),
                      .s(memtoregW), .y(resultW));
    reg [31:0] num = 1;

    // Cosimulation
    always @(negedge clk) begin
        if (validW) begin
            num <= num + 1;
            $display("-----------------------");
            $display("NUM=%0d", num);

            if (regwriteW & (rdW != 0))
                $display("x%0d=0x%h", rdW, resultW);
            else if (memwriteW)
                $display("M[0x%h]=0x%h", aluoutW, writedataW);

            $display("PC=0x%h", (pcM == 0) ? pcW + 4 : pcM);
            if (hltW) begin
                $display("");
                $display("Caught halt signal at WB stage. Exiting...");
                $finish;
            end
        end
    end

    // HAZARD UNIT

    hazard hazUnit(.ra1D(ra1D), .ra2D(ra2D), .ra1E(ra1E), .ra2E(ra2E),
                   .rdE(rdE), .rdM(rdM), .rdW(rdW),
                   .controlChange(controlChange), .memtoregE(memtoregE),
                   .regwriteM(regwriteM), .regwriteW(regwriteW),
                   .stallF(stallF), .stallD(stallD), .flushD(flushD),
                   .flushE(flushE),
                   .forwardAE(forwardAE), .forwardBE(forwardBE));

    wire _unused_ok = &{1'b0,
                        alusrcAE,
                        1'b0};
endmodule
