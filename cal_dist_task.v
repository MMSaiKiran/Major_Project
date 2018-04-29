`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:18:13 04/18/2018 
// Design Name: 
// Module Name:    cal_dist_task 
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
task automatic find_dist;
    input [16:0] pulse_count;
    output [7:0] distance;
    reg [63:0] temp;
    integer i;

    begin
        temp = (pulse_count<<15) + (pulse_count<<10) + (pulse_count<<7) + (pulse_count<<6) + (pulse_count<<4);
        //$display("%0d",temp);
        for(i=0; i<8; i=i+1)
        begin

            temp  = (temp<<6) + (temp<<5) + (temp<<2) + (temp<<1);
            temp  = temp >> 10;
            //$display("%0d",temp);
        end
        distance = temp + 1;
        //$display("%0d",distance);

    end

endtask