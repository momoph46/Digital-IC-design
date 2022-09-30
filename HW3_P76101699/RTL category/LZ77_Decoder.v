module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	 	[7:0] 	char_nxt;


/*
	Write Your Design Here ~
*/
reg [7:0] buffer [0:8];
reg [2:0] ll;
reg [3:0] i;
//wire last;
reg finish;
//reg [7:0] char_nxt;
assign encode = 0;
assign char_nxt = buffer[0];

always @(posedge clk, posedge reset) begin
	if (reset)begin 
		//char_nxt <= 8'd0;
		ll <= 3'd0;
		for (i = 0;i<=8;i=i+1)
			buffer[i] <= 8'd0; 
		finish <= 0;
	end
	else begin
		for (i=0;i<8;i=i+1)
			buffer[i+1] <= buffer[i];
	
		if (code_len==0 || code_len==ll) begin
			//char_nxt <= chardata;
			//for (i=0;i<8;i=i+1)
			//	buffer[i+1] <= buffer[i];
			buffer[0] <= chardata;
			ll <= 3'd0;
			if (char_nxt == 8'h24) finish <= 1; //87

		end
		else begin		 
			//for (i=0;i<8;i=i+1)
			//	buffer[i+1] <= buffer[i];
			buffer[0] <= buffer[code_pos];
			ll <= ll + 1;
		end
	end
	
end
//assign last = (code_len == ll);

endmodule

