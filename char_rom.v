/**
 * char_rom.v
 * Memória ROM para uma fonte 8x8.
 * Requer um arquivo de memória "font_8x8.mem" para inicialização.
 */
module char_rom #(
    parameter FONT_CHARS = 128,  // Número de caracteres na fonte
    parameter FONT_HEIGHT = 8,   // MODIFICADO: Altura da fonte em pixels
    parameter ADDR_WIDTH = 10,   // MODIFICADO: 7 bits (ASCII) + 3 bits (linha) = 10 bits
    parameter DATA_WIDTH = 8     // Largura da fonte em pixels
)(
    input wire [ADDR_WIDTH-1:0] addr,
    output wire [DATA_WIDTH-1:0] data_out
);

    localparam ROM_DEPTH = FONT_CHARS * FONT_HEIGHT; // 128 * 8 = 1024

    reg [DATA_WIDTH-1:0] rom[ROM_DEPTH-1:0];

    initial begin
        // O arquivo deve conter 1024 linhas de 8 bits em binário.
        // Ex: as 8 linhas para 'A' (ASCII 65) começam no endereço 65 * 8 = 520.
        $readmemb("font_8x8.mem", rom);
    end

    assign data_out = rom[addr];

endmodule