module modulo_entrada
#(parameter TAM_ENTRADA=4)
(   		
    input wire [TAM_ENTRADA-1:0] switch_imediato,
    output reg [TAM_ENTRADA-1:0] o_entrada,
    output reg [4:0] o_registrador
);


    always @(*) begin 
        o_entrada = switch_imediato;
        o_registrador = 28;
    end


endmodule