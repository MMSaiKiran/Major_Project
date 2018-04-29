`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:38:15 03/21/2018 
// Design Name: 
// Module Name:    subtractor 
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
module subtractor(data_out1,data_out2,signal_switch,signal_reached,data_in,speed,seconds_tick,valid_data,sub_enable,clock,reset);
  input sub_enable;
  input clock,reset,seconds_tick,valid_data;
  input [5:0]data_in;
  input [5:0]speed;
  output reg [5:0]data_out1;
  output reg [13:0] data_out2;
  output signal_reached;
  output signal_switch;
  
  assign signal_switch = (data_out1 == 6'h00);
  assign signal_reached = (data_out2<=speed);
  
  always @(posedge clock)
  begin
    if(reset)
	 begin
	   data_out1 <= 6'h00;
		data_out2 <= 14'h0000; 
	 end
	 else if (sub_enable==1'b1)
	 begin
      if(valid_data)
	   begin
	     data_out1 <= data_in;
		  data_out2 <= 14'd100;
	   end
	   else if(seconds_tick)
	   begin
		  if(data_out1 != 6'h00)
	       data_out1 <= (data_out1 - 1'b1);
		  if((data_out2 > speed))
		    data_out2 <= (data_out2 - speed);
	   end
      else
      begin	 
        data_out1 <= data_out1;
		  data_out2 <= data_out2;
      end	
    end
	 else
      begin	 
        data_out1 <= data_out1;
		  data_out2 <= data_out2;
      end
  end

endmodule
