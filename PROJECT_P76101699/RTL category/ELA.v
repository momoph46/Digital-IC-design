`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output 				req;
	output 				wen;
	output 		[12:0]	addr; //13-bit
	output 		[7:0]	data_wr;
	output 				done;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/
	parameter getpixel = 3'b000;
parameter calboundary = 3'b001;
parameter calmid = 3'b010;
parameter idle = 3'b011;
parameter calmidfive = 3'b100;

//image size: 128 * 63
//col :128(7) / row :63(6)
//



reg wen;
reg [5:0] row;//6-bit
reg [6:0] col;//7-bit
reg [7:0] data_wr;
reg req;
reg [2:0] state, next_state;
reg [8:0] sum;
reg [3:0] cnt;
wire bound_done;
wire mid_done;

always @(posedge clk, posedge rst) begin
	if (rst) state <= idle;
	else state <= next_state;
end
always @(*) begin
	case(state)
		idle:begin
			if (req==1 && ready)next_state=getpixel;
			//if(ready) next_state = getpixel;
			else next_state=idle;
		end
		getpixel:begin
			if (addr==8063) next_state = calboundary;
			else next_state = getpixel;
		end
		calboundary:begin
			if(bound_done) next_state = calmid;
			else next_state = calboundary;
		end
		calmid:begin
			if(mid_done) next_state = calmidfive;
			else next_state = calmid;
		end
		calmidfive:begin
			next_state = calmidfive;
		end
	endcase	
end

reg [7:0] min,max;
reg done;

//assign bound_done = (wen==1 && addr==959);
assign bound_done = (wen==1 && addr == 7935);
assign mid_done = (wen==1 && addr == 7934);

reg [12:0] addr;
always @(posedge clk, posedge rst) begin
	if (rst) begin
		req <= 0;
		row <= 6'd0;
		col <= 7'd0;
		wen <= 0;
	end
	else 
		case (state) 
			idle:begin
				if(ready) begin
					req <= ~req;
					if (req) begin
						col <= col + 1;	
						wen <= 1;
					end
				end
			end
			getpixel: begin
				//if (addr==991) begin
				if(addr == 8063) begin // go to next state 
					row <= 1;
					wen <= 0;
				end
				else begin
					//if (col==31) begin
					if(col == 127) begin
						req <= 1;
						row <= row + 2;
					end
					col <= col + 1;
				end
			end
			calboundary: begin
				if (bound_done)begin
					wen <= 0;
					row <= 1;
					col <= 1;
				end
				else begin
					//if (cnt==3)begin
					if (cnt ==2) begin
						wen <= 1;
						//row <= (row==29)?1:row + 2;
						//col <= (row==29)? ~col :col;
						row <= (row==61)?1:row + 2;
						col <= (row==61)? ~col :col;
						
					end
					else wen <=0;
				end
			end
			calmid: begin/*
				if (cnt == 7)begin
					wen <= 1;
					col <= (col==126)? 1 : col + 1;
					row <= (col==126)? row+2:row;
				end
				else wen <= 0;
				*/
				if(mid_done) begin
					wen <= 0;
					row <= 1;
					col <= 1;
				end
				else begin
					if(cnt == 7) begin
					/*-- warning --*/
						wen <= 1;
						col <= (col==126)? 1 : col + 1;
						row <= (col==126)? row+2:row;
					end
					else wen <= 0;
				end
			end
			calmidfive: begin
				if(cnt == 9) begin
					wen <= 1;
					col <= (col==126)? 1 : col + 1;
					row <= (col==126)? row+2:row;
				end
				else wen <= 0;
			end
		endcase

end
/*
always @(posedge clk, posedge rst) begin
	if (rst) done <= 0;
	//else if (addr==958) done <= 1;
	else if (addr==7934) done <= 1;
end
*/
always @(posedge clk, posedge rst) begin
	if (rst) done <= 0;
	else if (addr==7934 && wen && state == calmidfive) done <= 1;
end


wire [5:0] top, down;
assign top = row - 1;
assign down = row + 1;
always @(posedge clk, posedge rst) begin
	if (rst) addr <= 13'd0;
	else begin
		if (state == getpixel) 
			addr <= {row,col};//6(row)+7(col)
		else if (state == calboundary)begin
			case(cnt)
				0: addr <= {top,col};
				1: addr <= {down,col};
				2: addr <= {row,col};
			endcase
		end
		else if (state == calmid) begin
			
			case(cnt)
				0:addr <= {row-6'd1,col};
				1:addr <= {row+6'd1,col};
				2:addr <= {row-6'd1,col-7'd1};
				3:addr <= {row+6'd1,col+7'd1};
				
				4:addr <= {row-6'd1,col+7'd1};
				5:addr <= {row+6'd1,col-7'd1};
				7:addr <= {row,col};
			endcase
		end
		else if (state == calmidfive) begin
			
			case(cnt)
				/*
				0:addr <= {row-6'd1,col};
				1:addr <= {row+6'd1,col};
				2:addr <= {row,col-7'd1};
				3:addr <= {row,col+7'd1};
				*/
				0:addr <= {row,col-7'd1};
				1:addr <= {row,col+7'd1};
				2:addr <= {row-6'd1,col};
				3:addr <= {row+6'd1,col};
				4:addr <= {row-6'd1,col-7'd1};
				5:addr <= {row+6'd1,col+7'd1};
				6:addr <= {row-6'd1,col+7'd1};
				7:addr <= {row+6'd1,col-7'd1};
				
				9:addr <= {row,col};
			endcase
		end
	end
end
// set s1 & s2
reg [7:0] s1,s2;
always @(posedge clk, posedge rst) begin
	if (rst) begin
		s1 <= 8'd0;
		s2 <= 8'd0;
	end
	else if (state == calmid || state == calmidfive) begin
	    if (cnt[0] == 1) s1 <= data_rd;
		else s2 <= data_rd;
	end
end
// get abs(s1-s2)
wire [7:0] d0;
wire [8:0] psum,bsum;
assign d0 = (s1 > s2)? s1 - s2 : s2 - s1;
assign psum = {1'b0,s1}+{1'b0,s2};
assign bsum = sum + {1'b0,data_rd};



/*------new method-------*/
reg [10:0] newsum;


always @(posedge clk,posedge rst) begin
	if (rst) begin
		sum <= 9'd0;
		data_wr <= 8'd0;
		//min <= 8'b11111111;
		max <= 8'd0;
		newsum <= 11'd0;
	end
	else begin
		case (state)
			//idle, getpixel : data_wr <= in_data;
			idle, getpixel : if(ready) data_wr <= in_data;
			calboundary: begin
				if (cnt==1) sum <= {1'b0,data_rd};
				else if (cnt==2) data_wr <= bsum[8:1];
			end
			calmid, calmidfive: begin
				if (cnt == 0) min <= 8'b11111111;
				else if (cnt[0]==1 && cnt > 1) begin
					if( d0 < min )begin
						data_wr <= psum [8:1];
						min <= d0;
					end

				end
			end

			/*
			calmid: begin
				if(cnt==9) begin
					newsum <= 11'd0;
					data_wr <= newsum[10:3];
				end
				else if(cnt >=1 && cnt <=8)newsum <= newsum + {3'd0,data_rd};
			end
			*/
		endcase
	end
end



//cnt 
always @(posedge clk, posedge rst) begin
	if (rst) cnt <= 4'd0;
	else if (state == calboundary) begin
		//if (cnt==2 || addr==959) cnt <= 0;
		if (cnt==2 || addr==7935) cnt <= 0;
		else cnt <= cnt +1;
	end
	else if (state == calmid) begin
		if (cnt == 7 || addr == 7934) cnt <= 0;
		else cnt <= cnt +1;
		
	end
	else if (state == calmidfive) begin
		if (cnt == 9) cnt <= 0;
		else cnt <= cnt +1;
	end
end	


endmodule

