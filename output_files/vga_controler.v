/**
 * vga_text_controller.v
 * Módulo principal que orquestra a geração de um sinal de vídeo em modo texto
 * com uma fonte 8x8, resultando em uma tela de 80x60 caracteres.
 */
module vga_controller (
    input wire clk_pixel, // Clock principal do sistema VGA (~25MHz)
    input wire rst,

    // Interface com a CPU para escrever na Text RAM
    input wire cpu_write_enable,
    input wire [12:0] cpu_addr, // MODIFICADO: Para endereçar 4800 posições
    input wire [7:0] cpu_char_in,

    // Saídas para o conector VGA
    output wire hsync,
    output wire vsync,
    output wire vga_r, 
    output wire vga_g, 
    output wire vga_b
);

    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    vga_sync sync_unit (
        .clk_pixel(clk_pixel),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // --- Lógica de Renderização de Texto com Fonte 8x8 ---

    localparam FONT_WIDTH_BITS = 3;  // log2(8)
    localparam FONT_HEIGHT_BITS = 3; // MODIFICADO: log2(8)
    localparam SCREEN_CHARS_X = 80;
    localparam SCREEN_CHARS_Y = 60; // MODIFICADO: 480 / 8 = 60

    // Otimização para hardware (sem divisão/módulo)
    wire [6:0] char_x = pixel_x[9:FONT_WIDTH_BITS];     // pixel_x / 8
    wire [5:0] char_y = pixel_y[9:FONT_HEIGHT_BITS];    // MODIFICADO: pixel_y / 8
    wire [2:0] char_pixel_row = pixel_y[FONT_HEIGHT_BITS-1:0]; // MODIFICADO: pixel_y % 8
    wire [2:0] char_pixel_col = pixel_x[FONT_WIDTH_BITS-1:0];  // pixel_x % 8

    // Endereço para a Text RAM
    wire [12:0] text_ram_rd_addr = (char_y * SCREEN_CHARS_X) + char_x; // MODIFICADO: Largura do fio
    wire [7:0] ascii_code;

    text_ram #(
        .CHARS_X(80),
        .CHARS_Y(60) // MODIFICADO
    ) character_memory (
        .clk(clk_pixel),
        .wr_en_a(cpu_write_enable),
        .addr_a(cpu_addr),
        .data_in_a(cpu_char_in),
        .addr_b(text_ram_rd_addr),
        .data_out_b(ascii_code)
    );
    
    // Endereço para a Char ROM
    wire [9:0] char_rom_addr = {ascii_code[6:0], char_pixel_row}; // MODIFICADO: Largura do fio
    wire [7:0] font_pixel_data;

    char_rom #(
        .FONT_HEIGHT(8) // MODIFICADO
    ) font_rom (
        .addr(char_rom_addr),
        .data_out(font_pixel_data)
    );

    // Lógica para determinar o estado do pixel
    wire pixel_on;
    assign pixel_on = font_pixel_data[7 - char_pixel_col];

    // Saída final para os pinos RGB
    assign vga_r = video_on & pixel_on;
    assign vga_g = video_on & pixel_on;
    assign vga_b = video_on & pixel_on;

endmodule