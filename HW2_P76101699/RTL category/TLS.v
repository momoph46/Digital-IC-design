module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output reg         Gout;
output reg      Yout;
output reg      Rout;

/*
    Write Your Design Here ~
*/
parameter state_idle = 3'd0;
parameter state_set = 3'd1;
parameter state_red = 3'd2;
parameter state_yellow = 3'd3;
parameter state_green = 3'd4;
reg [2:0] state,next_state;
reg [3:0] r_num,y_num,g_num;
reg [3:0] gcnt,ycnt,rcnt;
wire g_done,r_done,y_done;
//reg g_done,r_done,y_done;

always@(posedge clk, posedge reset)begin
	if(reset) state <= state_idle;
	else if (!Stop)state <= next_state; 
end
reg stop_flag;
always@(posedge clk, posedge reset)begin
	if(reset) stop_flag <= 0;
	else if (Stop)stop_flag <= 1;
	else stop_flag <= 0; 
end


always @(*)begin
	case(state)
		state_idle:begin
			if(Set)next_state=state_green;
			else next_state = state_idle;
		end
		state_green:begin
			if (Jump) next_state = state_red;
			else if (Set) next_state=state_green;
			else if(g_done /*|| stop_flag*/) next_state=state_yellow;
			else next_state=state_green;
		end
		state_yellow:begin
			if (Jump) next_state = state_red;
			else if (Set) next_state=state_green;
			else if(y_done/*|| stop_flag*/)next_state=state_red;
			else next_state=state_yellow;
		end
		state_red:begin
			if (Set) next_state=state_green;
			else if(r_done /*|| stop_flag*/)next_state=state_green;
			else next_state=state_red;
		end
	endcase
end

always @(posedge clk, posedge reset)begin
	if (reset) begin
		r_num <= 4'd0;
		y_num <= 4'd0;
		g_num <= 4'd0;
	end
	else if (Set) begin
		r_num <= Rin;
		y_num <= Yin;
		g_num <= Gin;
	end
end

assign g_done=(gcnt==(g_num-1));
assign y_done=(ycnt==(y_num-1));
assign r_done=(rcnt==(r_num-1));

/*
always @(posedge clk, posedge reset) begin
	if (reset) begin
		{g_done,y_done,r_done} <= 3'b000;
	end
	else begin
		 g_done<=(gcnt==(g_num-2));
		 y_done<=(ycnt==(y_num-2));
		 r_done<=(rcnt==(r_num-2));
	end
end
*/
always @(posedge clk, posedge reset) begin
	if(reset) {gcnt,ycnt,rcnt}<={4'd0,4'd0,4'd0};
	else if (Set || Jump) {gcnt,ycnt,rcnt}<={4'd0,4'd0,4'd0};
	else begin
		case(state)
			state_green:begin
				if (!Stop) begin
					if (gcnt==(g_num-1))gcnt<=4'd0;
					else /*if (!Stop)*/gcnt<=gcnt+1;
				end
				//else if(!stop_flag)gcnt<=gcnt+1;
			end
			state_yellow:begin
				if (!Stop) begin
					if (ycnt==(y_num-1))ycnt<=4'd0;
					else /*if (!Stop)*/ycnt<=ycnt+1;
				end
				//else if(!stop_flag)ycnt<=ycnt+1;
			end
			state_red:begin
				if (!Stop) begin
					if (rcnt==(r_num-1))rcnt<=4'd0;
					else /*if (!Stop)*/rcnt<=rcnt+1;
				end
				//else if(!stop_flag)rcnt<=rcnt+1;
			end
		endcase
	end
end
always @(*) begin
	case(state)
		state_green:{Gout,Yout,Rout}=3'b100;
		state_yellow:{Gout,Yout,Rout}=3'b010;
		state_red:{Gout,Yout,Rout}=3'b001;
		default:{Gout,Yout,Rout}=3'b000;
	endcase
end







endmodule
