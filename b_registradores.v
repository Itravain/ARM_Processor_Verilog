module b_registradores(
    input wire [4:0] rn, rm, rd,
    input wire reg_write, clock, inv_clock, sinal_link,
    input wire [3:0] in_cpsr,
    input wire [31:0] in_dados, in_link,
    output reg [31:0] dado_um, dado_dois,
    output reg [3:0] out_cpsr
);

    reg [31:0] registradores [31:0];

    // Bloco de inicialização
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registradores[i] = 32'b0; // Inicializa todos os registradores com 0
        end
    end


	always @ (posedge clock) begin
		if (reg_write) begin
			registradores[rd] <= in_dados; // Atualiza o registrador apenas se reg_write for 1
		end
        // Atualiza cpsr e link
		if(sinal_link) begin
			registradores[31] <= in_link;		  
		end
			registradores[30] <= {28'b0, in_cpsr}; // Ajusta o tamanho para 32 bits

    end
	 

    always @ (posedge inv_clock) begin
		out_cpsr = registradores[30][3:0]; // Extrai os 4 bits de cpsr
		dado_um = registradores[rn];
		dado_dois = registradores[rm];
    end

endmodule
