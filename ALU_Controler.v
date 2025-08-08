`ifndef PARAM
	`include "Parametros.v"
`endif


module ALU_Controler (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [4:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = OPADD; // lw, sw, jalr
        2'b01: ALUControl = OPSUB; // beq
        2'b10: begin // R-type ou I-type
            case ({funct7, funct3})
                {7'b0000000, 3'b000}: ALUControl = OPADD; // add
                {7'b0100000, 3'b000}: ALUControl = OPSUB; // sub
                {7'b0000000, 3'b111}: ALUControl = OPAND; // and
                {7'b0000000, 3'b110}: ALUControl = OPOR;  // or
                {7'b0000000, 3'b010}: ALUControl = OPSLT; // slt
                default:              ALUControl = OPNULL;
            endcase
        end
        default: ALUControl = OPNULL;
    endcase
end

endmodule
