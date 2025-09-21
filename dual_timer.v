// dual_timer.v com registradores de controle separados
module dual_timer #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    // Interface do barramento de memória
    input wire                      clk,
    input wire                      rst,
    input wire [ADDR_WIDTH-1:0]     addr,
    input wire [DATA_WIDTH-1:0]     data_in,
    input wire                      write_enable,
    output reg [DATA_WIDTH-1:0]     data_out,

    // Saídas de interrupção
    output reg                      irq1,
    output reg                      irq2
);

    // --- Registradores (Controle separado) ---
    reg        timer1_enable;            // Endereço 0
    reg        timer1_irq_enable;        // Endereço 1
    reg [31:0] timer1_prescaler;         // Endereço 2
    reg [31:0] timer1_counter;           // Endereço 3 (leitura)
    reg [31:0] timer1_interrupt_period;  // Endereço 4
    reg [31:0] timer1_prescaler_count;

    reg        timer2_enable;            // Endereço 5
    reg        timer2_irq_enable;        // Endereço 6
    reg [31:0] timer2_prescaler;         // Endereço 7
    reg [31:0] timer2_counter;           // Endereço 8 (leitura)
    reg [31:0] timer2_interrupt_period;  // Endereço 9
    reg [31:0] timer2_prescaler_count;

    // --- Bloco de Inicialização ---
    initial begin
        timer1_enable = 1'b0;
        timer1_irq_enable = 1'b0;
        timer1_prescaler = 32'd0;
        timer1_counter = 32'd0;
        timer1_interrupt_period = 32'd0;
        timer1_prescaler_count = 32'd0;

        // Timer 2 configurado como contador de milissegundos
        timer2_enable = 1'b1; // Habilita o timer
        timer2_irq_enable = 1'b0;
        timer2_prescaler = 32'd24999;
        timer2_interrupt_period = 32'd0; // Não gera IRQ por padrão
        timer2_counter = 32'd0;
        timer2_prescaler_count = 32'd0;
        
        irq1 = 1'b0;
        irq2 = 1'b0;
    end

    // --- Lógica de Leitura/Escrita ---
    always @(*) begin
        case (addr)
            4'h0: data_out = {31'b0, timer1_enable};
            4'h1: data_out = {31'b0, timer1_irq_enable};
            4'h2: data_out = timer1_prescaler;
            4'h3: data_out = timer1_counter;
            4'h4: data_out = timer1_interrupt_period;
            4'h5: data_out = {31'b0, timer2_enable};
            4'h6: data_out = {31'b0, timer2_irq_enable};
            4'h7: data_out = timer2_prescaler;
            4'h8: data_out = timer2_counter;
            4'h9: data_out = timer2_interrupt_period;
            default: data_out = 32'h0;
        endcase
    end
    
    always @(posedge clk) begin
        if (write_enable) begin
            case (addr)
                4'h0: timer1_enable <= data_in[0];
                4'h1: timer1_irq_enable <= data_in[0];
                4'h2: timer1_prescaler <= data_in;
                4'h4: timer1_interrupt_period <= data_in;
                4'h5: timer2_enable <= data_in[0];
                4'h6: timer2_irq_enable <= data_in[0];
                4'h7: timer2_prescaler <= data_in;
                4'h9: timer2_interrupt_period <= data_in;
                default:;
            endcase
        end
    end

    // --- Lógica do Contador 1 ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // ... (lógica de reset)
        end else begin
            irq1 <= 1'b0;
            if (timer1_enable) begin
                if (timer1_prescaler_count >= timer1_prescaler) begin
                    timer1_prescaler_count <= 0;
                    if (timer1_counter >= timer1_interrupt_period && timer1_interrupt_period != 0) begin
                        timer1_counter <= 0;
                        if (timer1_irq_enable) begin
                           irq1 <= 1'b1;
                        end
                    end else begin
                        timer1_counter <= timer1_counter + 1;
                    end
                end else begin
                    timer1_prescaler_count <= timer1_prescaler_count + 1;
                end
            end
        end
    end
    
    // --- Lógica do Contador 2 ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
           // ... (lógica de reset)
        end else begin
            irq2 <= 1'b0;
            if (timer2_enable) begin
                if (timer2_prescaler_count >= timer2_prescaler) begin
                    timer2_prescaler_count <= 0;
                    if (timer2_counter >= timer2_interrupt_period && timer2_interrupt_period != 0) begin
                        timer2_counter <= 0;
                        if (timer2_irq_enable) begin
                           irq2 <= 1'b1;
                        end
                    end else begin
                        timer2_counter <= timer2_counter + 1;
                    end
                end else begin
                    timer2_prescaler_count <= timer2_prescaler_count + 1;
                end
            end
        end
    end

endmodule