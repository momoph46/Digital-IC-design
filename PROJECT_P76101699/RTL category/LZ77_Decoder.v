module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input				ready;
input 		[4:0] 	code_pos;
input 		[4:0] 	code_len;
input 		[7:0] 	chardata;
output  			encode;
output  			finish;
output 	  [7:0] 	char_nxt;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/

reg [7:0] buffer [0:29];//30
reg [4:0] ll;
reg [5:0] i;
//wire last;
reg finish;
//reg [7:0] char_nxt;
assign encode = 0;
assign char_nxt = buffer[0];

always @(posedge clk, posedge reset) begin
	if (reset)begin 
		//char_nxt <= 8'd0;
		ll <= 5'd0;
		for (i = 0;i<=29;i=i+1)
			buffer[i] <= 8'd0; 
		//finish <= 0;
	end
	else if (ready) begin
		for (i=0;i<29;i=i+1)
			buffer[i+1] <= buffer[i];
	
		if (code_len==0 || code_len==ll) begin
			//char_nxt <= chardata;
			
			buffer[0] <= chardata;
			ll <= 5'd0;
			//if (char_nxt == 8'h24) finish <= 1; //87

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
always@(posedge clk,posedge reset)begin
	if(reset) finish <= 0;
	else if (char_nxt==8'h24) finish <= 1;
end
endmodule
