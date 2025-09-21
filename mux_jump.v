module mux_jump (in_jump, in_soma, in_imm, out_mux_jump);
	input wire 	in_jump;
	input wire [31:0] in_soma, in_imm;
	
	reg [31:0] r_out;
		
	output wire [31:0] out_mux_jump;
	
	always @ (*) begin
		if (in_jump == 0) begin
			r_out = in_soma;
		end
		else begin
			r_out = in_imm;
		end
	end
	
	assign out_mux_jump = r_out;


endmodule 