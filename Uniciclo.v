`ifndef PARAM
	`include "Parametros.v"
`endif

module Uniciclo (
	input logic clockCPU, clockMem,
	input logic reset,
	output reg [31:0] PC,
	output logic [31:0] Instr,
	input  logic [4:0] regin,  
	output logic [31:0] regout 
);
	
	initial
		begin
			PC<=TEXT_ADDRESS;
			Instr<=32'b0;
			regout<=32'b0;
		end

		
		
	wire [31:0] SaidaULA, Leitura2, dado2mem;
	wire jump, jump2, Mem2Reg, LeMem, Branch, EscreveMem, OrigULA, EscreveReg;
	wire [1:0] ALUOp;
	
	wire [6:0] opcode = Instr[6:0];
	wire [2:0] funct3 = Instr[14:12];
	wire [6:0] funct7 = Instr[31:25];
	wire [4:0] rs1    = Instr[19:15];
	wire [4:0] rs2    = Instr[24:20];
	wire [4:0] rd     = Instr[11:7];
	
	wire [4:0] ALUControl;
	wire [31:0] SaidaImm;
	wire [31:0] dado1, dado2;
	wire [31:0] SaidaMemDado;
	wire ZeroULA;
	
	wire [31:0] PCMais4 = PC + 32'd4;	
	wire [31:0] PCMaisImm  = PC + SaidaImm;
	
	wire SaidaAnd = Branch & ZeroULA; // Porta AND
	wire SaidaOr = SaidaAnd | jump; // Porta OR
	
	
	wire [31:0] WMuxPC = (SaidaOr) ? PCMaisImm : PCMais4;
	
	wire [31:0] MuxPC = (jump2) ? SaidaULA : WMuxPC;
	
	wire [31:0] MuxMem = (Mem2Reg) ? SaidaMemDado : SaidaULA;
	
	wire [31:0] MuxULA = (OrigULA) ? SaidaImm : dado2;
	
	
	wire [31:0] DadoEscrita = (jump) ?  PCMais4 : MuxMem;
	


	
always @(posedge clockCPU  or posedge reset)
begin
	if(reset)
		PC <= TEXT_ADDRESS;
	else
		PC <= MuxPC;
end
		
		
//assign EscreveMem = 1'b0;
//assign LeMem = 1'b1;
//assign SaidaULA = 32'b0;

	
//=============================================================================//
// 												MEMÓRIAS											 //
//=============================================================================//
	
	// Memória de Instruções 
	ramI MemC (
		.address(PC[11:2]),
		.clock(clockMem),
		.data(),
		.wren(1'b0),
		.rden(1'b1),
		.q(Instr)
	);

	// Memória de Dados 
	ramD MemD (
		.address(SaidaULA[11:2]),
		.clock(clockMem),
		.data(dado2),
		.wren(EscreveMem),
		.rden(LeMem),
		.q(SaidaMemDado)
	);	
		
	//Controladora
	main_controler Controle (
	
		.opcode(opcode),
		.RegWrite(EscreveReg),
		.MemRead(LeMem),
		.MemWrite(EscreveMem),
		.MemtoReg(Mem2Reg),
		.Branch(Branch),
		.ALUorig(OrigULA),
		.Jump(jump),
		.Jump2(jump2),
		.ALUOp(ALUOp)
	);
	
			
	//Banco de Registrador
	Registers BancoReg (
		.iCLK(clockCPU),
		.iRST(reset),
		.iRegWrite(EscreveReg),
		.iReadRegister1(rs1),
		.iReadRegister2(rs2),
		.iWriteRegister(rd),
		.iWriteData(DadoEscrita),
		.oReadData1(dado1),
		.oReadData2(dado2),
		.iRegDispSelect(regin),
		.oRegDisp(regout)
	);


	
	//ULA
	ALU ALU (
		.iControl(ALUControl),
		.iA(dado1),
		.iB(MuxULA),
		.oResult(SaidaULA),
		.oZero(ZeroULA)
	);
			
			

//Controlador ULA
	ALU_Controler ALUControlador (
		.ALUOp(ALUOp),
		.funct3(funct3),
		.funct7(funct7),
		.ALUControl(ALUControl)
	);
	
	//Imediato
	ImmGen GeradorImm (
		.iInstrucao(Instr),
		.oImm(SaidaImm)
	);
			
			
			
			
			

			
endmodule