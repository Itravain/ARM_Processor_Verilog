module memory_selector(
    input wire [31:0] addr,
    input wire [31:0] data,
    input wire        memWrite,
    input wire        memToReg,

    output reg        memWrite_video,
    output reg        memWrite_ram,
    output reg        memWrite_instruct,
    output reg        memWrite_hd,
    output reg        memWrite_Timer,

    output reg [31:0] io_addr,
    output reg [31:0] out_data,

    output reg [1:0]  outMemReg
);

    wire [7:0] select_bits = addr[15:8];

    always @(*) begin
        memWrite_video    = 1'b0;
        memWrite_ram      = 1'b0;
        memWrite_instruct = 1'b0;
        memWrite_hd       = 1'b0;
        memWrite_Timer    = 1'b0;
        outMemReg         = 2'b00;
        out_data          = data;
        io_addr           = 32'h0;

        case (select_bits)
            //Memória RAM: 0x0000 a 0x07FF (2KB)
            8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07: begin
                memWrite_ram = memWrite;
                io_addr      = {21'b0, addr[10:0]};
                if (memToReg) begin
                    outMemReg = 2'b01;
                end
            end
            //Memória Instruções: 0x0800 a 0x0FFF (4KB)
            8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F,
            8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17: begin
                memWrite_instruct = memWrite;
                io_addr           =  addr - 2048;
            end
            //Memória Vídeo: 0x1800 a 0x2A9F (4,75KB)
            8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F, 
            8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 
            8'h28, 8'h29, 8'h2A: begin
                memWrite_video = memWrite;
                io_addr        = addr - 6144;
            end
            //HD: 0x2B00 a 0x6A6B (16KB)
            8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F, 8'h30, 8'h31, 8'h32, 
            8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39, 8'h3A, 
            8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F, 8'h40, 8'h41, 8'h42, 
            8'h43, 8'h44, 8'h45, 8'h46, 8'h47, 8'h48, 8'h49, 8'h4A, 
            8'h4B, 8'h4C, 8'h4D, 8'h4E, 8'h4F, 8'h50, 8'h51, 8'h52, 
            8'h53, 8'h54, 8'h55, 8'h56, 8'h57, 8'h58, 8'h59, 8'h5A, 
            8'h5B, 8'h5C, 8'h5D, 8'h5E, 8'h5F, 8'h60, 8'h61, 8'h62, 
            8'h63, 8'h64, 8'h65, 8'h66, 8'h67, 8'h68, 8'h69, 8'h6A: begin
                memWrite_hd = memWrite;
                io_addr     = addr - 11008;
                if (memToReg) begin
                    outMemReg = 2'b11;
                end
            end
            //Timer: 0x6A6C a 0x6B6B (256B)
            8'h6B: begin
                memWrite_Timer = memWrite;
                io_addr        = addr - 27392;
                if (memToReg) begin
                    outMemReg = 2'b10;
                end
            end
            
            default: begin

            end
        endcase
    end

endmodule