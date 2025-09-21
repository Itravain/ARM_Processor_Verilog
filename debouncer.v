module debouncer (
    input  wire clk,      // Clock de entrada
    input  wire btn_in,   // Entrada do botão (geralmente ativa em nível baixo)
    output reg  o_btn // Saída com debouncer
);

    reg ff;
	 
	 initial begin 
		ff = 1'b1;
	 end
	 
	 always @(posedge clk) begin
		ff <= btn_in;
	 end
	 
	 always @(posedge clk) begin
		if (ff == 1'b0) begin
			o_btn <= 1'b0;
		end 
		else if (ff == 1'b1) begin
			o_btn <= 1'b1;
		end
	 
	 end

endmodule
