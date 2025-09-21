module display_multiplexado #(
    parameter CLK_FREQ = 50_000_000 // Frequência do clock principal (ex: 50 MHz)
)(
    input wire fast_clk,            // Clock de alta frequência para multiplexação (ex: 50MHz)
    input wire proc_clk,           // Clock do processador (lento)
    input wire [1:0] sel_clock,     // Sinal da unidade de controle para a instrução OUT
    input wire [31:0] valor_in,     // Valor vindo do registrador do processador
    output reg [6:0] seg_out,       // Saída para os 7 segmentos (a-g)
    output reg [3:0] anode_sel      // Saída para selecionar o display ativo (anodo comum)
);

    reg [31:0] valor_registrado = 0;
	 reg [31:0] valor_limitado = 0;

    // Bloco 1: Captura do dado
    always @(negedge proc_clk) begin
		 if(sel_clock == 2'b01) begin
				valor_registrado <= valor_in;
		 end       
    end

    // 2. Preparação dos dígitos a partir do valor registrado
    reg [15:0] valor_bcd;

    always @(*) begin
        
        if (valor_registrado > 9999) begin
            valor_limitado = 9999;
        end else begin
            valor_limitado = valor_registrado;
        end
        
        valor_bcd[15:12] = valor_limitado / 1000;
        valor_bcd[11:8]  = (valor_limitado / 100) % 10;
        valor_bcd[7:4]   = (valor_limitado / 10) % 10;
        valor_bcd[3:0]   = valor_limitado % 10;
    end

    // 3. Lógica de Multiplexação (Varredura)
    localparam REFRESH_RATE_HZ = 800;
    localparam COUNTER_MAX = CLK_FREQ / REFRESH_RATE_HZ;
    reg [$clog2(COUNTER_MAX)-1:0] refresh_counter = 0;
    reg [1:0] display_selector = 0;

    always @(posedge fast_clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter >= COUNTER_MAX) begin
            refresh_counter <= 0;
            display_selector <= display_selector + 1;
        end
    end

    // 4. Seleção do dígito e acionamento do anodo
    reg [3:0] digito_atual;
    
    always @(*) begin
        case (display_selector)
            2'b00: begin anode_sel = 4'b1110; digito_atual = valor_bcd[15:12]; end // Display 1
            2'b01: begin anode_sel = 4'b1101; digito_atual = valor_bcd[11:8];  end // Display 2
            2'b10: begin anode_sel = 4'b1011; digito_atual = valor_bcd[7:4];   end // Display 3
            2'b11: begin anode_sel = 4'b0111; digito_atual = valor_bcd[3:0];   end // Display 4
            default: begin anode_sel = 4'b1111; digito_atual = 4'b0; end
        endcase
    end

    // 5. Conversor BCD para 7 Segmentos
    always @(*) begin
        case(digito_atual)
            4'b0000: seg_out = 7'b1000000; // 0
            4'b0001: seg_out = 7'b1111001; // 1
            4'b0010: seg_out = 7'b0100100; // 2
            4'b0011: seg_out = 7'b0110000; // 3
            4'b0100: seg_out = 7'b0011001; // 4
            4'b0101: seg_out = 7'b0010010; // 5
            4'b0110: seg_out = 7'b0000010; // 6
            4'b0111: seg_out = 7'b1111000; // 7
            4'b1000: seg_out = 7'b0000000; // 8
            4'b1001: seg_out = 7'b0011000; // 9
            default: seg_out = 7'b1111111; // Apagado
        endcase
    end

endmodule