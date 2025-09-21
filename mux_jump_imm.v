module mux_jump_imm (in_i, in_dado_um, in_imm, out_mux_jump_imm);
	input wire 	in_i;
	input wire [31:0] in_dado_um, in_imm;
	
	reg [31:0] r_out_dado_imm;
		
	output wire [31:0] out_mux_jump_imm;
	
	always @ (*) begin
		if (in_i == 0) begin
			r_out_dado_imm = in_dado_um;
		end
		else begin
			r_out_dado_imm = in_imm;
		end
	end
	
	assign out_mux_jump_imm = r_out_dado_imm;


endmodule 
