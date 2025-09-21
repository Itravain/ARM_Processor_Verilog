module unidade_controle (
		input wire [10:0] controle,
		output reg	jump, memWrite, memToReg, s, i, regWrite, link, RBaseLimWrite, FinishInterrupt, InterruptWrite,
		output reg [1:0] sel_clock,
		output reg [3:0] sel
);
	
	always @ (*) begin
		RBaseLimWrite = 0;
		FinishInterrupt = 0;
		InterruptWrite = 0;
		case (controle[10:9])
			//instruções de processamento de dados
			2'b00 : begin
				memWrite = 1'b0;
				memToReg = 0;
				jump = 0;
				sel_clock = 2'b00;
				
				case (controle[3:0])
					//AND
					4'b0001 : begin 
						sel = 4'b0000;
						regWrite = 1;			
					end
					
					//EOR
					4'b0010 : begin 
						sel = 4'b0001;
						regWrite = 1;			
					end
					
					//SUB
					4'b0011 : begin 
						sel = 4'b0011;
						regWrite = 1;			
					end
					
					//ADD 
					4'b0101 : begin 
						sel = 4'b0100;
						regWrite = 1;			
					end
					
					//MRS
					4'b0110 : begin
						sel = 4'b0100;
						regWrite = 1;
					end
					
					//MSR
					4'b0111 : begin
						sel = 4'b0100;
						regWrite = 1;
					end
					
					//TST
					4'b1000 : begin
						sel = 4'b0000;
						regWrite = 0;
					end
					
					//CMP
					4'b1010 : begin
						sel = 4'b0011;
						regWrite = 0;
					end
					
					//ORR
					4'b1100 : begin 
						sel = 4'b0010;
						regWrite = 1;			
					end
					
					//MOV
					4'b1101 : begin 
						sel = 4'b0100;
						regWrite = 1;			
					end
					
					//MUL
					4'b1110 : begin 
						sel = 4'b0101;
						regWrite = 1;			
					end
					
					//UDIV
					4'b1111 : begin 
						sel = 4'b0110;
						regWrite = 1;			
					end
					default: begin
						sel = 4'bxxxx; // Or a safe default like 4'b0000
						regWrite = 1'b0;
					end
				endcase			
			end
			
			//Transferência de dados
			2'b01 : begin 
				jump = 0;
				sel = 4'b0100;
				sel_clock = 2'b00;
				
				//Instruções de load
				if (controle[6] == 1) begin
						memWrite = 0;
						memToReg = 1;
						regWrite = 1;
				end
					
				//Instruções de store
				else begin
					memWrite = 1;
					memToReg = 0;
					regWrite = 0;		
				end
			end
			
			//Instruções de desvio
			2'b10 : begin
				jump = 1;
				sel = 4'b0100;
				memWrite = 0;
				memToReg = 0;
				regWrite = 0;
				sel_clock = 2'b00;
			end
			//OUTROS
			2'b11 :begin
				case (controle[3:0])
					//NOP
					4'b0000 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 0;
						sel_clock = 2'b00;
					end
					//IN
					4'b0001 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 1;
						sel_clock = 2'b10;
					end
					//OUT
					4'b0010 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 0;
						sel_clock = 2'b01;
					end
					//FINISH
					4'b0011 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 0;
						sel_clock = 2'b11;
						FinishInterrupt = 1'b1;
					end
					//SBL
					4'b0100 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 0;
						sel_clock = 2'b00;
						RBaseLimWrite = 1'b1;
					end
					//SIR
					4'b0101 : begin
						jump = 0;
						sel = 4'b0100;
						memWrite = 0;
						memToReg = 0;
						regWrite = 0;
						sel_clock = 2'b00;
						InterruptWrite = 1'b1;
					end
					default: begin
					  jump = 0;
					  sel = 4'bxxxx; // Or a safe default
					  memWrite = 0;
					  memToReg = 0;
					  regWrite = 0;
					  sel_clock = 2'b00;
					end
				endcase 
			end
		endcase 
		
		i = controle [8];
		s = controle [7];
		link = controle [5];
	
	end
endmodule	