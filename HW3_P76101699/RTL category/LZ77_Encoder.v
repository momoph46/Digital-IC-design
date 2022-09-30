	module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  		    valid;
output  			encode;
output  			finish;
output 		[3:0] 	offset;
output 		[2:0] 	match_len;
output 	 [7:0] 	char_nxt;

// total: 2049
// search buffer 9 - look-ahead buffer 8 - input sequence

/*
	Write Your Design Here ~
*/
reg [1:0] state,next_state;
parameter s0 = 2'd0;
parameter find_1st = 2'd1;
parameter compare = 2'd2;
parameter result = 2'd3;


reg [7:0] inseq [2040:0];
reg [7:0] searchlook [16:0];

reg [3:0] cnt8;
reg [10:0] inptr;


wire s_done,same;
wire find_start;

reg [2:0] cpr_len,cpr_tmp;
reg [2:0] rcnt;


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
			if (same && cpr_tmp < 7)next_state = compare;
			else if (s_done || cpr_tmp==7) next_state = result;
			else next_state = find_1st;
		end
		result: begin
			if(rcnt==cpr_len)next_state = find_1st;
			else next_state = result;
		end
	endcase
end
//---------//



assign s_done = (cnt8 == 4'd8);
assign find_start = (searchlook[cnt8] == searchlook[5'd9]);


//----------------


reg [2:0] match_len;
reg [3:0] offset;

always @(posedge clk, posedge reset) begin
	if (reset) begin
	  	cpr_len <= 3'd0;
		match_len <= 3'd0;
		offset <= 4'd0;
	end
	else begin
		case (state)
			find_1st:begin
				if (find_start && cpr_len == 3'd00) 
					offset <= cnt8;
			end
			compare:begin
			  	if (cpr_tmp > cpr_len ) begin
					 	cpr_len <= cpr_tmp;
						offset <= cnt8;
				end
			end
			result:begin
				//cpr_len <= 3'd0;
				match_len <= cpr_len;
				if (rcnt==cpr_len)begin
					offset <= (cpr_len == 3'd0)? 4'd0 : 4'd8 - offset;
					cpr_len <= 3'd0;
				end
			end

		endcase
	end
end

//assign same = (searchlook[lookahead + cpr_tmp]==searchlook[find_off+cpr_tmp]);
assign same = (searchlook[9 + cpr_tmp]==searchlook[cnt8+cpr_tmp]);

reg valid, finish;
reg [5:0] i;

always @(posedge clk ,posedge reset) begin
	if (reset) finish <= 0;
	else if (char_nxt==8'h24) finish <= 1;
end
always @(posedge clk, posedge reset) begin
	if (reset) begin
		valid <= 0;
		for (inptr=11'd0;inptr<=11'd2040;inptr=inptr+11'd1)
			inseq[inptr] <= 8'h24;
		for (i=6'd0;i<=6'd16;i=i+6'd1)
			searchlook[i] <= 8'b11111111;
		cpr_tmp <= 3'd0;
		cnt8 <= 4'd0;
		rcnt <= 3'd0;
	end
	else begin
	  case(state)
			s0:begin
				for (i=6'd9;i<6'd16;i=i+6'd1)begin
					searchlook[i] <= searchlook[i+1];
				end
				searchlook[16] <= inseq[0];
				for(inptr=11'd0;inptr<11'd2040;inptr=inptr+11'd1)begin
					inseq[inptr] <= inseq[inptr+1];
				end
				inseq[2040] <= chardata;

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
					cnt8 <= cnt8 + 4'd1;
				end
			end
			compare:begin
				if (same) cpr_tmp <= cpr_tmp + 1;
				else cnt8 <= cnt8 + 4'd1;
			end
			result:begin
				cpr_tmp <= 0;
				//valid <= (rcnt==cpr_len);
				cnt8 <= 4'd0;
				if (rcnt==cpr_len) begin
					rcnt <= 3'd0;
					valid <= 1;
				end
				else rcnt <= rcnt + 3'd1;

				for (i=6'd0;i<6'd16;i=i+6'd1)begin
					searchlook[i] <= searchlook[i+1];
				end
				searchlook[16] <= inseq[0];
				for(inptr=11'd0;inptr<11'd2040;inptr=inptr+11'd1)begin
					inseq[inptr] <= inseq[inptr+1];
				end
				
			end
	  endcase
	end
end
assign encode = 1;
assign char_nxt = searchlook[8];


endmodule

