module somador_pc (
	input wire [31:0] in_pc,
	output wire [31:0] out_somador_pc
);

assign out_somador_pc = in_pc + 1; 

endmodule 