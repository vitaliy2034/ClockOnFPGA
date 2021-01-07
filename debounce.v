module debounce #(parameter DIV_CONST)(
 input i_clk, i_sw,
 output reg [1:0]o_sw_state);
	//local parameters
	localparam [28:0]DEB_CNT_PRESSED = 5 * DIV_CONST;
	localparam [28:0]DEB_CNT_LONG = DEB_CNT_PRESSED - (2 * DIV_CONST)/3;
	localparam [28:0]DEB_CNT_STB  = DEB_CNT_PRESSED - DIV_CONST/10;
	
	reg [2:0] i_sw_sync; //synchronizer registers
	reg [31:0] cnt; //counter registers
	
	//detect end of counting
	wire cnt_over = ~|cnt;
	
	//Synchronizer of input button 
	always@(posedge i_clk) begin
		i_sw_sync = {i_sw_sync[1], i_sw_sync[0], i_sw};
	end
	
	// front detector
	wire sw_unprsd = ~i_sw_sync[2] & i_sw_sync[1];
	
	//Button press handler
	always@(posedge i_clk) begin
		if(1'b0 == i_sw_sync[2]) begin
				cnt <= cnt - 1'b1;
				if(cnt_over)
					o_sw_state <= 2'b00;
				else if(sw_unprsd) begin
					if(cnt <= DEB_CNT_LONG)
							o_sw_state <= 2'b01;
					else if(cnt <= DEB_CNT_STB)
							o_sw_state <= 2'b10;
				end 
		end else begin
			cnt <= DEB_CNT_PRESSED;
			o_sw_state <= 2'b11;
		end
	end
endmodule