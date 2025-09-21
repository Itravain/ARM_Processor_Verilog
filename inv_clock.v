module inv_clock(
	input wire clk,
	output wire clk_inv
);

	assign clk_inv = ~clk;
	
endmodule