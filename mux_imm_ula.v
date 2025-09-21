module mux_imm_ula (in_i, in_dado_dois, in_imm, out_imm_ula);
	input wire 	in_i;
	input wire [31:0] in_dado_dois, in_imm;
	
	reg [31:0] r_out_imm_ula;
		
	output wire [31:0] out_imm_ula;
	
	always @ (*) begin
		if (in_i == 0) begin
			r_out_imm_ula = in_dado_dois;
		end
		else begin
			r_out_imm_ula = in_imm;
		end
	end
	
	assign out_imm_ula = r_out_imm_ula;


endmodule 
