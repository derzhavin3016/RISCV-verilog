`include "opcodes.v"
`include "consts.v"

module maindec(input logic[6:0] op,
                   input logic[2:0] funct3,
                   output logic memtoreg, memwrite,
                   output logic[2:0] memsize,
                   output logic branch,
                   output logic[1:0] alusrc,
                   output logic alusrc_a_zero,
                   output logic regwrite,
                   output logic jump,
                   output logic jumpsrc, // add to imm 0 for pc, 1 for rs1
                   output logic hlt
                  );

    always_comb
        case(op)
            `OPC_AUIPC: begin
                alusrc = `ALU_SRC_PC;
                alusrc_a_zero = 1;
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
                alusrc = `ALU_SRC_IMM;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                hlt = 0;
            end
            `OPC_R_TYPE: begin
                alusrc = `ALU_SRC_REG;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_BRANCH: begin
                alusrc = `ALU_SRC_REG;
                branch = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                regwrite = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_JAL, `OPC_JALR: begin
                jumpsrc = (op == `OPC_JALR);
                alusrc = `ALU_SRC_NPC;
                alusrc_a_zero = 1;
                jump = 1;
                regwrite = 1;
                memsize = 3'bxxx;
                memtoreg = 0;
                memwrite = 0;
                branch = 0;
                hlt = 0;
            end
            `OPC_LOAD: begin
                alusrc = `ALU_SRC_IMM;
                regwrite = 1;
                memtoreg = 1;
                memsize = funct3;
                memwrite = 0;
                branch = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_STORE: begin
                alusrc = `ALU_SRC_IMM;
                memwrite = 1;
                memsize = funct3;
                memtoreg = 0;
                branch = 0;
                regwrite = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                hlt = 0;
            end
            `OPC_SYSTEM: begin
                hlt = 1;
                alusrc = 2'bxx;
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
                hlt = 1;
                alusrc = 2'bxx;
                memwrite = 0;
                memsize = 3'bxxx;
                memtoreg = 0;
                branch = 0;
                regwrite = 0;
                jump = 0;
                jumpsrc = 0;
                alusrc_a_zero = 0;
                $display("UNHANDLEN INST");
                $finish;
            end
        endcase
    endmodule
