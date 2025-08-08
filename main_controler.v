`ifndef PARAM
	`include "Parametros.v"
`endif


module main_controler(
	 input  wire [6:0] opcode,
    output reg        RegWrite, // Escreve no registrador
    output reg        MemRead, // Leitura na memoria
    output reg        MemWrite, // escreve na memoria
    output reg        MemtoReg, // Dado da memoria para o registrador
    output reg        Branch, // Desvio condicional
    output reg        ALUorig, // Origem do operando ULA
    output reg        Jump,	// Instrução de salto
	 output reg			 Jump2,  // Intrução de salto JALR
    output reg  [1:0] ALUOp	// tipo R olhe para fct3 e fct7
);

always @(*) begin
    case (opcode)
        OPC_RTYPE: begin // add, sub, and, or, slt
            RegWrite = 1; 
            ALUorig   = 0; 
            MemtoReg = 0; 
            MemRead  = 0; 
            MemWrite = 0; 
            Branch   = 0; 
            Jump     = 0; // Instrução de salto
            Jump2     = 0;
				ALUOp    = 2'b10; 
        end
        OPC_OPIMM: begin // addi
            RegWrite = 1;
            ALUorig   = 1;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            Jump     = 0;
				Jump2     = 0;
            ALUOp    = 2'b00; //soma
        end
        OPC_LOAD: begin // lw
            RegWrite = 1;
            ALUorig  = 1;
            MemtoReg = 1;
            MemRead  = 1;
            MemWrite = 0;
            Branch   = 0;
            Jump     = 0;
				Jump2     = 0;
            ALUOp    = 2'b00; //soma
        end
		  OPC_STORE: begin // sw
				RegWrite = 0;
            ALUorig   = 1;
            MemRead  = 0;
            MemWrite = 1;
            Branch   = 0;
            Jump     = 0;
				Jump2     = 0;
            ALUOp    = 2'b00; //soma
			end
			OPC_BRANCH: begin // beq
				RegWrite = 0;
            ALUorig   = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 1;
            Jump     = 0;
				Jump2     = 0;
            ALUOp    = 2'b01; // sub
			end
			OPC_JAL: begin
				RegWrite = 1;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            Jump     = 1;
				Jump2    = 0;
			end
			OPC_JALR: begin //jalr
				RegWrite = 1;
            ALUorig  = 1;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
				Jump     = 1;
				Jump2    = 1;
				ALUOp    = 2'b00;
			end
        default: begin // Caso nenhuma das opcoes.
            RegWrite = 0;
            ALUorig  = 0;
            MemtoReg = 0;
            MemRead  = 0;
            MemWrite = 0;
            Branch   = 0;
            Jump     = 0;
				Jump2    = 0;
            ALUOp    = 2'b00;
        end
    endcase
end

endmodule
