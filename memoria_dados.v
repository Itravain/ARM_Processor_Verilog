// Quartus Prime Verilog Temple
// Single part RAM with single read/write address

module memoria_dados
#(parameter DATA_WIDTH=32, parameter ADDR_WIDTH=10)
(
	input [(DATA_WIDTH-1):0] data, 
	input [(DATA_WIDTH-1):0] read_addr, write_addr,
	input we, read_clock, write_clock,
	output reg [(DATA_WIDTH-1):0] q
);
	
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
	
	always @ (posedge write_clock)
	begin
		// Write
		if (we)
			ram[write_addr] <= data;
	end 
	
	
	// Countinuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.
	
	always @ (posedge read_clock)
	begin
		q <= ram[read_addr];
	end 
	
endmodule 