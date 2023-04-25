`include "opcodes.v"
`include "aluop.v"

module aludec (input [6:0] opcode,
                   input [2:0] funct3,
                   input [6:0] funct7,
                   output reg [3:0] alucontrol,
                   output inv_br
                  );
    assign inv_br = funct3[0];
    always_latch
        case(opcode)
            `OPC_LUI, `OPC_AUIPC, `OPC_JAL, `OPC_JALR, `OPC_LOAD, `OPC_STORE, `OPC_SYSTEM:
                alucontrol = `ALU_ADD;
            `OPC_BRANCH:
            case (funct3)
                3'b000, 3'b001: begin
                    inv_br = funct3 == 3'b001;
                    alucontrol = `ALU_SUB; // beq, bne
                end
                3'b100, 3'b101:
                    alucontrol = `ALU_SLT; // blt, bge
                3'b110, 3'b111:
                    alucontrol = `ALU_SLTU; // bltu, bgeu
                default:
                    alucontrol = 4'bxxxx;
            endcase
            `OPC_R_TYPE, `OPC_I_TYPE: begin
                logic funct7_zero = (funct7 == 0);
                case (funct3)
                    3'b000:
                        alucontrol = (opcode == `OPC_I_TYPE) || funct7_zero ? `ALU_ADD : `ALU_SUB;
                    3'b001:
                        alucontrol = `ALU_SLL;
                    3'b010:
                        alucontrol = `ALU_SLT;
                    3'b011:
                        alucontrol = `ALU_SLTU;
                    3'b100:
                        alucontrol = `ALU_XOR;
                    3'b101:
                        alucontrol = funct7_zero ? `ALU_SRL : `ALU_SRA;
                    3'b110:
                        alucontrol = `ALU_OR;
                    3'b111:
                        alucontrol = `ALU_AND;
                    default:
                        alucontrol = 4'bxxxx;
                endcase
            end
            default:
                alucontrol = 4'bxxxx;
        endcase
    endmodule
