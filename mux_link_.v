module mux_link_ (
	input wire 	control,
	input wire [31:0] in_zero, in_one,
	output wire [31:0] m_out
);
	
	
	reg [31:0] r_out;
		
	
	
	always @ (*) begin
		if (control == 0) begin
			r_out = in_zero;
		end
		else begin
			r_out = in_one;
		end
	end
	
	assign m_out = r_out;


endmodule 
