module modulo_saida(
	input wire clock,
   input wire [31:0] registrador_e,
	input wire [1:0] sel_clock,
   output wire [7:0] display1, display2, display3, display4
);	
		reg [3:0] d_display1, d_display2, d_display3, d_display4; 
		reg [31:0] valor_para_exibir;

		always @(negedge clock) begin
			if(sel_clock == 2'b01)begin
				// Trunca o valor para o máximo de 4 dígitos (9999)
				if (registrador_e > 9999) begin
					valor_para_exibir = 9999;
				end else begin
                    valor_para_exibir = registrador_e;
                end

                d_display4 = (valor_para_exibir % 10);
                d_display3 = (valor_para_exibir / 10) % 10;
                d_display2 = (valor_para_exibir / 100) % 10;
                d_display1 = (valor_para_exibir / 1000) % 10; 
            end		   
        end
        
    bcd bcd1(
        .entrada(d_display1), 
        .display_7(display1)
    );
    bcd bcd2(
        .entrada(d_display2), 
        .display_7(display2)
    );
    bcd bcd3(
        .entrada(d_display3), 
        .display_7(display3)
    );
    bcd bcd4(
        .entrada(d_display4), 
        .display_7(display4)
    );


endmodule
