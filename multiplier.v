`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:23:42 03/02/2018 
// Design Name: 
// Module Name:    multiplier 
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
module multipler_booth(word1,word2,clock,reset,start,product,ready);
	 parameter data_length = 6;
	 input [data_length-1:0] word1;
    input [data_length-1:0] word2;
    input clock;
    input reset;
    input start;
    output [((2*data_length)+1):0] product;
    output ready;
	 wire load_word,shift,add,sub,m0;
	 
	 //Instantiation
	 control_mul CNTRL(load_word,shift,add,sub,ready,start,clock,reset,m0);
	 datapath_booth DP(product,m0,word1,word2,load_word,add,sub,shift,clock,reset);
	 
endmodule


module control_mul(load_word,shift,add,sub,ready,start,clock,reset,m0);
	localparam data_length = 3'd6;
	localparam state_len = 3'd4;
	input clock,reset,start;
	input m0;
	output reg load_word,shift,add,sub;
	output wire ready;
	wire [1:0] BRC;
	reg m0_prev;
	reg [3:0] count;
	parameter s_idle = 4'd0, s1 = 4'd1, s2 = 4'd2, s3 = 4'd3, s4 = 4'd4, s5 = 4'd5, s6 = 4'd6, s7 = 4'd7, s8 = 4'd8,done = 4'd9;
	reg [(state_len-1):0] p_state,n_state;
	
	assign ready = (p_state==done);
	assign BRC = {m0,m0_prev};
	//assign count = (p_state==s_idle || p_state==done)? 4'b0000 : ((p_state==s2)? count+1 : count);
	
	always @(posedge clock)
	begin
		if(reset)
			count <= 4'b0000;
		else if((p_state==s_idle) || (p_state==done))
			count <= 4'b0000;
		else if(p_state==s2)
			count <= count+1;
	end
	
	always @(posedge clock)
	begin
	if(reset)
		begin
		  p_state <= s_idle;
	     m0_prev <= 1'b0;
		end
	else
		begin
		  p_state <= n_state;
		  m0_prev <= m0;
		end
	end
	
	always @(posedge clock)
	begin
	  if(reset)
	    load_word <= 1'b0;
	  else if((start==1'b1)&&(p_state==s_idle))
	    load_word <= 1'b1;
	  else
	    load_word <= 1'b0;
	end
	
	
	always @(p_state or start or BRC or count)
	begin
		case(p_state)
		s_idle:
		begin
			shift = 1'b0;
			add = 1'b0;
			sub = 1'b0;
			if(start)
			begin
			n_state = s1;
			end
			else
			n_state = s_idle;
		end
		s1:
		begin	
		shift = 1'b0;
		add = 1'b0;
		sub = 1'b0;
		if(count<=data_length)
		 begin
			if(BRC==2'd0 || BRC==2'd3)
			begin
			n_state = s2;
			end
			else if(BRC==2'd1)
			begin
			add = 1'b1;
			n_state = s2;
			end
			else if(BRC==2'd2)
			begin
			sub = 1'b1;
			n_state = s2;
			end
		 end
		else
		 begin
			n_state = done;
		 end
		end
		s2:
		begin
			add = 1'b0;
			sub = 1'b0;
			shift = 1;
			n_state = s1;
	   end
		done:
		begin
			n_state = s_idle;
		end	
		default:
		begin
		  sub  = 1'b0;
		  shift = 1'b0;
		  add = 1'b0;
		  n_state = s_idle;
		end
		endcase
	end
	/*
	always @(posedge clock)
	begin
	  if(reset)
	    begin
		   p_state <= s_idle;
		 end
	  else
	    begin
		  case(p_state)
		  s_idle:
		  begin
			load_word <= 1'b0;
			shift <= 1'b0;
			add <= 1'b0;
			sub <= 1'b0;
			if(start)
			begin
			load_word <= 1'b1;
			p_state <= s1;
			end
			else
			p_state <= s_idle;
		  end
		  s1:
		  begin	
		  load_word <= 1'b0;
		  shift <= 1'b0;
		  add <= 1'b0;
		  sub <= 1'b0;
		  if(count<=data_length)
		  begin
			if(BRC==2'd0 || BRC==2'd3)
			begin
			p_state <= s2;
			end
			else if(BRC==2'd1)
			begin
			add <= 1'b1;
			p_state <= s2;
			end
			else if(BRC==2'd2)
			begin
			sub <= 1'b1;
			p_state <= s2;
			end
		 end
		 else
		 begin
			p_state <= done;
		 end
		 end
		 s2:
		 begin
			load_word <= 1'b0;
			add <= 1'b0;
			sub <= 1'b0;
			shift <= 1;
			p_state <= s1;
	    end
	  	 done:
		 begin
			p_state <= s_idle;
		 end	
		endcase
	  end
	end
	*/
endmodule 

module datapath_booth(product,m0,word1,word2,load_word,add,sub,shift,clock,reset);
	parameter data_length = 6;
	input [data_length-1:0] word1,word2;
	input clock,reset,load_word,add,sub,shift;
	output [(2*data_length+1):0] product;
	output m0;
	reg [data_length:0]multiplier,multiplicand;
	reg [(2*data_length+1):0] product;
	
	assign m0 = multiplier[0];
	
	always @(posedge clock)
	begin
	if(reset)
	begin
		product <= 0;
		multiplicand <= 0;
		multiplier <= 0;
	end
	else if(shift)
	begin
		multiplier <= multiplier>>1;
		product <= {product[(2*data_length+1)],product[(2*data_length+1):1]};
	end
	else if(add)
	begin
		product[(2*data_length+1):(data_length+1)] <= product[(2*data_length+1):(data_length+1)] + multiplicand;
	end
	else if(sub)
	begin
		product[(2*data_length+1):(data_length+1)] <= product[(2*data_length+1):(data_length+1)] - multiplicand;
	end
	else if(load_word)
	begin
		multiplicand <= word1;
		multiplier <= word2;
		product <= 0;
	end
	else
	begin
	  product <= product;
	  multiplicand <= multiplicand;
	  multiplier <= multiplier;
	end
	end
	
endmodule 

