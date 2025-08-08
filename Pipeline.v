`ifndef PARAM
	`include "Parametros.v"
`endif

module Pipeline (
	input logic clockCPU, clockMem,
	input logic reset,
	output logic [31:0] PC,
	output logic [31:0] Instr,
	input  logic [4:0] regin,
	output logic [31:0] regout
	);
	

	// IF/ID
	reg [31:0] IF_ID_PC, IF_ID_MI;

	// ID/EX
	reg [31:0] ID_EX_PC, ID_EX_A, ID_EX_B, ID_EX_Imm;
	reg [4:0]  ID_EX_RD;
	reg [1:0]  ID_EX_WB;
	reg [2:0]  ID_EX_M, ID_EX_EX;
	reg ID_EX_JALR;

	// EX/MEM
	reg [31:0] EX_MEM_ALU, EX_MEM_B, EX_MEM_PC;
	reg [4:0]  EX_MEM_RD;
	reg [1:0]  EX_MEM_WB;
	reg [2:0]  EX_MEM_M;

	// MEM/WB
	reg [31:0] MEM_WB_ALU, MEM_WB_MemData, MEM_WB_PC;
	reg [4:0]  MEM_WB_RD;
	reg [1:0]  MEM_WB_WB;


	wire [31:0] A, B, SaidaImm;
	wire [3:0]  ALUControl;
	wire [31:0] SaidaULA;
	wire        Zero = (A == B);
	wire        EscreveReg, MemToReg, MemRead, MemWrite, Branch, ALUOrig, jal, jalr;
	wire [1:0]  ALUOp;
	
	wire [31:0] PCImm = IF_ID_PC + SaidaImm;
	
	wire portaAnd = Branch & Zero;
	wire portaOr  = portaAnd | jal;
	
	wire [31:0] PCNext = (portaOr) ? PCImm : PC + 4; // MUX PC
	
	
	
	
	wire [31:0] muxMem = (MEM_WB_WB[0]) ? MEM_WB_MemData : MEM_WB_ALU;
	
		// Atualiza PC
	always @(posedge clockCPU or posedge reset) begin
		if (reset) begin
			PC <= TEXT_ADDRESS;
		end else if (jalr == 1'b1) begin
			 PC <= A + SaidaImm;
		//end else if (ID_EX_JALR == 1'b1) begin
			 //PC <= SaidaULA;
		end else begin
			PC <= PCNext;
		end
	end

	// IF/ID
	always @(posedge clockCPU) begin
		IF_ID_MI <= Instr;
	end

	// ID/EX
	always @(posedge clockCPU or posedge reset) begin
		if (reset) begin
			ID_EX_PC 			<= 0; 
			ID_EX_Imm 			<= 0; 
			ID_EX_A 				<= 0; 
			ID_EX_B 				<= 0; 
			ID_EX_RD 			<= 0;
			ID_EX_EX 			<= 0; 
			ID_EX_M 				<= 0; 
			ID_EX_WB 			<= 0;
		end else begin
			IF_ID_PC 			<= PC;
			ID_EX_Imm 			<= SaidaImm;
			ID_EX_JALR			<= jalr;
			ID_EX_A 				<= A;
			ID_EX_B 				<= B;
			ID_EX_RD 			<= IF_ID_MI[11:7];
			ID_EX_EX 			<= {ALUOrig, ALUOp};
			ID_EX_M 				<= {MemRead, MemWrite, Branch};
			ID_EX_WB 			<= {EscreveReg, MemToReg};
		end
	end

	// EX/MEM
	always @(posedge clockCPU) begin
		EX_MEM_ALU 			<= SaidaULA;
		EX_MEM_B 			<= ID_EX_B;
		EX_MEM_RD 			<= ID_EX_RD;
		EX_MEM_M 			<= ID_EX_M;
		EX_MEM_WB 			<= ID_EX_WB;
	end

	// MEM/WB
	always @(posedge clockCPU) begin
		MEM_WB_ALU 			<= EX_MEM_ALU;
		MEM_WB_RD 			<= EX_MEM_RD;
		MEM_WB_WB 			<= EX_MEM_WB;
	end

	//=========================//
	//  MEMÓRIAS
	//=========================//

	ramI MemInstr (
		.address(PC[11:2]),
		.clock(clockMem),
		.data(),
		.wren(1'b0),
		.q(Instr)
	);

	ramD MemData (
		.address(EX_MEM_ALU[11:2]),
		.clock(clockMem),
		.data(EX_MEM_B),
		.wren(EX_MEM_M[1]),
		.q(MEM_WB_MemData)
	);

	//=========================//
	//  COMPONENTES
	//=========================//

	main_controler Control (
		.opcode(IF_ID_MI[6:0]),
		.RegWrite(EscreveReg),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemtoReg(MemToReg),
		.Branch(Branch),
		.ALUorig(ALUOrig),
		.Jump(jal),
		.Jump2(jalr),
		.ALUOp(ALUOp)
	);

	ALU_Controler ALUCtrl (
		.ALUOp(ID_EX_EX[1:0]), // ALUOp
		.funct3(IF_ID_MI[14:12]),
		.funct7(IF_ID_MI[31:25]),
		.ALUControl(ALUControl)
	);

	ImmGen ImmG (
		.iInstrucao(IF_ID_MI),
		.oImm(SaidaImm)
	);

	Registers BancoReg (
		.iCLK(clockCPU),
		.iRST(reset),
		.iRegWrite(MEM_WB_WB[1]),
		.iReadRegister1(IF_ID_MI[19:15]),
		.iReadRegister2(IF_ID_MI[24:20]),
		.iWriteRegister((jal) ? IF_ID_MI[11:7] : MEM_WB_RD),
		.iWriteData((jal) ? IF_ID_PC + 4 : muxMem),
		.oReadData1(A),
		.oReadData2(B),
		.iRegDispSelect(regin),
		.oRegDisp(regout)
	);

	ALU ULA (
		.iControl(ALUControl),
		.iA(ID_EX_A),
		.iB(ID_EX_EX[2] ? ID_EX_Imm : ID_EX_B),
		.oResult(SaidaULA),
		.oZero()
	);

endmodule
