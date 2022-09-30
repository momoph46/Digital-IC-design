module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  			valid;
output  			encode;
output  			finish;
output  	[4:0] 	offset;
output  	[4:0] 	match_len;
output  	[7:0] 	char_nxt;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/
reg [1:0] state,next_state;
parameter s0 = 2'd0;
parameter find_1st = 2'd1;
parameter compare = 2'd2;
parameter result = 2'd3;

//reg [7:0] inseq [2040:0]; 
//reg [7:0] searchlook [16:0];



// total : 4096 (2^12) 128*32
// search buffer :30 / look-ahead buffer :25 / max length :24 
//reg [7:0] inseq [4071:0];//4096-25=4071, 4071+1($)

// now test all image 8192(2^13), 128*64 
reg [7:0] inseq [8167:0];//8192-25=8167, 8167+1=8168
reg [7:0] searchlook [54:0];

reg [5:0] cnt29; // search buffer's idx :0~29
reg [12:0] inptr; //13-bit


wire s_done,same;
wire find_start;

reg [5:0] cpr_len,cpr_tmp;
reg [5:0] rcnt;
integer charcnt;
always @(posedge clk, posedge reset) begin
	if(reset) charcnt <= 0;
	else if(chardata != 8'h24) charcnt <= charcnt + 1;
end
always @(posedge clk, posedge reset)begin
	if (reset) state <= s0;
	else state <= next_state;
end
always @(*) begin
	case (state)
		s0: begin
			if (chardata == 8'h24) next_state = find_1st;
			else next_state = s0;
		end 
		find_1st: begin
			if (find_start) next_state = compare;
			else if (s_done) next_state =result;
			else next_state = find_1st;
		end
		compare: begin
			if (same && cpr_tmp < 6'd24)next_state = compare;
			else if (s_done || cpr_tmp==6'd24) next_state = result;
			else next_state = find_1st;
		end
		result: begin
			if(rcnt==cpr_len)next_state = find_1st;
			else next_state = result;
		end
	endcase
end
//---------//



assign s_done = (cnt29 == 5'd29);
assign find_start = (searchlook[cnt29] == searchlook[5'd30]);


//----------------


reg [4:0] match_len;
reg [4:0] offset;

always @(posedge clk, posedge reset) begin
	if (reset) begin
	  	cpr_len <= 6'd0;
		match_len <= 5'd0;
		offset <= 5'd0;
	end
	else begin
		case (state)
			find_1st:begin
				if (find_start && cpr_len == 6'd0) 
					offset <= cnt29;
			end
			compare:begin
			  	if (cpr_tmp > cpr_len ) begin
					 	cpr_len <= cpr_tmp;
						offset <= cnt29;
				end
			end
			result:begin
				//cpr_len <= 3'd0;
				match_len <= cpr_len;
				if (rcnt==cpr_len)begin
					offset <= (cpr_len == 6'd0)? 6'd0 : 6'd29 - offset;
					cpr_len <= 6'd0;
				end
			end

		endcase
	end
end

//assign same = (searchlook[lookahead + cpr_tmp]==searchlook[find_off+cpr_tmp]);
assign same = (searchlook[6'd30 + cpr_tmp]==searchlook[cnt29+cpr_tmp]);

reg valid, finish;
reg [5:0] i; // 

always @(posedge clk ,posedge reset) begin
	if (reset) finish <= 0;
	else if (char_nxt==8'h24) finish <= 1;
end
reg [7:0] rcv_cnt;
always @(posedge clk, posedge reset) begin
	if(reset) rcv_cnt <= 8'd0;
	else if (state == s0) rcv_cnt <= rcv_cnt + 8'd1;
end

always @(posedge clk, posedge reset) begin
	if (reset) begin
		valid <= 0;
		for (inptr=13'd0;inptr<=13'd8167;inptr=inptr+13'd1)
			inseq[inptr] <= 8'h24;
		for (i=6'd0;i<=6'd54;i=i+6'd1)
			searchlook[i] <= 8'b11111111;
		cpr_tmp <= 6'd0;
		cnt29 <= 6'd0;
		rcnt <= 6'd0;
	end
	else begin
	  case(state)
			s0:begin
				//if(rcv_cnt < 128) begin
				for (i=6'd30;i<6'd54;i=i+6'd1)begin
					searchlook[i] <= searchlook[i+1];
				end
				searchlook[54] <= inseq[0];
				//for(inptr=12'd0;inptr<12'd4071;inptr=inptr+12'd1)begin
				for(inptr=13'd0;inptr<13'd8167;inptr=inptr+13'd1)begin
					inseq[inptr] <= inseq[inptr+1];
				end
				//inseq[4071] <= chardata;
				inseq[8167] <= chardata;
				//end
				//for(i=9;i<2057;i=i+1)begin
				//	buffer[i] <= buffer[i+1];
				//end
				//buffer[2057] <= chardata;
			end
			find_1st:begin
				valid <= 0;
				if (find_start) cpr_tmp <= 1;
				else begin
					cpr_tmp <= 0;
					cnt29 <= cnt29 + 6'd1;
				end
			end
			compare:begin
				if (same) cpr_tmp <= cpr_tmp + 1;
				else cnt29 <= cnt29 + 6'd1;
			end
			result:begin
				cpr_tmp <= 0;
				//valid <= (rcnt==cpr_len);
				cnt29 <= 6'd0;
				if (rcnt==cpr_len) begin
					rcnt <= 8'd0;
					valid <= 1;
				end
				else rcnt <= rcnt + 8'd1;

				for (i=6'd0;i<6'd54;i=i+6'd1)begin
					searchlook[i] <= searchlook[i+1];
				end
				searchlook[54] <= inseq[0];
				for(inptr=13'd0;inptr<13'd8167;inptr=inptr+13'd1)begin
					inseq[inptr] <= inseq[inptr+1];
				end
				
			end
	  endcase
	end
end
assign encode = 1;
assign char_nxt = searchlook[29];



endmodule
