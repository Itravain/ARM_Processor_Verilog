module pc (	input clock,
				input wire [31:0] novo_estado,
				output wire [31:0] o_pc
);
	reg [31:0] pc; 

	always @(posedge clock)
	begin
		pc <= novo_estado;
	end
		

assign o_pc = pc;
endmodule 