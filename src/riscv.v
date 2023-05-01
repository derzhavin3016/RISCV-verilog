module riscv (input logic clk, reset,
                  output logic[31:0] pcF,
                  input logic [31:0] instrF,
                  output logic memwriteM, output logic [2:0] memsizeM,
                  output logic[31:0] aluoutM, writedataM,
                  input logic[31:0] readdataM
                 );
    logic memtoregD, regwriteD, jumpD;
    logic[1:0] alusrcAD, alusrcBD;
    logic alusrc_a_zeroD;
    logic jumpsrcD, hltD, branchD, inv_brD, memwriteD;
    logic[3:0] alucontrolD;
    logic[2:0] memsizeD;
    logic [31:0] instrD;
    controller c(.op(instrD[6:0]), .funct3(instrD[14:12]),
                 .funct7(instrD[31:25]),
                 .memtoregD(memtoregD), .memwriteD(memwriteD),
                 .memsizeD(memsizeD),
                 .alusrcAD(alusrcAD), .alusrcBD(alusrcBD),
                 .regwriteD(regwriteD),
                 .jumpD(jumpD), .alucontrolD(alucontrolD),
                 .jumpsrcD(jumpsrcD), .alusrc_a_zeroD(alusrc_a_zeroD),
                 .hltD(hltD), .branchD(branchD), .inv_brD(inv_brD));
    datapath dp(.clk(clk), .reset(reset),
                .hltD(hltD), .memtoregD(memtoregD),
                .jumpsrcD(jumpsrcD),
                .alusrcAD(alusrcAD), .alusrcBD(alusrcBD), .regwriteD(regwriteD),
                .jumpD(jumpD), .alucontrolD(alucontrolD),
                .alusrc_a_zeroD(alusrc_a_zeroD),
                .pcF(pcF), .instrF(instrF),
                .aluoutM(aluoutM), .writedataM(writedataM),
                .readdataM(readdataM),
                .memwriteD(memwriteD), .memwriteM(memwriteM),
                .memsizeD(memsizeD), .memsizeM(memsizeM),
                .branchD(branchD), .inv_brD(inv_brD), .instrD(instrD));


    wire _unused_ok = &{1'b0,
                        instrD[24:15],
                        instrD[11:7],
                        1'b0};
endmodule
