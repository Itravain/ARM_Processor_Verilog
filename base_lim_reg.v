/**
 * @module base_lim_reg
 * @brief Unidade de Proteção de Memória (MPU) com escrita centralizada.
 *
 * Armazena registradores de base e limite para os segmentos de instrução e dados.
 * A escrita é controlada por uma única instrução, onde 'write_addr' atua como
 * um seletor para o registrador de destino.
 * A tradução de endereço (base + offset) e a verificação de limite são realizadas
 * de forma combinacional para os desvios.
 */
module base_lim_reg (
    // --- Interface de Escrita (controlada por uma instrução do SO) ---
    input wire         write_clock,       // Clock para a operação de escrita
    input wire         we,                // Write Enable - ativa a escrita
    input wire  [1:0]  write_addr,      // Seletor do registrador de destino:
                                        // 00: base_inst, 01: limit_inst
                                        // 10: base_data, 11: limit_data
    input wire  [31:0] w_data,            // Dado de 32 bits a ser escrito

    // --- Interface de Tradução/Verificação (para o datapath) ---
    input wire         jump,              // '1' se a instrução atual é um desvio
    input wire  [31:0] in_inst_logical,   // Endereço LÓGICO do desvio
	 input wire  [31:0] in_data_logical,   // Endereço LÓGICO para acesso a dados (se necessário)

    // --- Saídas ---
    output reg [31:0] physical_addr_out, // Endereço FÍSICO traduzido para o PC
	 output reg [31:0] out_base_lim_data,
    output reg        seg_fault          // '1' se ocorrer uma falha de segmentação
);

    // --- Armazenamento Interno: 4 registradores nomeados de 32 bits ---
    reg [31:0] base_inst_reg;
    reg [31:0] limit_inst_reg;
    reg [31:0] base_data_reg;
    reg [31:0] limit_data_reg;

    // Bloco 1: Lógica de Escrita SINCRONA
    // Atualiza um dos quatro registradores no pulso de clock se 'we' estiver ativo.
    always @(posedge write_clock) begin
        if (we) begin
            case (write_addr)
                2'b00: base_inst_reg  <= w_data;
                2'b01: limit_inst_reg <= w_data;
                2'b10: base_data_reg  <= w_data;
                2'b11: limit_data_reg <= w_data;
            endcase
        end
    end

    // Bloco 2: Lógica de Tradução e Verificação COMBINACIONAL
    // Esta lógica está sempre ativa, calculando as saídas com base nas entradas atuais.
    always @(*) begin
        // Verificação de Limite para Instruções
        // A falha ocorre se um desvio tenta acessar um endereço LÓGICO maior ou igual ao limite.
        if (jump && (in_inst_logical >= limit_inst_reg)) begin
            seg_fault = 1'b1;
        end else begin
            // Adicionar aqui a verificação para acesso a dados se necessário
            // Ex: if (mem_access && (in_data_logical >= limit_data_reg))
            seg_fault = 1'b0;
        end
		  out_base_lim_data = in_data_logical + base_data_reg;
        physical_addr_out = base_inst_reg + in_inst_logical;
    end

endmodule