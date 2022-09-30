module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;      

/*
	Write Your Design Here ~
*/
wire srca,srcb,out0,out1,out2,out3;
wire fa_co;
mux2 MUX2to1_a(a,~a,Ainvert,srca);
mux2 MUX2to1_b(b,~b,Binvert,srcb);
and (out0,srca,srcb);
or (out1,srca,srcb);
FA fulladder(out2,fa_co,srca,srcb,c_in);
xor (overflow,c_in,fa_co);
assign out3 = less;
mux4 MUX4to1(out0,out1,out2,out3,op,result);
assign c_out = fa_co;
assign set = out2;
endmodule

module mux2(in0,in1,sel,out);
input in0,in1,sel;
output out;
assign out = (sel)? in1:in0;
endmodule

module mux4(in0,in1,in2,in3,sel,out);
input in0,in1,in2,in3;
input [1:0] sel;
output reg out;
always @(*) begin
	case(sel)
		2'b00:out = in0;
		2'b01:out = in1;
		2'b10:out = in2;
		2'b11:out = in3;
	endcase
end
endmodule