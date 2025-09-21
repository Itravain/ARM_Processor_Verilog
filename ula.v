module ula (sel, a, b, s, resultado, cond);

input [3:0] sel;
input [31:0] a, b;
input s;
output reg signed [31:0] resultado;
output reg [3:0] cond; // Ordem das flags: {N, Z, C, V}

// Variáveis para as flags
reg n_flag, z_flag, c_flag, v_flag;

always @ (*) begin
    // Valores padrão
    resultado = 32'b0;
    cond = 4'b0000;
    n_flag = 1'b0;
    z_flag = 1'b0;
    c_flag = 1'b0;
    v_flag = 1'b0;

    case(sel)
        4'b0000: resultado = a & b;   // AND
        4'b0001: resultado = a ^ b;   // XOR
        4'b0010: resultado = a | b;   // OR
        
        4'b0011: begin // SUB (a - b)
            resultado = a - b;
            if (s) begin
                // N (Negative): Bit mais significativo do resultado.
                n_flag = resultado[31];
                // Z (Zero): Resultado é zero.
                z_flag = (resultado == 32'b0);
                // C (Carry/Borrow): Ocorre um "não-empréstimo". C=1 se a >= b (unsigned).
                c_flag = (a >= b);
                // V (Overflow): O sinal do resultado é incorreto.
                // Ocorre se os sinais dos operandos forem diferentes e o sinal do resultado for igual ao de 'b'.
                v_flag = (a[31] != b[31]) && (resultado[31] == b[31]);
                
                cond = {n_flag, z_flag, c_flag, v_flag};
            end
        end
        
        4'b0100: begin // ADD (a + b)
            resultado = a + b;
            if (s) begin
                // N (Negative): Bit mais significativo do resultado.
                n_flag = resultado[31];
                // Z (Zero): Resultado é zero.
                z_flag = (resultado == 32'b0);
                // C (Carry): Ocorre um "vai-um" do bit 31.
                c_flag = (resultado < a); // ou (resultado < b)
                // V (Overflow): O sinal do resultado é incorreto.
                // Ocorre se os sinais dos operandos forem iguais e o sinal do resultado for diferente.
                v_flag = (a[31] == b[31]) && (resultado[31] != a[31]);

                cond = {n_flag, z_flag, c_flag, v_flag};
            end
        end
        
        4'b0101: resultado = a * b; // MULT
        4'b0110: resultado = a / b; // DIV
        default: resultado = 32'b0;
    endcase
end

endmodule