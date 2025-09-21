module mux_entrada_imediato(
	input wire [31:0] dado_um, entrada,
	input wire [1:0] sel_clock,
	output wire [31:0] out_mux_entrada_imediato
);

	reg [31:0] r_out_imm_entrada;
	

	always @ (*) begin
		if (sel_clock == 2'b10) begin
			r_out_imm_entrada = entrada;
		end
		else begin
			r_out_imm_entrada = dado_um;
		end
	end
	
	assign out_mux_entrada_imediato = r_out_imm_entrada;
	
	
endmodule 