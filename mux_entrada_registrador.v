module mux_entrada_registrador(
	input wire [4:0] rd, entrada_registrador,
	input wire [1:0] sel_clock,
	output wire [4:0] out_mux_entrada_registrador
);

	reg [4:0] r_out_mux_entrada_registrador;
	

	always @ (*) begin
		if (sel_clock == 2'b10) begin
			r_out_mux_entrada_registrador = entrada_registrador;
		end
		else begin
			r_out_mux_entrada_registrador = rd;
		end
	end
	
	assign out_mux_entrada_registrador = r_out_mux_entrada_registrador;
	
	
endmodule 