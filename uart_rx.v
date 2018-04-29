`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:50:48 03/21/2018 
// Design Name: 
// Module Name:    uart_rx 
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
module baud_generator(input clk, input rst, output baud_tick);
 
  parameter clkFreq = 50000000;
  parameter Baud = 9600;
  parameter BGAccWidth = 20;
  parameter BGInc = ((Baud<<(BGAccWidth-4)) + (clkFreq>>5))/(clkFreq>>4);
  
  reg [BGAccWidth:0] BGAcc;
  
  always @(posedge clk)
    begin
      if(rst == 1'b1)
        BGAcc <= 0;
      else if(rst == 1'b0)
        BGAcc <= BGAcc[BGAccWidth-1:0] + BGInc;
    end
   
   assign baud_tick = BGAcc[BGAccWidth];
   
endmodule

module uart_rx(input RxD, input clk, input baud_tick, input rst,
               output reg [7:0] RxD_data,
               output reg data_ready);
               
    //wire baud_tick;
    reg [1:0] RxD_sync;
    reg [3:0] state;
    reg [1:0] RxD_cnt;
    reg RxD_bit;
 	 
	 
    //baud_generator #(50000000, 9600, 20) BG_Tx(clk, rst, baud_tick);


    always @(posedge clk)
      begin
        RxD_sync <= {RxD_sync[0], RxD};
      end
      
    always @(posedge clk)
     begin
        if(rst == 1'b1) 
          begin
            RxD_cnt <= 0;
          end
        if(RxD_sync[1] == 1'b1 && RxD_cnt!=2'b11)
          begin
            RxD_cnt <= RxD_cnt + 1;
          end
        else if(RxD_sync[1] == 1'b0 && RxD_cnt!= 2'b00)
          begin
            RxD_cnt <= RxD_cnt - 1;
          end
          
        if(RxD_cnt == 2'b00 ) RxD_bit <= 1'b0;
        else if(RxD_cnt == 2'b11) RxD_bit <= 1'b1;
     end
       
    always @(posedge clk)
      begin
       if(rst == 1'b1) 
          begin
            state <= 4'b0000;
            RxD_data <= 8'b0;
          end
		 else
        case(state)
          4'b0000: if(RxD_bit == 1'b0)   begin state <= 4'b1000; RxD_data <= 8'b0; end
          4'b1000: if(baud_tick == 1'b1) begin state <= 4'b1001; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1001: if(baud_tick == 1'b1) begin state <= 4'b1010; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1010: if(baud_tick == 1'b1) begin state <= 4'b1011; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1011: if(baud_tick == 1'b1) begin state <= 4'b1100; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1100: if(baud_tick == 1'b1) begin state <= 4'b1101; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1101: if(baud_tick == 1'b1) begin state <= 4'b1110; RxD_data <= {RxD_bit, RxD_data[7:1]}; end            
          4'b1110: if(baud_tick == 1'b1) begin state <= 4'b1111; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b1111: if(baud_tick == 1'b1) begin state <= 4'b0001; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b0001: if(baud_tick == 1'b1) begin state <= 4'b0010; RxD_data <= {RxD_bit, RxD_data[7:1]}; end
          4'b0010: if(baud_tick == 1'b1) begin state <= 4'b0000; end
          default: if(baud_tick == 1'b1) begin state <= 4'b0000; end 
        endcase
      end
      
    always @(posedge clk)
      begin
        case(state)
          4'b0010: if(baud_tick == 1'b1) data_ready <= 1'b1; else data_ready <= 1'b0;
          default: data_ready <= 1'b0;
        endcase
      end
                
endmodule
