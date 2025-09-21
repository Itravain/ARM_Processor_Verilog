
module text_ram #(
    parameter CHARS_X = 80,       // Caracteres por linha
    parameter CHARS_Y = 60,       // Linhas de caracteres para fonte 8x8
    parameter ADDR_WIDTH = 13,    // 2^13 = 8192, suficiente para 4800 endereços
    parameter DATA_WIDTH = 8      // Largura dos dados (ASCII)
)(
    // --- Porta A: Escrita (Controlada pela CPU) ---
    input wire clk_a,             // NOVO: Clock da CPU (proc_clk)
    input wire wr_en_a,
    input wire [ADDR_WIDTH-1:0] addr_a,
    input wire [DATA_WIDTH-1:0] data_in_a,

    // --- Porta B: Leitura (Controlada pelo Controlador VGA) ---
    input wire clk_b,             // NOVO: Clock do Pixel (clk_pixel)
    input wire [ADDR_WIDTH-1:0] addr_b,
    output reg [DATA_WIDTH-1:0] data_out_b
);

    localparam RAM_DEPTH = CHARS_X * CHARS_Y; // 80 * 60 = 4800

    // A memória em si
    reg [DATA_WIDTH-1:0] ram[RAM_DEPTH-1:0];


    
    // --- Lógica das Portas de Escrita e Leitura ---
    
    // Porta A (Escrita) é sensível APENAS ao clock da CPU
    always @(posedge clk_a) begin
        if (wr_en_a) begin
            ram[addr_a] <= data_in_a;
        end
    end

    // Porta B (Leitura) é sensível APENAS ao clock do pixel
    always @(posedge clk_b) begin
        data_out_b <= ram[addr_b];
    end

endmodule