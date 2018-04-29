`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:23:36 03/23/2018 
// Design Name: 
// Module Name:    range_finder 
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
/*module test_us;
      reg echo_pin;
      reg clk;
      reg rst;
      wire trig_pin;
      wire [7:0] distance;

      range_finder RF(echo_pin, clk, rst, trig_pin, distance);

      initial fork
          clk = 1'b0;
          rst = 1'b0;
          echo_pin = 1'b0;
          #50 rst = 1'b1;
          #80 rst = 1'b0;
          #12120 echo_pin = 1'b1;
          #1188620 echo_pin = 1'b0;
      join

      always begin
          #10 clk = ~clk;
      end
endmodule
*/
module range_finder(input echo_pin,
                    input clk,
                    input rst,
                    output reg trig_pin,
                    output reg [7:0] LED,
						  output reg [7:0] distance
                    );

       `include "cal_dist_task.v"

       reg [16:0] pulse_count;
       reg [25:0] counter;
       reg [2:0] state;
       
		 
       localparam two_us = 100;
       localparam ten_us = 500;
		 localparam one_sec = 26'b10111110101111000001111111;

       localparam idle = 3'b000;
       localparam make_trig_pin_low = 3'b001;
       localparam make_trig_pin_high = 3'b010;
       localparam wait_echo_pin_posedge = 3'b011;
       localparam wait_echo_pin_negedge = 3'b100;
       localparam calc_distance = 3'b101;
		 localparam wait_state = 3'b110;

       always @(posedge clk)
		 begin
			 if(rst == 1'b1)
			 begin
				 LED <= 0;
			 end
			 else
			 begin
			    if(distance <= 40)
				 begin
				    LED <= distance;
				 end
				 else
				 begin
				    LED <= 8'hFF;
		       end
			 end
		 end
		 
		 always @(posedge clk)
       begin
          if(rst == 1'b1)
          begin
              state <= idle;
              pulse_count <= 0;
              trig_pin <= 1'b0;
              counter <= 0;
          end

          else
          begin
              case(state)
                  idle:
                  begin
                      trig_pin <= 1'b0;
                      counter <= 0;
                      pulse_count <= 0;
                      state <= make_trig_pin_low;
                  end
                  make_trig_pin_low:
                  begin
                      if(counter == two_us)
                      begin
                          state <= make_trig_pin_high;
                          counter <= 0;
                          trig_pin <= 1'b1;
                      end
                      else
                      begin
                          state <= make_trig_pin_low;
                          counter <= counter + 1'b1;
                          trig_pin <= 1'b0;
                      end
                  end
                  make_trig_pin_high:
                  begin
                      if(counter == ten_us)
                      begin
                          state <= wait_echo_pin_posedge;
                          counter <= 0;
                          trig_pin <= 1'b0;
                      end
                      else
                      begin
                          state <= make_trig_pin_high;
                          counter <= counter + 1'b1;
                          trig_pin <= 1'b1;
                      end
                  end
                  wait_echo_pin_posedge:
                  begin
                      if(echo_pin == 1'b1)
                      begin
                          state <= wait_echo_pin_negedge;
                      end
                      else
                      begin
                          state <= wait_echo_pin_posedge;
                      end
                  end
                  wait_echo_pin_negedge:
                  begin
                      if(pulse_count >= 17'b11111111111111111 && echo_pin == 1'b1)
                      begin
                          state <= idle;
                      end
                      else if(pulse_count < 17'b11111111111111111 && echo_pin == 1'b1)
                      begin
                          pulse_count <= pulse_count + 1'b1;
                      end
                      else if(echo_pin == 1'b0)
                      begin
                          state <= calc_distance;
                      end
                  end
                  calc_distance:
                  begin
                      find_dist(pulse_count, distance);
                      state <= wait_state;
                  end
						wait_state:
						begin
                      if(counter == one_sec-1)
                      begin
                          state <= idle;
                          counter <= 0;
                          trig_pin <= 1'b1;
                      end
                      else
                      begin
                          state <= wait_state;
                          counter <= counter + 1'b1;
                          trig_pin <= 1'b0;
                      end
							 
						end
                  default:
                  begin
                      state <= idle;
                  end
              endcase
          end
       end
endmodule

