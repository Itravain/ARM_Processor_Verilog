// Arquivo: geral_tb.v
`timescale 1ns / 1ps // Define a unidade de tempo da simulação

module geral_tb;

    // 1. Declare regs para as ENTRADAS do seu design
    reg input_clock;
    reg [3:0] switch_imediato;
    reg switch_continue;

    // 2. Declare wires para as SAÍDAS do seu design
    wire [6:0] seg_out;
    // Adicione aqui outros wires para as saídas que quiser observar...
    wire vga_hsync;
    wire vga_vsync;


    // 3. Instancie o seu design principal (DUT - Device Under Test)
    //    Certifique-se de que os nomes das portas correspondem exatamente
    //    aos do seu módulo 'geral.v'
    geral dut (
        .input_clock(input_clock),
        .switch_imediato(switch_imediato),
        .switch_continue(switch_continue),
        .seg_out(seg_out),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync)
        // Adicione aqui o restante das portas do seu módulo geral...
    );

    // 4. Geração do clock principal (50MHz = período de 20ns)
    initial begin
        input_clock = 0;
        forever #10 input_clock = ~input_clock; // Inverte o clock a cada 10ns
    end

    // 5. Bloco de estímulos: aqui você descreve o que o teste fará
    initial begin
        // Inicia os valores das entradas
        switch_imediato = 4'b0000;
        switch_continue = 1'b0;

        // Espera 100ns para o sistema estabilizar
        #100;

        // --- AQUI COMEÇA SEU TESTE ---
        // Exemplo: Simular uma instrução de entrada
        // A unidade de controle define sel_clock para 2'b10 no modo IN
        // Vamos simular o pressionamento do botão 'continue'
        
        // Simula o usuário colocando '5' nas chaves
        switch_imediato = 4'b0101; 
        
        #50; // Espera um pouco

        // Simula um pulso no botão 'continue' para executar um ciclo
        switch_continue = 1'b1;
        #20; // Mantém pressionado por 20ns (1 ciclo de 50MHz)
        switch_continue = 1'b0;

        #1000; // Deixa a simulação rodar por mais 1000ns

        // Termina a simulação
        $stop;
    end

endmodule