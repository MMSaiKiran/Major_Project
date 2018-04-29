`include "uart_rx.v"
`include "uart_lcd.v"
`include "comparator.v"
`include "multiplier.v"
`include "pwm.v"
`include "motor_cntrl.v"
`include "subtractor.v"
`include "ultrasonic_sen.v"

//speed_udata: push button used to load speed and UART data
module top_controller(LED,SF_D,LCD_E,LCD_RS,LCD_RW,motor1,motor2,motor_enable,echo_pin,trig_pin,clock,reset,speed_udata,start_mod,data_in,Rx_D);
  input clock,reset,start_mod,speed_udata,Rx_D,echo_pin;
  input [3:0] data_in;
  output [7:0] LED;
  output [3:0] SF_D;
  output LCD_E,LCD_RS,LCD_RW;
  output reg motor1,motor2;
  output reg motor_enable;
  output trig_pin;
  reg start,signal_reach;
  reg [5:0] speed;
  wire [7:0] distance;
  
  
  //Instantaition
  central_controller CNTRL(.SF_D(SF_D),.LCD_E(LCD_E),.LCD_RS(LCD_RS),.LCD_RW(LCD_RW),.motor_out(motor_out),.distance(distance),.clock(clock),.reset(reset),.start(start),.speed(speed),.Rx_D(Rx_D));
  range_finder DIST(.LED(LED),.echo_pin(echo_pin),.clk(clock),.rst(reset),.trig_pin(trig_pin),.distance(distance));
  //distance_measurement DIST_SENSOR(distance,valid_distance,trig,echo,reset,clock);
  
  always @(motor_out)
  begin
    motor1 = motor_out;
	 motor2 = 1'b0;
	 motor_enable = 1'b1;
  end
  
  always @(posedge clock,posedge reset)
  begin
    if(reset)
      begin
        start <= 1'b0;
        speed <= 4'h0;
      end
    else if(speed_udata)
      begin
        //Adjust higher bits of speed here
        speed <= {2'b00,data_in};
      end
    else if(start_mod)
      begin
        start <= 1'b1;
      end
	 else
	   begin
		  speed <= speed;
		  start <= start;
		end
  end
  
endmodule 

module central_controller(SF_D,LCD_E,LCD_RS,LCD_RW,motor_out,distance,clock,reset,start,speed,Rx_D);
	input clock,reset,start;
	input [5:0] speed;
	input Rx_D;
	input [7:0] distance;
	output [3:0] SF_D;
	output LCD_E,LCD_RS,LCD_RW;
	output motor_out;
	//Varialbles for Central_Controller
	parameter ideal = 3'd0,init_state=3'd1,mult_enable=3'd2,comp_enable=3'd3,done=3'd4;
	reg [2:0]p_state,n_state;
	//For LCD
	wire [3:0] SF_D;
	wire LCD_E,LCD_RS,LCD_RW;
	//For Multiplier
	reg start_multiplier;
	wire done_multiplication;
	wire [13:0] product;
	//6 bit of valid data is obtained from the UART Module
	reg [5:0] mul_in1,mul_in2;
	//For Comparator
	reg comparator_enable;
	wire greater,lesser,equal;
	reg [7:0] comp_in1,comp_in2;
	//For Uart_Rx
	wire [7:0] uart_data;
	wire valid_uart_data;
	reg valid_data;
	//For PWM
	wire [9:0] pwm_in;
	//Seconds clock
	reg div_enable;
	wire seconds_tick;
	//Baud Generator
	wire baud_tick;
	//Subtractor
	reg sub_enable;
	wire [5:0] time_rem;
	wire [13:0] distance_rem;
	wire signal_reached;
	wire signal_switch;
	
	//Instantiation
	//.formal_parameter(actual_parameter)
	
	//Multiplier module
	multipler_booth MUL(.word1(mul_in1),.word2(mul_in2),.clock(clock),.reset(reset),.start(start_multiplier),.product(product),.ready(done_multiplication));
	//Comparator module with the data length = 14 
	comparator #(14) CMP(.gt(greater),.lt(lesser),.eq(equal),.in1(comp_in1),.in2(comp_in2),.comp_enable(comparator_enable),.reset(reset));
	//PWM Generator
	pwm_gen PWM(.pwm_out(motor_out),.pwm_in(pwm_in),.clock(clock),.reset(reset));
   //Motor Control depending on the comparator output
	motor_control MOTOR_CNTRL(.pwm_width(pwm_in),.distance(distance),.signal_switch(signal_switch),.signal_reached(signal_reached),.valid_uart_data(valid_data),.uart_data_sig(uart_data[7:6]),.lt(lesser),.gt(greater),.eq(equal),.clock(clock),.reset(reset));
	//Secondary Clock (Ticks for every one second)
	clockDivider SEC_CLOCK(.clock(clock),.clear(reset),.clock_div(seconds_tick),.div_enable(div_enable));
	//Subtractor acts as a Timer
	subtractor SUB(.data_out1(time_rem),.data_out2(distance_rem),.signal_switch(signal_switch),.signal_reached(signal_reached),.data_in(uart_data[5:0]),.speed(speed),.seconds_tick(seconds_tick),.valid_data(valid_uart_data),.sub_enable(sub_enable),.clock(clock),.reset(reset));
	//Baud Generator
	baud_generator #(50000000, 9600, 20) BG(.clk(clock),.rst(reset),.baud_tick(baud_tick));
   //LCD Module displays Time, Speed and Signal Colour
	LCD  LCD_BLOCK(.clk(clock),.rst(reset),.lcd_enable(valid_uart_data),.uart_data(uart_data),.speed(speed),.seconds_tick(seconds_tick),.SF_D(SF_D),.LCD_E(LCD_E),.LCD_RS(LCD_RS),.LCD_RW(LCD_RW));
	//Uart Reciever Module
	uart_rx  UART_Rx(.RxD(Rx_D),.clk(clock),.baud_tick(baud_tick),.rst(reset),.RxD_data(uart_data),.data_ready(valid_uart_data));
	
	
	always @(posedge clock)
	begin
	  if(reset)
	    valid_data <= 1'b0;
     else if(valid_uart_data)
       valid_data <= 1'b1;
     else
       valid_data <= valid_data;	  
	end
	
	
	always @(posedge clock)
	begin
	  if(reset)
	  begin
	    sub_enable = 1'b0;
		 div_enable = 1'b0;
     end		 
	  else if(valid_uart_data)
	  begin
	    sub_enable = 1'b1;
		 div_enable = 1'b1;
	  end
	end
	
	
  always @(posedge clock)
  begin
    if(reset)
	 begin
	   p_state <= ideal;
	 end
	 else 
	 begin
	   case(p_state)
		ideal:
		begin
		  start_multiplier <= 1'b0;
	     comparator_enable <= 1'b0;
		  //sub_enable = 1'b0;
	     mul_in1 <= 6'd0;
	     mul_in2 <= 6'd0;
	     comp_in1 <= 14'd0;
	     comp_in2 <= 14'd0;  
	     //LED = 8'h00;
		  if(start)
		    p_state <= init_state;
		  else
		    p_state <= ideal;
		end
		init_state:
		begin
		  start_multiplier <= 1'b0;
	     comparator_enable <= 1'b0;
		  //sub_enable = 1'b0;
	     mul_in1 <= 6'd0;
	     mul_in2 <= 6'd0;
	     comp_in1 <= 14'd0;
	     comp_in2 <= 14'd0;
		  if(valid_uart_data)
		    p_state <= mult_enable;
		  else 
		    p_state <= init_state;
		end
		mult_enable:
		begin
		  mul_in1 <= time_rem;
	     mul_in2 <= speed;
		  start_multiplier <= 1'b1;
		  //sub_enable = 1'b1;
	     comparator_enable <= 1'b0;
		  //LED = 8'h0F;
		  if(signal_reached==1'b1)
		    p_state <= done;
		  else if(done_multiplication==1'b1)
		    p_state <= comp_enable;
		  else
		    p_state <= mult_enable;
		end
		comp_enable:
		begin
		  start_multiplier <= 1'b0;
		  comp_in1 <= product;
	     comp_in2 <= distance_rem; //Distance : 100 meters
		  comparator_enable <= 1'b1;
	     //LED = {greater,equal,lesser};
		  if((time_rem==0) || (signal_reached==1'b1))
		    p_state <= done;
		  else if(seconds_tick)
		    p_state <= mult_enable;
		  else
		    p_state <= comp_enable;
		end
		done:
		begin
		  start_multiplier <= 1'b0;
	     comparator_enable <= 1'b0;
		  //LED = 8'hFF;
		  p_state <= done;
		end
		default:
		begin
		  p_state <= ideal; 
        start_multiplier <= 1'b0;
	     comparator_enable <= 1'b0;
		  //sub_enable = 1'b0;
	     mul_in1 <= 6'd0;
	     mul_in2 <= 6'd0;
	     comp_in1 <= 14'd0;
	     comp_in2 <= 14'd0;		  
		end
		endcase
	 end
  end
	
endmodule
