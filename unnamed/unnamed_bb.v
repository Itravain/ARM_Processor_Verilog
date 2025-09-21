
module unnamed (
	clk,
	reset,
	address,
	chipselect,
	byteenable,
	read,
	write,
	writedata,
	readdata,
	irq,
	IRDA_TXD,
	IRDA_RXD);	

	input		clk;
	input		reset;
	input		address;
	input		chipselect;
	input	[3:0]	byteenable;
	input		read;
	input		write;
	input	[31:0]	writedata;
	output	[31:0]	readdata;
	output		irq;
	output		IRDA_TXD;
	input		IRDA_RXD;
endmodule
