`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:38:11 10/05/2007 
// Design Name:    picoVOS
// Module Name:    musicbox 
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description:    MusicBox stores music data.
//                 An address counter add one every time VSYNC have a pulse.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module musicbox(clk, reset, enable, vsync, data);
    input clk;
    input reset;
    input enable;
    input vsync;
    output [7:0]data;

reg [10:0] counter = 11'b0;


//address counter add one every time VSYNC have a pulse.
always @(posedge clk)
begin
	if (reset)
		counter <= 11'b0;
	else if (enable)
      if (vsync)
         counter <= counter + 1'b1;
      else
         counter <= counter;


end

//Music data ROM
music music_data (
	.clka(clk),
	.addra(counter), // Bus [10 : 0] 
	.douta(data)); // Bus [7 : 0] 
	


endmodule
