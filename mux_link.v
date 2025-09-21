module mux_link (in_link, in_pc, in_link_atual, mux_out_link);
	input wire 	in_link;
	input wire [31:0] in_pc, in_link_atual;
	
	reg [31:0] r_out_link;
		
	output wire [31:0] mux_out_link;
	
	always @ (*) begin
		if (in_link == 1) begin
			r_out_link = in_pc;
		end
		else begin
			r_out_link = in_link_atual;
		end
	end
	
	assign mux_out_link = r_out_link;


endmodule 