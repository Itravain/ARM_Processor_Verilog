module geral(	
	//FPGA
	input wire input_clock,

	//Módulo de saída
	output wire [6:0] seg_out,
	output wire [3:0] anode_sel,
	 
	//modulo_entrada
	input wire [3:0] switch_imediato,
	 
	//div_clock
	input wire switch_continue,
	
//	//Tester
//	output wire [31:0] saida_um,
//	output wire [15:0] saida_dois,

	//	pc
	
	output wire vga_hsync,
	output wire vga_vsync,
	output wire vga_r,
	output wire vga_g,
	output wire vga_b,
	
	output wire clock
);




//tester u_tester(					
//	.entrada_um(outInterrupt),
//	.entrada_dois(ClockInterrupt),
//	
//	.saida_um(saida_um),
//	.saida_dois(saida_dois),
//
//);


//conexões
//Modulo_entrada
wire [7:0] o_entrada;
wire [4:0] o_registrador;

//b_registradores
wire [31:0] dado_um, dado_dois, out_link;
wire [3:0] in_cpsr, out_cpsr;

//ula
wire [31:0] resultado;
wire [3:0] cond;

//mux_imm_ula
wire [31:0] out_imm_ula;

//mux_cpsr
wire [3:0] out_mux_cpsr;

//unidade_instrucao
wire [4:0] rn, rm, rd;
wire [31:0] imm;
wire [10:0] controle;

//memoria_instrucoes
wire [31:0] q;
wire [31:0] out_mem_inst;

//mux_link
wire [31:0] out_mux_link;

//pc
wire [31:0] o_pc;

//somador_pc
wire [31:0] out_somador_pc;

//mux_jump
wire [31:0] out_mux_jump;

//mux_jump_imm
wire [31:0] out_mux_jump_imm;

//memoria_dados
wire[31:0] out_ram;

//mux_memoria_ula
wire [31:0] out_mux_memoria_ula;

//mux_entrada_dado_um
wire [31:0] out_mux_entrada_imediato;

//mux_entrada_registrador
wire [31:0] out_mux_entrada_registrador;

//unidade de controle
wire [3:0] sel;
wire i, regWrite, link;
wire [1:0] sel_clock;

////inv_clock
//wire inv_clock;


wire s;
wire jump;
wire memWrite;
wire memToReg;
wire RBaseLimWrite;
wire FinishInterrupt;
wire InterruptWrite;

//memory_selector
wire memWrite_video;
wire memWrite_data;
wire memWrite_hd;
wire memWrite_instruct;
wire memWrite_Timer;

wire [31:0] out_data;
wire [31:0] io_addr;
wire [1:0] outMemReg;


// Fios para conectar ao PLL
 wire pixel_clock;
 wire pll_locked;

 //hd
 wire [31:0] out_hd;

 //base_lim_reg
 wire [14:0] out_base_lim_inst;
 wire [14:0] out_base_lim_data;
 wire seg_fault;
 
 
 //modulo)interrupcao
 wire [31:0] outInterrupt;
 
 // Sinais para o timer
 wire [31:0] timer_data_out;
 wire ClockInterrupt, MillisInterrupt;
 
 
