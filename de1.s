.data
.word 1

.text
	li gp,0x10010000 # gp = 0x10010000
	addi t1, zero, 4 # t1 = 4  
	lw t2, 0(gp) # t2 = 1
	addi t0, t2, 0  #t0 = 1
	add t0, t0, t1 # t0 = 5 
	sub t0, t0, t1 # t0  = 1
	slt t0, t1, t0 # t0 = 0
	or t0, t0, t2 # t0 = 1
	and t0, t0, zero # t0 = 0
	beq t0, t1, exit # Não Pula só pra testar
	nop 
	beq t0, zero, pula # pula para "pula" 
	nop
exit:	
	jalr ra, ra, 0 # pula para o endereco salvo em ra
	nop
	nop
	nop
pula:	
	jal ra, exit # pula para o label exit e salva o endereco em ra
	nop
	nop
	nop
	addi t0,t1, 10 # t0 = 14
	sw t0, 4(gp) # armazena o t0(14) em gp+4
	
	
