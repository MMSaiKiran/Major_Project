`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:23:10 03/21/2018 
// Design Name: 
// Module Name:    uart_lcd 
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

//LCD Module
module LCD(input clk, rst, lcd_enable,
           input [7:0]  uart_data,
           input [5:0] speed,
			  input seconds_tick,
           output [3:0] SF_D, 
           output LCD_E, 
           output reg LCD_RS,
           output LCD_RW 
           );
	`include "my_task.v"           
	parameter init_IDLE = 4'b0000, init_fifteenms = 4'b0001, 
	          init_one = 4'b0010,init_two = 4'b0011, 
	          init_three = 4'b0100, init_four = 4'b0101, 
				 init_five = 4'b0110, init_six = 4'b0111, 
				 init_seven = 4'b1000, init_eight = 4'b1001, 
				 init_DONE = 4'b1010;

	parameter cd_INIT = 5'b00000, cd_function_set = 5'b00001, 
		     	cd_entry_set = 5'b00010, cd_set_display = 5'b00011,
            cd_clr_display = 5'b00100, cd_pause = 5'b00101, 
            cd_set_addr = 5'b00110,cd_done = 5'b00111,
            cd_print_T = 5'b01000,cd_print_coln = 5'b01001, 
            cd_set_addr_2 = 5'b01010,cd_print_S = 5'b01011,
            cd_print_coln1 = 5'b01100,cd_print_MSD_speed = 5'b01101,
            cd_print_LSD_speed = 5'b01110, cd_set_addr_1 = 5'b01111,
            cd_print_S1 = 5'b10000, cd_print_i = 5'b10001,
            cd_print_g = 5'b10010, cd_print_coln2 = 5'b10011,
            cd_print_color = 5'b10100, cd_set_addr_3 = 5'b10101, 
            cd_get_MSD_LSD = 5'b10110,cd_print_MSD = 5'b10111, 
            cd_print_LSD = 5'b11000;

	parameter high_setup = 3'b000, high_hold = 3'b001, 
	          oneus = 3'b010,low_setup = 3'b011, 
	          low_hold = 3'b100, fortyus = 3'b101,
            done = 3'b110, wait_state=3'b111;

	reg [2:0] tx_state;
	reg [3:0] init_state;
	reg [4:0] cur_state;
	reg init_init, init_done, tx_init;
	reg [7:0] tx_byte;
	reg [3:0] SF_D0;
	reg [3:0] SF_D1;
	reg LCD_E0, LCD_E1, mux;
	reg [7:0] reg_uart_data;
	reg [3:0] reg_MSD,speed_MSD;
	reg [3:0] reg_LSD,speed_LSD;

	integer i ;
	integer i2 ;
	integer i3 ;

	//assign SF_CE0 = 1'b1;
	assign LCD_RW = 1'b0;
	assign LCD_E = (mux==1'b0) ? LCD_E0 : LCD_E1;
	assign SF_D = (mux==1'b0) ? SF_D0 : SF_D1;


	always @(posedge clk)
	begin
	  if(lcd_enable==1'b1)
	    begin
	      divide(speed[5:0], speed_MSD, speed_LSD);
	    end
	end
	
	always @(cur_state)
	begin
		case(cur_state)
			cd_INIT: 
			begin
				tx_init <= 1'b0;
        mux <= 1'b1;
        init_init <= 1'b1;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00000000;
      end
                       
      cd_function_set: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b00101000;
      end
                               
      cd_entry_set: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b00000110;
      end
                             
      cd_set_display: 
			begin 
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b00001100; 
      end
                            
      cd_clr_display: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b00000001;
      end
                                
      cd_pause: 
			begin
				tx_init <= 1'b0;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00000000;
      end
                         
      cd_set_addr: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b10000000;
      end
                           
      cd_done:   
			begin
				tx_init <= 1'b0;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00000000;
      end

   	  cd_print_T:	
			begin
				tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= 8'b01010100;
			end

     	cd_print_coln:	
			begin
				tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= 8'b00111010;
			end

      cd_set_addr_2: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b10000101;
      end

     	cd_print_S:  
			begin
				tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= 8'b01010011;
			end
 
     	cd_print_coln1:
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00111010;
			end
			
			cd_print_MSD_speed:
			begin
			  tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= (8'h30+speed_MSD);
			end
			
			cd_print_LSD_speed:
			begin
			  tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= (8'h30+speed_LSD);
			end
			
			cd_set_addr_1: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b11000000;
      end
			
		  cd_print_S1:  
			begin
				tx_init <= 1'b1;
				mux <= 1'b0;
				init_init <= 1'b0;
				LCD_RS <= 1'b1;
				tx_byte <= 8'b01010011;
			end
			
			cd_print_i:
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b01101001; //0x69
			end
			
			cd_print_g: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b01100111; //0x67
      end
			
			cd_print_coln2:
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00111010;
			end

   	  cd_print_color:
			begin
				mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_init <= 1'b1;
        if(reg_uart_data[7:6] == 2'b00)
					begin
						tx_byte <= 8'b01010010;
          end
        else if(reg_uart_data[7:6] == 2'b01)
					begin
						tx_byte <= 8'b01011001;
          end
        else if(reg_uart_data[7:6] == 2'b10)
					begin
						tx_byte <= 8'b01000111;
          end
        else
					begin
						tx_init <= 1'b0;
            tx_byte <= 8'b00000000;
          end
			end

      cd_set_addr_3: 
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b0;
        tx_byte <= 8'b10000010;
      end

      cd_get_MSD_LSD: 
			begin
				tx_init <= 1'b0;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00000000;
      end

   	  cd_print_MSD:
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= reg_MSD + 8'h30;
			end

   	  cd_print_LSD:
			begin
				tx_init <= 1'b1;
        mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= reg_LSD + 8'h30;
			end

      default: 
			begin
				tx_init <= 1'b0;
				mux <= 1'b0;
        init_init <= 1'b0;
        LCD_RS <= 1'b1;
        tx_byte <= 8'b00000000;
			end
		endcase
	end			 

	always @(posedge clk) 
	begin
		if(rst == 1'b1)
			reg_uart_data <= 8'b00000000;
 
		else if(lcd_enable == 1'b1)
			reg_uart_data <= uart_data;

		else if(seconds_tick == 1'b1)
		begin
			if(reg_uart_data[5:0] > 6'b000000)
				reg_uart_data[5:0] <= reg_uart_data[5:0] + 6'b111111;
		end
	end
	
	always @(posedge clk)
   begin
		if(rst == 1'b1)
      begin
        cur_state <= cd_INIT;
        i3 <= 0;
      end
    else
      begin
        case(cur_state)
          cd_INIT:
          begin
            if(init_done == 1'b1)
              begin
                cur_state <= cd_function_set;
              end
            else
              cur_state <= cd_INIT;
          end
                       
          cd_function_set: 
          begin
            if(i2 == 2000)
              begin
                cur_state <= cd_entry_set;
              end
            else
              begin
                cur_state <= cd_function_set;
              end
          end
                               
          cd_entry_set: 
          begin
            if(i2 == 2000)
              cur_state <= cd_set_display;
            else
              cur_state <= cd_entry_set;
          end
                             
          cd_set_display: 
          begin 
            if(i2 == 2000)
              cur_state <= cd_clr_display;
            else
              cur_state <= cd_set_display;
          end
                            
          cd_clr_display: 
          begin
            if(i2 == 2000)
              cur_state <= cd_pause;
            else
              cur_state <= cd_clr_display;
          end
                                
          cd_pause: 
          begin
            if(i3 == 82000)
              begin
                cur_state <= cd_set_addr;
                i3 <= 0;
              end
            else
              begin
                cur_state <= cd_pause;
                i3 <= i3+1;
              end
          end
                         
          cd_set_addr: 
          begin
            if(i2 == 2000)
              cur_state <= cd_done;
            else 
              cur_state <= cd_set_addr;
          end
                               
          cd_done:
          begin
					  if(lcd_enable==1'b1)
							cur_state <= cd_print_T;
						else
							cur_state <= cd_done;
          end
          
          cd_print_T:
					begin
						if(i2 == 2000)
							cur_state <= cd_print_coln;
						else
							cur_state <= cd_print_T;
					end

				  cd_print_coln:
					begin
						if(i2 == 2000)
							cur_state <= cd_set_addr_2;
						else
							cur_state <= cd_print_coln;
					end

				  cd_set_addr_2:
					begin
						if(i2 == 2000)
							cur_state <= cd_print_S;
						else
							cur_state <= cd_set_addr_2;
					end

				  cd_print_S:
					begin
						if(i2 == 2000)
							cur_state <= cd_print_coln1;
						else
							cur_state <= cd_print_S;
					end

				  cd_print_coln1:
					begin
						if(i2 == 2000)
							cur_state <= cd_print_MSD_speed;
						else
							cur_state <= cd_print_coln1;
					end
					
					cd_print_MSD_speed:
					begin
					  if(i2==2000)
					    cur_state <= cd_print_LSD_speed;
					  else
					    cur_state <= cd_print_MSD_speed;  
					end
					
					cd_print_LSD_speed:
					begin
					  if(i2==2000)
					    cur_state <= cd_set_addr_1;
					  else
					    cur_state <= cd_print_LSD_speed;  
					end

          cd_set_addr_1:
          begin
            if(i2 == 2000)
              cur_state <= cd_print_S1;
            else 
              cur_state <= cd_set_addr_1;
          end
                           
          cd_print_S1:
          begin
            if(i2==2000)
              cur_state <= cd_print_i;
            else
              cur_state <= cd_print_S1;
          end
          
          cd_print_i:
          begin
            if(i2==2000)
              cur_state <= cd_print_g;
            else
              cur_state <= cd_print_i;
          end
          
          cd_print_g:
          begin
            if(i2==2000)
              cur_state <= cd_print_coln2;
            else
              cur_state <= cd_print_g;
          end
          
          cd_print_coln2:
          begin
            if(i2==2000)
              cur_state <= cd_print_color;
            else
              cur_state <= cd_print_coln2;
          end

				  cd_print_color:
					begin
						if(i2 == 2000)
							cur_state <= cd_set_addr_3;
						else
							cur_state <= cd_print_color;
					end

				  cd_set_addr_3:
					begin
						if(i2 == 2000)
							cur_state <= cd_get_MSD_LSD;
						else
							cur_state <= cd_set_addr_3;
					end

				  cd_get_MSD_LSD:
					begin
					if(lcd_enable==1'b1)
						cur_state <= cd_set_addr_1;
					else
					begin
						if(seconds_tick == 1'b1)
							begin
								if(reg_uart_data[5:0] == 6'b000000)
									begin
										cur_state <= cd_done;
									end
								else
									begin
										divide(reg_uart_data[5:0], reg_MSD, reg_LSD);
										cur_state <= cd_print_MSD;
								end
							end
						else
							cur_state <= cd_get_MSD_LSD;
					end
					end

				  cd_print_MSD:
					begin
						if(lcd_enable==1'b1)
							cur_state <= cd_set_addr_1;

						else if(i2 == 2000)
							cur_state <= cd_print_LSD;
						else
							cur_state <= cd_print_MSD;
					end

				  cd_print_LSD:
					begin
						if(lcd_enable==1'b1)
							cur_state <= cd_set_addr_1;
						else if(i2 == 2000)
							cur_state <= cd_set_addr_3;
						else
							cur_state <= cd_print_LSD;
					end

            endcase

          end

        end
     
	always @(posedge clk)
	begin
		if(rst == 1'b1)
		begin
			tx_state <= done;
			i2 <= 0;
		end
		else
		begin
			case(tx_state)
				high_setup:
				begin
									LCD_E0 <= 1'b0;
									SF_D0 <= tx_byte[7:4];
									if(i2 == 2)
									begin
										tx_state <= high_hold;
										i2 <= 0;
									end
									else
									begin
										tx_state <= high_setup;
										i2 <= i2+1;
									end
			   end
            high_hold: 
				begin
									LCD_E0 <= 1'b1;
									SF_D0 <= tx_byte[7:4];
									if(i2 == 12)
									begin
										tx_state <= oneus;
										i2 <= 0;
									end
									else
									begin
										tx_state <= high_hold;
										i2 <= i2+1;
									end
            end

            oneus: 			
				begin
									LCD_E0 <= 1'b0;
									if(i2 == 50)
									begin
										tx_state <= low_setup;
										i2 <= 0;
									end
									else
									begin
										tx_state <= oneus;
										i2 <= i2+1;
									end
            end
                
				low_setup: 		
				begin
									LCD_E0 <= 1'b0;
									SF_D0 <= tx_byte[3:0];
									if(i2 == 2)
									begin
										tx_state <= low_hold;
										i2 <= 0;
									end
									else
									begin
										tx_state <= low_hold;
										i2 <= i2+1;
									end
            end

            low_hold:  		
				begin
									LCD_E0 <= 1'b1;
									SF_D0 <= tx_byte[3:0];
									if(i2 == 12) 
									begin
										tx_state <= fortyus;
										i2 <= 0;
									end
									else
									begin
										tx_state <= low_hold;
										i2 <= i2+1;
									end
            end

            fortyus: 		
				begin
									LCD_E0 <= 1'b0;
									if(i2 == 2000)
									begin
										tx_state <= done;
										i2 <= 0;
									end
									else
									begin
										tx_state <= fortyus;
										i2 <= i2+1;
									end
            end
                     
            done:
            begin
									LCD_E0 <= 1'b0;
									i2 <= 0;
									tx_state <= wait_state;
									/*if(tx_init == 1'b1)
									begin
										tx_state <= high_setup;
										i2 <= 0;
									end
									else
									begin
										tx_state <= done;
										i2 <= 0;
									end
                           */
            end

            wait_state:
            begin
									if(tx_init == 1'b1)
									begin
										tx_state <= high_setup;
										i2 <= 0;
									end
								   else
									begin
										tx_state <= wait_state;
										i2 <= 0;
									end
            end
			endcase
		end
	end
                  
   always @(posedge clk) 
   begin
		if(rst == 1'b1) 
      begin
        init_state <= init_IDLE;
        init_done <= 1'b0;
        i<= 0;
      end
      else 
      begin
			case(init_state) 
				init_IDLE: 
				begin
                       init_done <= 1'b0;
                       if(init_init == 1'b1)
                         begin
                           init_state <= init_fifteenms;
                           i<=0;
                         end
                       else 
                         begin
                           init_state <= init_IDLE;
                           i <= i+1;
                         end
                      end
             
     init_fifteenms: begin
                     init_done <= 1'b0;
                     if(i == 750000) 
                     begin
                       init_state <= init_one;
                       i <= 0;
                     end
                     else
                     begin
                       init_state <= init_fifteenms;
                       i <= i+1;
                     end
                   end
     init_one: begin
               SF_D1 <= 4'b0011;
					LCD_E1 <= 1'b1;
               init_done <= 1'b0;
               if(i == 11)
               begin
                 init_state <= init_two;
                 i <= 0;
               end
               else
               begin
                  init_state <= init_one;
                  i <= i+1;
               end
             end
     init_two: begin
	            LCD_E1 <= 1'b0;
               init_done <= 1'b0;
               if(i == 205000)                    
               begin
                 init_state <= init_three;
                 i <= 0;
               end
               else 
               begin
                  init_state <= init_two;
                  i <= i+1;
               end
             end
             
     init_three: begin
	              
                 SF_D1 <= 4'b0011;
                 LCD_E1 <= 1'b1;
					  init_done <= 1'b0;
                 if(i == 11)
                 begin
                   init_state <= init_four;
                   i <= 0;
                 end
                 else
                 begin
                   init_state <= init_three;
                   i <= i+1;
                 end
               end
               
     init_four: begin
                LCD_E1 <= 1'b0;
					 init_done <= 1'b0;
                if(i == 5000)
                begin
                  init_state <= init_five;
                  i <= 0;
                end
                else
                begin
                  init_state <= init_four;
                  i <= i+1;
                end
              end
              
      init_five: begin
                 SF_D1 <= 4'b0011;
					  LCD_E1 <= 1'b1;
                 init_done <= 1'b0;
                 if(i == 11)
                   begin
                     init_state <= init_six;
                     i <= 0;
                   end
                 else
                   begin
                     init_state <= init_five;
                     i <= i+1;
                   end
                 end
      init_six: begin
		          LCD_E1 <= 1'b0;
                init_done <= 1'b0;
					 
                if(i == 2000) 
                  begin
                    init_state <= init_seven;
                    i <= 0;
                  end
                else
                  begin
                    init_state <= init_six;
                    i <= i+1;
                  end
                end
      init_seven: begin
                  SF_D1 <= 4'b0010;
						LCD_E1 <= 1'b1;
                  init_done <= 1'b0;
                  if(i == 11)
                    begin
                      init_state <= init_eight;
                      i <= 0;
                    end
                  else 
                    begin
                      init_state <= init_seven;
                      i <= i+1;
                    end
                  end
      init_eight: begin
		            LCD_E1 <= 1'b0;
                  init_done <= 1'b0;
                  if(i == 2000)
                    begin
                      init_state <= init_DONE;
                      i <= 0;
                    end
                  else
                    begin
                      init_state <= init_eight;
                      i <= i+1;
                    end
                  end
      init_DONE: begin
                 init_state <= init_DONE;
                 init_done <= 1'b1;
                 end
  endcase
end
end

endmodule

module clockDivider(input clock,input div_enable, input clear, output reg clock_div);

localparam constantNumber = 26'b10111110101111000001111111;

reg [25:0] count;

always @ (posedge clock)
begin
  if(clear == 1'b1)
    count <= 26'b0;
  else if(div_enable == 1'b1)
  begin
    if(count == constantNumber - 1)
      count <= 26'b0;
    else
      count <= count+1;
  end
end

always @ (posedge clock)
begin
  if(clear == 1'b1)
    clock_div <= 1'b0;
  else if(div_enable == 1'b1)
  begin
    if(count == constantNumber - 1)
      clock_div <= 1'b1;
    else
      clock_div <= 1'b0;
  end
end 

endmodule


