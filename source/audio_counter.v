`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:36:11 10/16/2007 
// Design Name:    picoVOS
// Module Name:    audio_counter 
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description:    Audio counter inverts when it counts up to the freq_rom output data.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module audio_counter(clk, preload, counter_load, dout);
    input clk;
    input [16:0] preload;
    input counter_load;
    output dout;

    reg [16:0] preload_cnt = 17'b0;
    reg [16:0] cnt = 17'b0;
    reg dout = 1'b0;
    
    always @(posedge clk)
    begin
      if (counter_load)
         preload_cnt <= preload;
      else
         preload_cnt <= preload_cnt;
    end
    
    always @(posedge clk)
    begin
      if (cnt > preload_cnt) begin
         cnt <= 17'b0;
         dout <= ~dout;
      end   
      else begin
         cnt <= cnt + 1;  
         dout <= dout;
      end   
    end


endmodule
