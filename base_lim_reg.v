/**
 * @module base_lim_reg
 * @brief Unidade de Proteção de Memória (MPU) simplificada (Apenas Base).
 *
 * Controla o offset de base para instruções e dados separadamente.
 * Funciona como um switch:
 * - Se ativado (ON): 
 * Adiciona 1850 aos endereços de instrução.
 * Adiciona 1024 aos endereços de dados.
 * - Se desativado (OFF): 
 * Adiciona 0 aos endereços lógicos (pass-through).
 */
module base_lim_reg (
    // --- Interface de Controle (Switch ON/OFF) ---
    input wire         write_clock,       // Clock para a operação de escrita
    input wire         we,                // Write Enable - ativa a mudança de estado

    // --- Interface de Tradução (para o datapath) ---
    input wire  [31:0] in_inst_logical,   // Endereço LÓGICO da instrução
    input wire  [31:0] in_data_logical,   // Endereço LÓGICO de dados

    // --- Saídas ---
    output reg [31:0] physical_addr_out,
    output reg [31:0] out_base_lim_data 
);

    reg [31:0] base_inst;
    reg [31:0] base_data;

    initial begin
        base_inst = 0;
        base_data = 0;
    end

    // Bloco 1: Lógica de Controle (Switch)
    always @(posedge write_clock) begin
        if (we) begin
            // Verifica se está "Desligado"
            if (base_inst == 0) begin
                base_inst <= 1850; // Instrução
                base_data <= 1024; // Dados
            end else begin
                // Se já estava ligado, reseta ambos para 0
                base_inst <= 0;
                base_data <= 0;
            end
        end
    end

    // Bloco 2: Lógica de Tradução COMBINACIONAL
    // Soma a base específica ao tipo de endereço
    always @(*) begin
        physical_addr_out = in_inst_logical + base_inst; //1850 
        out_base_lim_data = in_data_logical + base_data; //1024
    end

endmodule