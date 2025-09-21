module bcd(	input wire [4:0] entrada, 
				output reg [6:0] display_7);
				
	always @(*) begin 
		case(entrada)
			4'b0000   : display_7 = 7'b1000000;
			4'b0001   : display_7 = 7'b1111001;
			4'b0010   : display_7 = 7'b0100100;
			4'b0011   : display_7 = 7'b0110000;
			4'b0100   : display_7 = 7'b0011001;
			4'b0101   : display_7 = 7'b0010010;
			4'b0110   : display_7 = 7'b0000010;
			4'b0111   : display_7 = 7'b1111000;
			4'b1000   : display_7 = 7'b0000000;
			4'b1001   : display_7 = 7'b0011000;
			default   : display_7 = 7'bXXXXXXX;
	  endcase
	end
endmodule 