`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:22:18 03/02/2018 
// Design Name: 
// Module Name:    comparator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

/* Input1 Input2 gt:Greater than lt:Less than eq:Equal to */
module comparator(gt,lt,eq,in1,in2,comp_enable,reset);
  parameter word_len = 14;
  input comp_enable,reset;
  input [word_len-1:0]in1,in2;
  output reg gt,lt,eq;
  always @(in1,in2,comp_enable,reset)
  begin: comparator_block
	if(reset)
	begin
		gt = 1'b0;
		lt = 1'b0;
		eq = 1'b0;
	end
	else if(comp_enable)
	begin
		if(in1>in2)
		begin
			gt = 1'b1;
			lt = 1'b0;
			eq = 1'b0;
		end
		else if(in1<in2)
		begin
			lt = 1'b1;
			gt = 1'b0;
			eq = 1'b0;
		end
		else
		begin
			eq = 1'b1;
			lt = 1'b0;
			gt = 1'b0;
		end
	end 
	else 
	begin
		gt = 1'b0;
		lt = 1'b0;
		eq = 1'b0;
	end
  end
endmodule 
