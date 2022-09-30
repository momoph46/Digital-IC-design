`timescale 1ns/10ps

module ELA(clk, rst, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output				req;
	output				wen;
	output		[9:0]	addr;
	output		[7:0]	data_wr;
	output				done;


	//--------------------------------------
	//		Write your code here
	//--------------------------------------
parameter getpixel = 2'b00;
parameter calboundary = 2'b01;
parameter calmid = 2'b10;
parameter idle = 2'b11;

reg wen;
reg [4:0] row;
reg [4:0] col;
reg [7:0] data_wr;
reg req;
reg [1:0] state, next_state;
reg [8:0] sum;
reg [3:0] cnt;
wire bound_done;
always @(posedge clk, posedge rst) begin
	if (rst) state <= idle;
	else state <= next_state;
end
always @(*) begin
	case(state)
		idle:begin
			if (req==1)next_state=getpixel;
			else next_state=idle;
		end
		getpixel:begin
			if (addr==991) next_state = calboundary;
			else next_state = getpixel;
		end
		calboundary:begin
			if(bound_done) next_state = calmid;
			else next_state = calboundary;
		end
		calmid:begin
			next_state = calmid;
		end
	endcase	
end

reg [7:0] min;
reg done;

assign bound_done = (wen==1 && addr==959);
reg [9:0] addr;
always @(posedge clk, posedge rst) begin
	if (rst) begin
		req <= 0;
		row <= 5'd0;
		col <= 5'd0;
		wen <= 0;
	end
	else 
		case (state) 
			idle:begin
				req <= ~req;
				if (req) begin
					col <= col + 1;	
					wen <= 1;
				end
			end
			getpixel: begin
				if (addr==991) begin
					row <= 1;
					wen <= 0;
				end
				else begin
					if (col==31) begin
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
						row <= (row==29)?1:row + 2;
						col <= (row==29)? ~col :col;
					end
					else wen <=0;
				end
			end
			calmid: begin
				if (cnt == 7)begin
					wen <= 1;
					col <= (col==30)? 1 : col + 1;
					row <= (col==30)? row+2:row;
				end
				else wen <= 0;
				
				
			end
		endcase

end
always @(posedge clk, posedge rst) begin
	if (rst) done <= 0;
	else if (addr==958) done <= 1;
end
wire [4:0] top, down;
assign top = row - 1;
assign down = row + 1;
always @(posedge clk, posedge rst) begin
	if (rst) addr <= 10'd0;
	else begin
		if (state == getpixel) 
			addr <= {row,col};
		else if (state == calboundary)begin
			case(cnt)
				0: addr <= {top,col};
				1: addr <= {down,col};
				2: addr <= {row,col};
				//3: addr <= {row,col};
			endcase
		end
		else if (state == calmid) begin
			case(cnt)
				0:addr <= {row-5'd1,col};
				1:addr <= {row+5'd1,col};
				2:addr <= {row-5'd1,col-5'd1};
				3:addr <= {row+5'd1,col+5'd1};
				
				4:addr <= {row-5'd1,col+5'd1};
				5:addr <= {row+5'd1,col-5'd1};
				7:addr <= {row,col};
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
	else if (state == calmid) begin
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
/*
always @(posedge clk, posedge rst) begin
	if (rst) sum <= 9'd0;
	else if (state == calboundary) begin
		case(cnt) 
			1: sum <= {1'b0,data_rd};
			2: sum <= sum + {1'b0,data_rd};
		endcase
	end
end
*/
always @(posedge clk,posedge rst) begin
	if (rst) begin
		sum <= 9'd0;
		data_wr <= 8'd0;
		min <= 8'b11111111;
	end
	else begin
		case (state)
			idle, getpixel : data_wr <= in_data;
			calboundary: begin
				if (cnt==1) sum <= {1'b0,data_rd};
				else if (cnt==2) data_wr <= bsum[8:1];
				//if (cnt==3) data_wr <= sum[8:1]; 
			end
			calmid: begin
				if (cnt == 0) min <= 8'b11111111;
				else if (cnt[0]==1 && cnt > 1) begin
					if( d0 < min )begin
						data_wr <= psum [8:1];
						min <= d0;
					end

				end
			end
		endcase
	end
end
//cnt 
always @(posedge clk, posedge rst) begin
	if (rst) cnt <= 4'd0;
	else if (state == calboundary) begin
		//if (cnt == 3 || addr==959) cnt <= 0; 
		if (cnt==2 || addr==959) cnt <= 0;
		else cnt <= cnt +1;
	end
	else if (state == calmid) begin
		if (cnt == 7) cnt <= 0;
		else cnt <= cnt +1;
	end
end	

endmodule
