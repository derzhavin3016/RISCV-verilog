`include "opcodes.v"

module immSel (
        input [31:0] instr,
        output [31:0] imm
    );
    logic [31:0] im;
    assign imm = im;

    always @(*)
    case (instr[6:0]
             )
        `OPC_I_TYPE, `OPC_JALR, `OPC_LOAD:
            im = {{21{instr[31]}}, instr[30:20]}; // I imm
        `OPC_BRANCH:
            im = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B imm
        `OPC_AUIPC, `OPC_LUI:
            im = {instr[31:12], 12'b0}; // U imm
        `OPC_JAL:
            im = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J imm
        `OPC_STORE:
            im = {{21{instr[31]}}, instr[30:25], instr[11:7]}; // S imm
        default:
            im = 32'hxxxx;
    endcase
endmodule
