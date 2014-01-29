`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:34:33 09/20/2007 
// Design Name:    picoVOS
// Module Name:    kbd_f0filter 
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description:    keyboard will send out F0 xx when you release a key on keyboard.
//                 This filter remove these scan codes and stores useful keyboard
//                 scan code into the FIFO.  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module kbd_f0filter(clk, kbd_data_p, kbd_data_a, fifo_datain, fifo_we);
    input clk;
    input [7:0] kbd_data_p;
    input kbd_data_a;
    output [7:0] fifo_datain;
    output fifo_we;
    
    reg [7:0] fifo_datain = 8'h00;
    reg fifo_we = 1'b0;
    
    reg filter_status = 1'b0;

   //F0 Filter
   always @(posedge clk)
   begin
      fifo_we <= 1'b0;
      if (kbd_data_a == 1'b1)
         if (kbd_data_p == 8'hF0) begin
            filter_status <= 1'b1;
            
            fifo_datain <= fifo_datain;
         end
         else if (filter_status == 1'b1) begin
            filter_status <= 1'b0;
            fifo_datain <= fifo_datain;
           
         end 
         else begin
            filter_status <= 1'b0;
            fifo_datain <= kbd_data_p;
            fifo_we <= 1'b1;
         end   
   end
endmodule
