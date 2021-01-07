module my_clock(input i_clk, i_sw, output [2:0] o_digit_en, output [7:0] o_seven_seg);
parameter DIV_CONST = 50_000_000; //frequency of clock source, which connected to i_clk
parameter [19:0]SIGN_CLK_CNT = 200_000; //(4 ms) count of i_clk ticks for shifting symbol of seven segment display

reg rst_n;
reg inc_sec, inc_min, inc_hour;
wire [1:0]sw_state;

wire    [3:0]   sec0, sec1, min0, min1, hour0, hour1;  
wire            sec0_to_sec1, sec1_to_min0, min0_to_min1, min1_to_hour0, hour0_to_hour1;
wire            tick_1hz;

wire clr_hrs    = (8'h24 == {hour1, hour0}); 

//enable tick only if modes are shw_sec, shw_min, shw_hour 
wire tick_en = ~mode[2];

// Creating 1 Hz reference signal
counter #(.MAX_VAL(DIV_CONST-1), .WIDTH(26) ) freq_div(.i_clk (i_clk), 
                                                        .i_rst_n (rst_n), 
                                                        .i_srst (1'b0),
                                                        .i_cnt_en (tick_en), 
                                                        .o_data (),
                                                        .o_tick (tick_1hz)
                                                       );

// Counters for secs, mins, hours
counter #(.MAX_VAL(9), .WIDTH(4) ) sec_0(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (1'b0),
                                          .i_cnt_en (tick_1hz | inc_sec), 
                                          .o_data (sec0),
                                          .o_tick (sec0_to_sec1)
                                        );

counter #(.MAX_VAL(5), .WIDTH(4) ) sec_1(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (1'b0),
                                          .i_cnt_en (sec0_to_sec1),
                                          .o_data(sec1), 
                                          .o_tick (sec1_to_min0)
                                        );

counter #(.MAX_VAL(9), .WIDTH(4) ) min_0(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (1'b0),
                                          .i_cnt_en (sec1_to_min0 | inc_min), 
                                          .o_data(min0),
                                          .o_tick (min0_to_min1)
                                        );

counter #(.MAX_VAL(5), .WIDTH(4) ) min_1(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (1'b0),
                                          .i_cnt_en (min0_to_min1), 
                                          .o_data(min1),
                                          .o_tick (min1_to_hour0)
                                        );

counter #(.MAX_VAL(9), .WIDTH(4) ) hour_0(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (clr_hrs),
                                          .i_cnt_en (min1_to_hour0 | inc_hour), 
                                          .o_data(hour0),
                                          .o_tick (hour0_to_hour1)
                                        );

counter #(.MAX_VAL(5), .WIDTH(4) ) hour_1(.i_clk (i_clk), 
                                          .i_rst_n (rst_n), 
                                          .i_srst (clr_hrs),
                                          .i_cnt_en (hour0_to_hour1), 
                                          .o_data(hour1),
                                          .o_tick ()
                                        );
	
	reg [3:0] digits_to_disp [2:0];
	wire [7:0] digits_sev_seg [2:0];

	assign o_seven_seg = digits_sev_seg[o_digit_en[1:0]];
	
	disp_seven_seg #(SIGN_CLK_CNT) dyn_ind (i_clk, rst_n, o_digit_en);
	
	decoder7seg (digits_to_disp[0],digits_sev_seg[0]);
	decoder7seg (digits_to_disp[1],digits_sev_seg[1]);
	decoder7seg ({2'b11, digits_to_disp[2][1:0]},digits_sev_seg[2]);
	
	debounce #(DIV_CONST) but_ctrl (i_clk, i_sw, sw_state);
	
reg [2:0] mode;

localparam [2:0] shw_sec = 0, shw_min = 1, shw_hour = 2, set_sec = 4, set_min = 5, set_hour = 6;

	always@(posedge i_clk) begin
		if(sw_state == 2'b00)  begin
			rst_n <= 0;
			mode <= 0;
		end else begin
			rst_n <= 1;
		case(mode)
			shw_sec:begin
				digits_to_disp[2] = 4'd12;
				digits_to_disp[1] = sec0;
				digits_to_disp[0] = sec1;
				if(sw_state == 2'b10)
					mode = shw_min;
				if(sw_state == 2'b01)
					mode = set_sec;
			end
			shw_min:begin
				digits_to_disp[2] = 4'd13;
				digits_to_disp[1] = min0;
				digits_to_disp[0] = min1;
				if(sw_state == 2'b10)
					mode = shw_hour;
				if(sw_state == 2'b01)
					mode = set_sec;
			end
			shw_hour: begin
				digits_to_disp[2] = 4'd14;
				digits_to_disp[1] = hour0;
				digits_to_disp[0] = hour1;
				if(sw_state == 2'b10)
					mode = shw_sec;
				if(sw_state == 2'b01)
					mode = set_sec;
			end
			set_sec:	begin
				digits_to_disp[2] = 4'd12;
				digits_to_disp[1] = sec0;
				digits_to_disp[0] = sec1;
				if(sw_state == 2'b01)
					mode = set_min;
				if(sw_state == 2'b10) 
					inc_sec = 1'b1;
				else 
					inc_sec = 0;
			end
			set_min:	begin
				digits_to_disp[2] = 4'd13;
				digits_to_disp[1] = min0;
				digits_to_disp[0] = min1;
				if(sw_state == 2'b01)
					mode = set_hour;
				if(sw_state == 2'b10) 
					inc_min = 1'b1;
				else 
					inc_min = 0;
			end
			set_hour:begin
				digits_to_disp[2] = 4'd14;
				digits_to_disp[1] = hour0;
				digits_to_disp[0] = hour1;
				if(sw_state == 2'b01)
					mode = shw_sec;
				if(sw_state == 2'b10) 
					inc_hour = 1'b1;
				else 
					inc_hour = 0;
			end
			default: begin 
				digits_to_disp[0] = 0;
				digits_to_disp[1] = 0;
				digits_to_disp[2] = 0;
				end
		endcase
	end
	end
	
	
endmodule