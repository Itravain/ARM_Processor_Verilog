/**
 * vga_sync.v
 * Gera os sinais de temporização e as coordenadas de pixel para um modo VGA 640x480 @ 60Hz.
 * Requer um clock de pixel de 25.175 MHz.
 */
module vga_sync (
    input wire clk_pixel,       // Clock de ~25MHz
    input wire rst,             // Reset
    
    output reg hsync,           // Pulso de sincronização horizontal (ativo baixo)
    output reg vsync,           // Pulso de sincronização vertical (ativo baixo)
    output reg video_on,        // '1' quando estiver na área de desenho visível
    
    output wire [9:0] pixel_x,  // Coordenada X atual (coluna do pixel)
    output wire [9:0] pixel_y   // Coordenada Y atual (linha do pixel)
);

    // Parâmetros de temporização para 640x480 @ 60Hz
    localparam H_DISPLAY      = 640;
    localparam H_FRONT_PORCH  = 16;
    localparam H_SYNC_PULSE   = 96;
    localparam H_BACK_PORCH   = 48;
    localparam H_TOTAL        = 800;

    localparam V_DISPLAY      = 480;
    localparam V_FRONT_PORCH  = 10;
    localparam V_SYNC_PULSE   = 2;
    localparam V_BACK_PORCH   = 33;
    localparam V_TOTAL        = 525;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    assign pixel_x = h_count;
    assign pixel_y = v_count;

    always @(posedge clk_pixel or posedge rst) begin
        if (rst) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    always @(*) begin
        hsync = !((h_count >= H_DISPLAY + H_FRONT_PORCH) && (h_count < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE));
        vsync = !((v_count >= V_DISPLAY + V_FRONT_PORCH) && (v_count < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE));
        video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    end

endmodule