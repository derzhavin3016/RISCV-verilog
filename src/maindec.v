`include "opcodes.v"
`include "consts.v"

module maindec(input logic[6:0] op,
                   input logic[2:0] funct3,
                   output logic memtoreg, memwrite,
                   output logic[2:0] memsize,
                   output logic branch,
                   output logic[1:0] alusrcA,
                   output logic[1:0] alusrcB,
                   output logic alusrc_a_zero,
                   output logic regwrite,
                   output logic jump,
                   output logic jumpsrc, // add to imm 0 for pc, 1 for rs1
                   output logic hlt
                  );

    always_comb
        case(op)
            `OPC_AUIPC: begin
                alusrcA = `ALU_SRCA_PC;
                alusrcB = `ALU_SRCB_IMM;
                alusrc_a_zero = 0;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                hlt = 0;
            end
            `OPC_LUI, `OPC_I_TYPE: begin
                alusrc_a_zero = (op == `OPC_LUI);
                alusrcA = `ALU_SRCA_REG;
                alusrcB = `ALU_SRCB_IMM;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                hlt = 0;
            end
            `OPC_R_TYPE, `OPC_BRANCH: begin
                alusrcA = `ALU_SRCA_REG;
                alusrcB = `ALU_SRCB_REG;
                regwrite = (op == `OPC_R_TYPE);
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = (op == `OPC_BRANCH);
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_JAL, `OPC_JALR: begin
                jumpsrc = (op == `OPC_JALR);
                alusrcA = `ALU_SRCA_PC;
                alusrcB = `ALU_SRCB_FOUR;
                alusrc_a_zero = 0;
                jump = 1;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                hlt = 0;
            end
            `OPC_LOAD, `OPC_STORE: begin
                alusrcA = `ALU_SRCA_REG;
                alusrcB = `ALU_SRCB_IMM;
                regwrite = (op == `OPC_LOAD);
                memtoreg = (op == `OPC_LOAD);
                memsize = funct3;
                memwrite = (op == `OPC_STORE);
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_SYSTEM: begin
                hlt = 1;
                alusrcA = 2'bxx;
                alusrcB = 2'bxx;
                memwrite = 0;
                memsize = 3'bxxx;
                memtoreg = 0;
                branch = 0;
                regwrite = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
            end
            default: begin
                hlt = 0;
                alusrcA = 2'bxx;
                alusrcB = 2'bxx;
                memwrite = 0;
                memsize = 3'bxxx;
                memtoreg = 0;
                branch = 0;
                regwrite = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                $display("Warning: INST w/ opcode %d", op);
            end
        endcase
    endmodule
