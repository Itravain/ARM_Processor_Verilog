module div_clock
#(
    // Mantemos os parâmetros para os outros modos
    parameter FREQ_CLOCK = 25 , // 25 - run -> 1000000 debugFPGA - 2
    parameter PERIODO_OUT = 2000000, // 2000000 - run -> 20 debugFPGA - 4
    parameter PERIODO_NORMAL = 1
)
(
    input wire CLOCK_50,
    input wire continue_switch,
    input wire [1:0] sel_clock,
    output reg clk
);

    reg [28:0] count;
    reg [28:0] divisor;

    reg step_pulse;
    reg previous_debounced_signal; // Registador para detetar a borda

    // Ele vai estabilizar o sinal do 'continue_switch'
    debouncer step_debouncer (
        .clk(CLOCK_50),
        .btn_in(continue_switch),
        .o_btn(debounced_continue) // Saída estável do debouncer
    );

    // Gera um pulso de um ciclo ('step_pulse') quando o botão é pressionado (transição de 0 para 1)
    always @(posedge CLOCK_50) begin
        previous_debounced_signal <= debounced_continue;
        if (debounced_continue == 1'b1 && previous_debounced_signal == 1'b0) begin
            step_pulse <= 1'b1;
        end else begin
            step_pulse <= 1'b0;
        end
    end

    initial begin
        count = 0;
        clk = 0;
        previous_debounced_signal = 1'b1; // Estado inicial
    end

    // --- LÓGICA DO CLOCK MODIFICADA ---
    always @ (posedge CLOCK_50) begin
        // A lógica do divisor continua igual para os modos contínuos
        case (sel_clock)
            2'b00: divisor <= (FREQ_CLOCK * PERIODO_NORMAL); // NORMAL
            2'b01: divisor <= (FREQ_CLOCK * PERIODO_OUT);   // OUT
            default: divisor <= 0;
        endcase

        // Lógica de atualização do clock agora depende do modo
        case (sel_clock)
        2'b10: begin // MODO 'IN' (Passo-a-passo)
            if (step_pulse) begin
                clk <= ~clk;
            end
        end

//        2'b11: begin // MODO 'FINISH' (Parado)
//            count <= 0;
//            // Opcional: garantir que o clock pare num estado conhecido
//            // clk <= 1'b0;
//        end

        // Os modos 2'b00 (NORMAL) e 2'b01 (OUT) têm a mesma lógica
        default: begin // MODOS 'NORMAL' e 'OUT' (Clock contínuo)
            if (count >= divisor) begin
                clk <= ~clk;
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end
    endcase
    end

endmodule