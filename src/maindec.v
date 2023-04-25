`include "opcodes.v"
`include "consts.v"

module maindec(input [6:0] op,
                   input [2:0] funct3,
                   output memtoreg, memwrite,
                   output [2:0] memsize,
                   output branch,
                   output [1:0] alusrc,
                   output alusrc_a_zero,
                   output regwrite,
                   output jump,
                   output jumpsrc, // add to imm 0 for pc, 1 for rs1
                   output hlt
                  );
    logic [1:0] al_src;
    logic memtoreg_v = 0,
          memwrite_v = 0,
          branch_v = 0,
          regwrite_v = 0,
          jump_v = 0,
          jumpsrc_v = 0,
          alusrc_a_zero_v = 0,
          hlt_v = 0;
    logic [2:0] memsize_v = 3'bxxx;

    assign alusrc = al_src;
    assign memtoreg = memtoreg_v;
    assign memwrite = memwrite_v;
    assign memsize = memsize_v;
    assign branch = branch_v;
    assign regwrite = regwrite_v;
    assign jump = jump_v;
    assign jumpsrc = jumpsrc_v;
    assign alusrc_a_zero = alusrc_a_zero_v;
    assign hlt = hlt_v;

    always_latch
        case(op)
            `OPC_AUIPC: begin
                al_src = `ALU_SRC_PC;
                alusrc_a_zero_v = 1;
                regwrite_v = 1;
            end
            `OPC_LUI, `OPC_I_TYPE: begin
                alusrc_a_zero_v = (op == `OPC_LUI);
                al_src = `ALU_SRC_IMM;
                regwrite_v = 1;
            end
            `OPC_R_TYPE: begin
                al_src = `ALU_SRC_REG;
                regwrite_v = 1;
            end
            `OPC_BRANCH: begin
                al_src = `ALU_SRC_REG;
                branch_v = 1;
            end
            `OPC_JAL, `OPC_JALR: begin
                jumpsrc_v = (op == `OPC_JALR);
                al_src = `ALU_SRC_NPC;
                alusrc_a_zero_v = 1;
                jump_v = 1;
                regwrite_v = 1;
            end
            `OPC_LOAD: begin
                al_src = `ALU_SRC_IMM;
                regwrite_v = 1;
                memtoreg_v = 1;
                memsize_v = funct3;
            end
            `OPC_STORE: begin
                al_src = `ALU_SRC_IMM;
                memwrite_v = 1;
                memsize_v = funct3;
            end
            `OPC_SYSTEM: begin
                hlt_v = 1;
            end
            default:
                ;
        endcase
    endmodule
