`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:37:16 03/21/2018 
// Design Name: 
// Module Name:    pwm 
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

module pwm_gen(pwm_out,pwm_in,clock,reset);
  parameter PWM_Length = 4'd10;
  parameter Max_value = 10'd1023;
  parameter Min_value = 10'd0;
  input clock,reset;
  input [PWM_Length-1:0] pwm_in;
  output pwm_out;
  reg [PWM_Length-1:0] count;
  reg cnt_dir; //If 0 it will count up or else it will count down
  wire [PWM_Length-1:0] cnt_next;
  wire count_end;
  
  assign count_end = (cnt_dir)? (count==Min_value):(count==Max_value);
  assign cnt_next = (cnt_dir)? count-1'b1 : count+1'b1 ;
  
  assign pwm_out = cnt_dir;
  
  always @(posedge clock)
  begin
    if(reset==1'b1)
      begin
        count <= Min_value;
        cnt_dir <= 1'b0;
      end
    else
      begin
        count <= (count_end) ? pwm_in : cnt_next;
        cnt_dir <= cnt_dir ^ count_end; 
      end
  end
    
endmodule