mux_link_ (
	.control(ClockInterrupt),
	.in_zero(link), 
	.in_one(ClockInterrupt),
	.m_out(out_mux_link),
);
 
 
dual_timer timer_inst (
  .clk(clock),
  .rst(1'b0),
  .addr(io_addr[2:0]),
  .data_in(out_data),
  .write_enable(memWrite_Timer),
  .data_out(timer_data_out),
  .irq1(ClockInterrupt),
  .irq2(MillisInterrupt)
);



display_multiplexado d_mlu( 
	.fast_clk(input_clock),  // Clock de alta frequência para multiplexação (ex: 50MHz)
	.proc_clk(clock),        // Clock do processador (lento)
	.sel_clock(sel_clock),   // 2'b01 - debug -> sel_clock - run
	.valor_in(dado_um),      //   dado_um - run 
	.seg_out(seg_out),       // Saída para os 7 segmentos (a-g)
	.anode_sel(anode_sel) 
);
 
base_lim_reg blr (
		.write_clock(clock),
		.we(RBaseLimWrite),
		.write_addr(dado_um),
		.w_data(dado_dois),
		.jump(jump),
		.in_inst_logical(imm),
		.in_data_logical(io_addr),
		.physical_addr_out(out_base_lim_inst),
		.out_base_lim_data(out_base_lim_data),
		.seg_fault(seg_fault)
);

 
modulo_interrupcao mi (
	.InterruptWrite(InterruptWrite),
	.ClockInterrupt(ClockInterrupt), 
	.PrintInterruption(),
	.FinishInterrupt(FinishInterrupt),
	.write_clock(clock),
	.write_addr(imm),
	.w_data(dado_um),
	.inNextPcAddr(out_mux_jump),
	.outInterrupt(outInterrupt)
);



 // Instanciação do módulo PLL gerado pelo Quartus
 // A sintaxe .nome_da_porta(sinal_conectado) é a mais segura e recomendada.
 vga_pll pll_inst (
	  .areset   (1'b0),            // Reset assíncrono. Conectado a '0' para nunca resetar.
	  .inclk0   (input_clock),     // Conecta o clock principal de 50MHz do FPGA.
	  .c0       (pixel_clock),     // Esta é a saída do clock de 25.175 MHz para o VGA.
	  .locked   (pll_locked)       // Saída que vai para '1' quando o clock está estável.
 );

vga_text_controller v_text_ct(
    .clk_pixel(pixel_clock),    // Clock de ~25MHz para o VGA
    .proc_clk(clock),           // NOVO: Conecta o clock do processador
    .rst(~pll_locked),

    // Interface com a CPU para escrever na Text RAM
    .cpu_write_enable(memWrite_video),
    .cpu_addr(io_addr[12:0]),
    .cpu_char_in(out_data[7:0]),

    // Saídas para o conector VGA
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .vga_r(vga_r), 
    .vga_g(vga_g), 
    .vga_b(vga_b)
);


memory_selector m_sel(
    .addr(resultado),
    .data(dado_dois),
    .memWrite(memWrite),
	 .memToReg(memToReg),
    
    .memWrite_video(memWrite_video),
    .memWrite_ram(memWrite_data),
	 .memWrite_instruct(memWrite_instruct),
	 .memWrite_hd(memWrite_hd),
	 .memWrite_Timer(memWrite_Timer),

    .io_addr(io_addr),
    .out_data(out_data),
	 
	 .outMemReg(outMemReg)
);

hd h(
	.data(out_data),
	.read_addr(io_addr[11:0]),
	.write_addr(io_addr[11:0]),
	.we(memWrite_hd),
	.read_clock(input_clock),
	.write_clock(clock),
	.q(out_hd)
);


mux_entrada_registrador u_en_reg(	
	.rd(rd),
	.entrada_registrador(o_registrador),
	.sel_clock(sel_clock),
	.out_mux_entrada_registrador(out_mux_entrada_registrador)
);

mux_entrada_imediato u_mux_en_im(	
	.dado_um(imm), 
	.entrada(o_entrada),
	.sel_clock(sel_clock),
	.out_mux_entrada_imediato(out_mux_entrada_imediato)
);

modulo_entrada u_mod_en(		
    .switch_imediato(switch_imediato),
    .o_entrada(o_entrada),
    .o_registrador(o_registrador)
);


div_clock u_div_cl(				
	.CLOCK_50(input_clock), 
	.sel_clock(sel_clock), 
	.clk(clock),
	.continue_switch(switch_continue)
);

b_registradores u_breg(	.rn(rn), 
	.rm(rm),
	.rd(out_mux_entrada_registrador),
	.sinal_link(out_mux_link),
	.in_dados(out_mux_memoria_ula), 
	.reg_write(regWrite),
	.clock(clock),
	.inv_clock(input_clock),
	.in_cpsr(out_mux_cpsr),
	.in_link(o_pc),
	.dado_um(dado_um), 
	.dado_dois(dado_dois), 
	.out_cpsr(out_cpsr)	
);

ula u(					
	.sel(sel), 
	.a(dado_um), 
	.b(out_imm_ula), 
	.s(s), 
	.resultado(resultado), 
	.cond(cond)
);

mux_imm_ula u_m_imm_u(			
	.in_i(i),
	.in_dado_dois(dado_dois),
	.in_imm(out_mux_entrada_imediato),
	.out_imm_ula(out_imm_ula)
);

mux_cpsr u_m_cpsr(				
	.in_s(s),
	.in_atual(out_cpsr),
	.in_novo(cond),
	.out_mux_cpsr(out_mux_cpsr)
);

unidade_instrucao u_un_inst(	
	.instrucao(q),
	.in_cpsr(out_cpsr),							
	.rn(rn),
	.rm(rm),
	.rd(rd),
	.imm(imm),
	.controle(controle)
);


memoria_instrucoes u_mem_inst(
	.data_a(1'b0),
	.data_b(out_data),
	.addr_a(o_pc),
	.addr_b(io_addr),
	.we_a(1'b0), 
	.we_b(memWrite_instruct), 
	.clk_a(input_clock), 
	.clk_b(clock),
	.q_a(q), 
	.q_b()
);


pc u_pc(						
	.clock(clock), 
	.novo_estado(outInterrupt), 
	.o_pc(o_pc)
);

somador_pc u_som_pc(				
	.in_pc(o_pc),
	.out_somador_pc(out_somador_pc)
);

mux_jump u_m_j(				
	.in_jump(jump), 
	.in_soma(out_somador_pc), 
	.in_imm(out_mux_jump_imm), 
	.out_mux_jump(out_mux_jump) 
);

mux_jump_imm u_m_j_imm(			
	.in_i(i), 
	.in_dado_um(dado_um), 
	.in_imm(out_base_lim_inst), 
	.out_mux_jump_imm(out_mux_jump_imm)

);

memoria_dados u_mem_d(  		
	.data(out_data),
	.read_addr(out_base_lim_data),
	.write_addr(out_base_lim_data),
	.we(memWrite_data), 
	.read_clock(input_clock), 
	.write_clock(clock),
	.q(out_ram)
);


mux_memoria_ula u_m_m_u(		 
	.in_ula(resultado),
	.in_ram(out_ram),
	.in_timer(timer_data_out),
	.in_hd(out_hd),
	.sel(outMemReg),
	.out_mux_memoria_ula(out_mux_memoria_ula)

);

unidade_controle u_u_cont(		
	.controle(controle),
	.jump(jump), 
	.memWrite(memWrite), 
	.memToReg(memToReg),
	.RBaseLimWrite(RBaseLimWrite),
	.FinishInterrupt(FinishInterrupt),
	.s(s), 
	.i(i), 
	.regWrite(regWrite), 
	.link(link),
	.sel(sel),
	.sel_clock(sel_clock),
	.InterruptWrite(InterruptWrite)
);
endmodule 