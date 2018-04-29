`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:38:01 03/21/2018 
// Design Name: 
// Module Name:    motor_cntrl 
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
module motor_control(pwm_width,valid_uart_data,uart_data_sig,signal_reached,signal_switch,distance,lt,gt,eq,clock,reset);
  input clock,reset;
  input lt,gt,eq;
  input valid_uart_data;
  input signal_reached,signal_switch;
  input [1:0] uart_data_sig;
  input [7:0] distance;
  output reg [9:0] pwm_width;
  parameter RED = 2'b00, YELLOW = 2'b01, GREEN = 2'b10;
  
  always @(posedge clock)
  begin
    if(reset)
      begin
        pwm_width <= 10'd510; //initially move with 50% 
      end
	 else if((distance>=8'd5)&&(distance<=8'd9))
	   begin
		  pwm_width <= 10'd300; //Slow down
		end
    else if(distance<8'd5)
	   begin
		  pwm_width <= 10'd0; //STOP
		end	
	 else if(signal_reached==1'b1)
	   begin
		  case(uart_data_sig)
		  RED:
		  begin
		    if(signal_switch!=1'b1)
		      pwm_width <= 10'd0; //STOP
			 else
			   pwm_width <= 10'd310; //Start the vehicle as signal will now change to green
		  end
		  YELLOW:
		    if(signal_switch!=1'b1)
		      pwm_width <= pwm_width;
			 else
			   pwm_width <= 10'd0;
		  GREEN:
		    pwm_width <= pwm_width; //No Change
		  endcase 
		end
    else if (valid_uart_data)
     begin
		case(uart_data_sig)
		RED:
		  begin
        if(lt)
          begin
            pwm_width <= pwm_width; //No Change
          end
        else if(gt)
          begin
            pwm_width <= 10'd300;  //Slow
          end
        else if(eq)
          begin
            pwm_width <= 10'd300;  //Slow
          end
        else
          begin
            pwm_width <= pwm_width;
          end
		  end
		YELLOW:
		  begin
        if(lt)
          begin
            pwm_width <= 10'd300; //Slow
          end
        else if(gt)
          begin
            pwm_width <= pwm_width; //No Change 
          end
        else if(eq)
          begin
            pwm_width <= 10'd300; //Slow
          end
        else
          begin
            pwm_width <= pwm_width;
          end
			 end
		GREEN:
		  begin
        if(lt)
          begin
            pwm_width <= 10'd1000; //Fast
          end
        else if(gt)
          begin
            pwm_width <= pwm_width; //No change
          end
        else if(eq)
          begin
            pwm_width <= 10'd1000; //Fast
          end
        else
          begin
            pwm_width <= pwm_width;
          end
	     end
		default:
		  begin
		    pwm_width <= pwm_width;
		  end
		endcase
	   end
		else
		begin
		  pwm_width <= 10'd500;
      end
  end
  
endmodule 


