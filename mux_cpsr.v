module mux_cpsr (in_s, in_atual, in_novo, out_mux_cpsr);
	input wire 	in_s;
	input wire [3:0] in_atual, in_novo;
	
	reg [3:0] r_out_cpsr;
		
	output wire [3:0] out_mux_cpsr;
	
	always @ (*) begin
		if (in_s == 0) begin
			r_out_cpsr = in_atual;
		end
		else begin
			r_out_cpsr = in_novo;
		end
	end
	
	assign out_mux_cpsr = r_out_cpsr;

endmodule 
