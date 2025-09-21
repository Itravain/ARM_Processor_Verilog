module modulo_interrupcao (
    input wire write_clock,
    input wire InterruptWrite,
    input wire FinishInterrupt, ClockInterrupt, PrintInterruption,
    
    // Corrigido para [1:0] para corresponder à lógica do 'case'
    // ou use [2:0] com 3'bxxx para 8 posições
    input wire [1:0] write_addr, 
    input wire [31:0] w_data,
    
    input wire [31:0] inNextPcAddr,
    
    output reg [31:0] outInterrupt
);

    reg [31:0] FinishReg;
    reg [31:0] ClockReg;
    reg [31:0] PrintReg;
    

    // Bloco de escrita (síncrono)
    // Armazena os endereços de interrupção
    always @(posedge write_clock) begin
        if (InterruptWrite) begin
            case (write_addr)
                2'b00: FinishReg <= w_data;
                2'b01: ClockReg  <= w_data;
                2'b10: PrintReg  <= w_data;
                default: begin
                    // Opcional: Trata endereços não mapeados
                end
            endcase
        end
    end

    // Bloco de seleção (combinacional)
    // Seleciona o endereço da rotina de interrupção com base na prioridade
    always @(*) begin
        if(FinishInterrupt) begin
            outInterrupt = FinishReg;
        end else if (ClockInterrupt) begin
            outInterrupt = ClockReg;
        end else if (PrintInterruption) begin
            outInterrupt = PrintReg;
        end else begin
            outInterrupt = inNextPcAddr;
        end
    end

endmodule