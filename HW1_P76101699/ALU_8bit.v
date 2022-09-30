module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

/*
	Write Your Design Here ~
*/
wire [7:0] set_out,of_out;
wire out0to1,out1to2,out2to3,out3to4,out4to5,out5to6,out6to7,out7;
wire less_src;
ALU_1bit ALU0(.a(ALU_src1[0]),.b(ALU_src2[0]),.less(less_src),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(Binvert),.op(op),
.result(result[0]),.c_out(out0to1),.set(set_out[0]),.overflow(of_out[0]));

ALU_1bit ALU1(.a(ALU_src1[1]),.b(ALU_src2[1]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out0to1),.op(op),
.result(result[1]),.c_out(out1to2),.set(set_out[1]),.overflow(of_out[1]));

ALU_1bit ALU2(.a(ALU_src1[2]),.b(ALU_src2[2]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out1to2),.op(op),
.result(result[2]),.c_out(out2to3),.set(set_out[2]),.overflow(of_out[2]));

ALU_1bit ALU3(.a(ALU_src1[3]),.b(ALU_src2[3]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out2to3),.op(op),
.result(result[3]),.c_out(out3to4),.set(set_out[3]),.overflow(of_out[3]));

ALU_1bit ALU4(.a(ALU_src1[4]),.b(ALU_src2[4]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out3to4),.op(op),
.result(result[4]),.c_out(out4to5),.set(set_out[4]),.overflow(of_out[4]));

ALU_1bit ALU5(.a(ALU_src1[5]),.b(ALU_src2[5]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out4to5),.op(op),
.result(result[5]),.c_out(out5to6),.set(set_out[5]),.overflow(of_out[5]));

ALU_1bit ALU6(.a(ALU_src1[6]),.b(ALU_src2[6]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out5to6),.op(op),
.result(result[6]),.c_out(out6to7),.set(set_out[6]),.overflow(of_out[6]));

ALU_1bit ALU7(.a(ALU_src1[7]),.b(ALU_src2[7]),.less(1'b0),
.Ainvert(Ainvert),.Binvert(Binvert),.c_in(out6to7),.op(op),
.result(result[7]),.c_out(out7),.set(set_out[7]),.overflow(of_out[7]));

assign zero = (result==8'd0);
xor (less_src,set_out[7],of_out[7]);
assign overflow = of_out[7];
endmodule
