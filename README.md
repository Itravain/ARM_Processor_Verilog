# Processador ARM em Verilog (FPGA SoC)

Este repositório contém o código-fonte em Verilog para um processador didático de 32 bits, inspirado na arquitetura ARM, implementado como um System-on-a-Chip (SoC) completo para FPGAs.

O projeto não se limita a uma CPU; ele integra um conjunto de periféricos, incluindo controlador de vídeo VGA, timers, memórias e I/O, formando um pequeno sistema computacional.

## Visão Geral da Arquitetura

O sistema é centrado em uma CPU customizada que se comunica com diversos blocos de memória e periféricos através de um sistema de memória mapeada (MMIO), gerenciado pelo `memory_selector.v`. O módulo `geral.v` é a entidade *top-level* que instancia e conecta todos os componentes.

## Características Principais

* **CPU de 32 bits:**
    * Banco de registradores (`b_registradores.v`).
    * Unidade Lógica e Aritmética (ULA) com suporte a operações como ADD, SUB, AND, OR, XOR, MUL e DIV.
    * Unidade de Instrução (`unidade_instrucao.v`) que decodifica instruções.
    * Execução condicional de instruções baseada nas flags do CPSR (N, Z, C, V).
    * Unidade de Controle (`unidade_controle.v`) que gera os sinais de controle (regWrite, memWrite, jump, etc.).
* **Sistema de Memória:**
    * Memória de Instruções (`memoria_instrucoes.v`).
    * Memória de Dados RAM (`memoria_dados.v`).
    * Unidade de Proteção de Memória (MPU) com registradores de base e limite (`base_lim_reg.v`) para segmentação simples.
* **Gerenciamento de Interrupções:**
    * Módulo de Interrupção (`modulo_interrupcao.v`) que gerencia interrupções de periféricos.
* **Controle de Clock:**
    * Divisor de clock (`div_clock.v`) com múltiplos modos, incluindo "run", "step-by-step" (para debug) e "out".

## Periféricos Integrados (MMIO)

O `memory_selector.v` mapeia endereços para os seguintes periféricos:

* **Controlador de Vídeo VGA:**
    * Implementa um modo texto (80x60 caracteres).
    * Utiliza um `vga_pll` (gerado pelo Quartus) para o clock de pixel.
    * Possui sua própria RAM de texto (`text_ram.v`) e ROM de caracteres (`char_rom.v`).
* **Display de 7 Segmentos:**
    * Controlador (`display_multiplexado.v`) para 4 displays multiplexados.
* **Timer Duplo:**
    * Módulo `dual_timer.v` com dois timers programáveis que podem gerar interrupções.
* **Armazenamento "HD":**
    * Um bloco de memória (`hd.v`) que simula um disco rígido, inicializado a partir do arquivo `hd_memory.txt`.
* **Entrada de Usuário:**
    * Módulo (`modulo_entrada.v`) para ler dados a partir de switches.


## Datapath
![Datapath](images/datapath.png)

## Simulação

Um testbench básico (`geral_tb.v`) é fornecido para verificar a funcionalidade principal. Ele instancia o módulo `geral` e simula a geração de clock e o acionamento dos switches de entrada (`switch_imediato` e `switch_continue`).
