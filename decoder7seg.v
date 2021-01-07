module decoder7seg( input [3:0]i_digit, output reg [7:0]o_sevenseg);//bits description: 0-a,1-b,2-c,3-d,4-e,5-f,6-g
 always @(*)
	case(i_digit)
		0: o_sevenseg = 8'b11000000;
		1: o_sevenseg = 8'b11111001;
		2: o_sevenseg = 8'b10100100;
		3: o_sevenseg = 8'b10110000;
		4: o_sevenseg = 8'b10011001;
		5: o_sevenseg = 8'b10010010;
		6: o_sevenseg = 8'b10000010;
		7: o_sevenseg = 8'b11111000;
		8: o_sevenseg = 8'b10000000;
		9: o_sevenseg = 8'b10010000;
		12:o_sevenseg = 8'b11000110; //Cekundy
		13:o_sevenseg = 8'b10001001; //Xvylyny
		14:o_sevenseg = 8'b11001110; //Godyny
		default: o_sevenseg = 8'b11111111;
	endcase
endmodule