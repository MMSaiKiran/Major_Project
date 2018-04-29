`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:35:28 03/21/2018 
// Design Name: 
// Module Name:    my_task 
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
task automatic divide;
  input [5:0] in;
  output [3:0] MSD;
  output [3:0] LSD;
  integer int_in;
  integer int_MSD;
  integer int_LSD;
  
  begin
    int_in   = {26'b00000000000000000000000000, in};
    int_MSD  = (int_in<<6) + (int_in<<5) + (int_in<<2) + (int_in<<1);
    int_MSD  = int_MSD >> 10;
    MSD[3:0] = int_MSD[3:0];
    int_LSD  = int_in - (int_MSD*10);
	 if(int_LSD > 9)
		begin
			MSD[3:0] = MSD[3:0] + 4'b0001;
			LSD[3:0] = 4'b0000;
		end
	 else
		LSD[3:0] = int_LSD[3:0];
  end
endtask   
