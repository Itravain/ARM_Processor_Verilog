module unidade_instrucao (instrucao, in_cpsr, rn, rm, rd, imm, controle);
	input wire [31:0] instrucao;
	// Formato: [N, Z, C, V]
	input wire [3:0] in_cpsr;
	
	reg [4:0] r_rn, r_rm, r_rd;
	reg [31:0] r_imm;
	reg [10:0] r_controle;
	reg verificacao;
	
	output wire [4:0] rn, rm, rd;
	output wire [31:0] imm;
	output wire [10:0] controle;

// Mapeia as flags para nomes mais legíveis
    wire N, Z, C, V;
    assign N = in_cpsr[3];
    assign Z = in_cpsr[2];
    assign C = in_cpsr[1];
    assign V = in_cpsr[0];
	
	always @ (*)	begin
		verificacao = 0;
		case(instrucao[31:28])
            4'b0000: verificacao = (Z == 1);                  // EQ - Equal
            4'b0001: verificacao = (Z == 0);                  // NE - Not Equal
            4'b0010: verificacao = (C == 1);                  // CS/HS - Carry Set / Unsigned Higher or Same
            4'b0011: verificacao = (C == 0);                  // CC/LO - Carry Clear / Unsigned Lower
            4'b0100: verificacao = (N == 1);                  // MI - Minus/Negative
            4'b0101: verificacao = (N == 0);                  // PL - Plus/Positive or zero
            4'b0110: verificacao = (V == 1);                  // VS - Overflow
            4'b0111: verificacao = (V == 0);                  // VC - No Overflow
            4'b1000: verificacao = (C == 1 && Z == 0);        // HI - Unsigned Higher
            4'b1001: verificacao = (C == 0 || Z == 1);        // LS - Unsigned Lower or Same
            4'b1010: verificacao = (N == V);                  // GE - Signed Greater Than or Equal
            4'b1011: verificacao = (N != V);                  // LT - Signed Less Than
            4'b1100: verificacao = (Z == 0 && N == V);        // GT - Signed Greater Than
            4'b1101: verificacao = (Z == 1 || N != V);        // LE - Signed Less Than or Equal
            4'b1110: verificacao = 1;                         // AL - Always
            default: verificacao = 0;                         // Should not happen
        endcase 
	
		if (verificacao) begin
			case({instrucao[27], instrucao[26]})
			// Processamento de dados
			2'b00 : 	begin 
				r_rn = instrucao [19:15];
				r_rd = instrucao [14:10];
				// sel, I, S, L/s, L, U, Opcode
				r_controle = {2'b00, instrucao[25], instrucao[20], 1'b0, 1'b0, 1'b0, instrucao[24:21]};
				
				if (instrucao [25] == 1) begin // se a instrução possuir imediato
					r_imm = instrucao [9:0];
					r_rm = 5'b0;
				end
				else begin
					r_imm = 24'b0;
					r_rm = instrucao [9:5];
				end
			end // <-- CORREÇÃO: Faltava este 'end'

			//Transferencia de dados
			2'b01 :	begin
				r_rn = instrucao [22:18];
				if (instrucao [23] == 1) begin
					r_rm = 5'b0;
					r_rd = instrucao [17:13];						
				end
				else begin
					r_rm = instrucao [17:13];
					r_rd = 5'b0;
				end
				r_imm = instrucao [12:0];
				// sel, I, S, L/s, L, U, Opcode
				r_controle = {2'b01, instrucao[25], 1'b0, instrucao[23], 1'b0, instrucao[24], 4'b0};	
			end
						
			//Operações de desvio
			2'b10 :	begin
				r_rd = 5'b0;
				r_rm = 5'b0;
				// sel, I, S, L/s, L, U, Opcode
				r_controle = {2'b10, instrucao[25], 1'b0, 1'b0, instrucao[24], 1'b0, 4'b0};	
				
				if (instrucao [25] == 1) begin // se a instrução possuir imediato
					r_imm = instrucao [23:0];
					r_rn = 5'b0;
				end
				else begin
					r_imm = 24'b0;
					r_rn = instrucao [23:19];
				end
			end
						
			//Outras instruções
			2'b11 :	begin
				/* Define valores padrão para os registradores */
				r_rn = 5'b0;
				r_rm = 5'b0;
				r_rd = 5'b0;
				r_imm = 23'b0;

				case (instrucao[25:23])
					/* OUT */
					3'b010 : begin
						r_rn = 5'b11101; /* Registrador especial para a saída */
						/* sel, I, S, L/s, L=0, U, Opcode */
						r_controle = {2'b11, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, {1'b0,instrucao[25:23]}};
					end
					
					/* SBL */
					3'b100 : begin
						r_rn = instrucao[22:18];
						r_rm = instrucao[17:13];
						/* sel, I, S, L/s, L=0, U, Opcode */
						r_controle = {2'b11, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, {1'b0,instrucao[25:23]}};
					end
					
					/* SIR */
					3'b101 : begin
						r_rn = instrucao[22:18];
						r_imm = instrucao[17:13];
						/* sel, I, S, L/s, L=0, U, Opcode */
						r_controle = {2'b11, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, {1'b0,instrucao[25:23]}};
					end

					/* SPL - Store PC to Link */
					3'b110 : begin
						/* A única ação é gerar o sinal de controle correto. */
						/* sel, I, S, L/s, L=1, U, Opcode */
						r_controle = {2'b11, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, {1'b0,instrucao[25:23]}};
					end

					default : begin
						/* Comportamento padrão para outras instruções (NOP, IN, FINISH) */
						/* sel, I, S, L/s, L=0, U, Opcode */
						r_controle = {2'b11, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, {1'b0,instrucao[25:23]}};
					end
				endcase
			end
			endcase
		end
		// Caso o CPSR seja diferente do cond a instrução executada será a NOP
		else begin
			r_rn = 5'b0;
			r_rm = 5'b0;
			r_rd = 5'b0;
			r_imm = 23'b0;
			// sel, I, S, L/s, L, U, Opcode
			r_controle = {2'b11, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 4'b0};
		end 
	end

	assign rn = r_rn;
	assign rd = r_rd;
	assign rm = r_rm;
	assign imm = r_imm;
	assign controle = r_controle;
	
endmodule