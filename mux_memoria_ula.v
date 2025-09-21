// MUX 4-para-1: Seleciona qual dado será escrito de volta ao banco de registradores.
module mux_memoria_ula (
    // ENTRADAS DE DADOS
    input wire [31:0] in_ula,       // Dado vindo da ULA
    input wire [31:0] in_ram,       // Dado lido da Memória RAM
    input wire [31:0] in_timer,  // Dado lido da Memória de Instruções
    input wire [31:0] in_hd,        // Dado lido da Memória HD

    // SINAL DE SELEÇÃO (vindo do memory_selector)
    input wire [1:0]  sel,
    // SAÍDA
    output reg [31:0] out_mux_memoria_ula
);

    always @(*) begin
        case (sel)
            // sel = 00: ULA.
            // (Operações aritméticas, lógicas, etc.)
            2'b00: begin
                out_mux_memoria_ula = in_ula;
            end

            // sel = 01: Memória RAM.
            // (Resultado de uma instrução LDR na RAM)
            2'b01: begin
                out_mux_memoria_ula = in_ram;
            end

            // sel = 10: Memória de Instruções.
            2'b10: begin
                out_mux_memoria_ula = in_timer;
            end

            // sel = 11: Memória HD.
            2'b11: begin
                out_mux_memoria_ula = in_hd;
            end
            
            default: begin
                out_mux_memoria_ula = 32'hxxxxxxxx; 
            end
        endcase
    end

endmodule