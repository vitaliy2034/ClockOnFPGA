module disp_seven_seg #(parameter [19:0]SIGN_CLK_CNT) (
input i_clk, rst_n,
output [2:0]o_digit_en
);

//Counter register
reg	[19:0] cnt;
//Shift register	
reg 	[2:0]	 shft = 1'b1;
//Overflow signal
wire 	over_flow = ~|cnt;

assign o_digit_en = shft;
//Shift register which shifts when is overflow
always@(posedge i_clk, negedge rst_n) begin
	if(~rst_n) begin
		cnt <= 0;
		shft <= 1;
	end else begin
		if(over_flow)begin
			cnt <= SIGN_CLK_CNT;
			shft <= {shft[1:0],shft[2]};
		end else
			cnt <= cnt - 1'b1;
	end
end

endmodule