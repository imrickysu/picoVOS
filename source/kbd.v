`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Ricky Su
// 
// Create Date:    15:14:43 09/10/2007 
// Design Name:    picoVOS
// Module Name:    keyboard control
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description:    PS/2 keyboard scan code reader
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module kbd(clk, kbd_clk, kbd_data, kbd2pico_rden , kbd2pico_count , kbd2pico_data);
    input clk;
    input kbd_clk;
    input kbd_data;
    output [7:0] kbd2pico_data;
    input kbd2pico_rden; 
    output [3:0] kbd2pico_count;
    
   wire [7:0] kbd_data_p;
   wire [7:0] fifo_datain;
   wire fifo_we;


   //PS/2 keyboard scan code reader
   kbd_receive kbd_receive0 (
    .clk(clk), 
    .kbd_clk(kbd_clk), 
    .kbd_data(kbd_data), 
    .dataout(kbd_data_p), 
    .kbd_data_a(kbd_data_a)
    );
   
   //Keyboard will send out F0 xx when you release a key.
   //This filter remove these scan codes and stores useful keyboard
   //scan code into the FIFO.  
   kbd_f0filter kbd_f0filter0 (
    .clk(clk), 
    .kbd_data_p(kbd_data_p), 
    .kbd_data_a(kbd_data_a), 
    .fifo_datain(fifo_datain), 
    .fifo_we(fifo_we)
    );
    
   //keyboard fifo
   //width: 8 bit
   //depth: 16
   kbd_fifo kbd_fifo0 (
	.clk(clk),
	.din(fifo_datain), // Bus [7 : 0] 
	.rd_en(kbd2pico_rden),
	.wr_en(fifo_we),
	.data_count(kbd2pico_count), // Bus [3 : 0] 
	.dout(kbd2pico_data), // Bus [7 : 0] 
	.empty(),
	.full());
endmodule
