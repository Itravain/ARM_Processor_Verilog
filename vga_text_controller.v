/**
 * vga_text_controller.v
 * MODIFICADO: Orquestra a geração de vídeo e agora recebe o clock do processador
 * para passá-lo à porta de escrita da memória de vídeo (text_ram).
 */
module vga_text_controller (
    input wire clk_pixel,       // Clock principal do sistema VGA (~25MHz)
    input wire proc_clk,        // NOVO: Clock do processador para escrita síncrona na RAM
    input wire rst,

    // Interface com a CPU para escrever na Text RAM
    input wire cpu_write_enable,
    input wire [12:0] cpu_addr, 
    input wire [7:0] cpu_char_in,

    // Saídas para o conector VGA
    output wire hsync,
    output wire vsync,
    output wire vga_r, 
    output wire vga_g, 
    output wire vga_b
);

    // Sinais internos para a unidade de sincronismo
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    // Instanciação da unidade de sincronismo (sem alterações)
    vga_sync sync_unit (
        .clk_pixel(clk_pixel),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // --- Lógica de Renderização de Texto (sem alterações na lógica) ---
    localparam FONT_WIDTH_BITS = 3;
    localparam FONT_HEIGHT_BITS = 3; 
    localparam SCREEN_CHARS_X = 80;
    localparam SCREEN_CHARS_Y = 60; 

    wire [6:0] char_x = pixel_x[9:FONT_WIDTH_BITS]; 
    wire [5:0] char_y = pixel_y[9:FONT_HEIGHT_BITS]; 
    wire [2:0] char_pixel_row = pixel_y[FONT_HEIGHT_BITS-1:0];
    wire [2:0] char_pixel_col = pixel_x[FONT_WIDTH_BITS-1:0];

    // Endereço para a Text RAM (leitura)
    wire [12:0] text_ram_rd_addr = (char_y * SCREEN_CHARS_X) + char_x;
    wire [7:0] ascii_code;

    // --- Instanciação da text_ram MODIFICADA ---
    text_ram #(
        .CHARS_X(80),
        .CHARS_Y(60)
    ) character_memory (
        // Porta A (Escrita - CPU) agora usa o proc_clk
        .clk_a(proc_clk), 
        .wr_en_a(cpu_write_enable),
        .addr_a(cpu_addr),
        .data_in_a(cpu_char_in),
        
        // Porta B (Leitura - VGA) continua usando o clk_pixel
        .clk_b(clk_pixel), 
        .addr_b(text_ram_rd_addr),
        .data_out_b(ascii_code)
    );

    // Lógica da ROM de fontes e saída RGB (sem alterações)
    wire [9:0] char_rom_addr = {ascii_code[6:0], char_pixel_row};
    wire [7:0] font_pixel_data;

    char_rom #(.FONT_HEIGHT(8)) font_rom (
        .addr(char_rom_addr),
        .data_out(font_pixel_data)
    );

    wire pixel_on;
    assign pixel_on = font_pixel_data[7 - char_pixel_col];

    assign vga_r = video_on & pixel_on;
    assign vga_g = video_on & pixel_on;
    assign vga_b = video_on & pixel_on;

endmodule