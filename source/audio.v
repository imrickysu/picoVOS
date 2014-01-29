`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:49:50 10/16/2007 
// Design Name:    picoVOS
// Module Name:    audio 
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description:    Audio module select the output of audio counter according to PicoBlaze outputs.
//                 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module audio(clk, counter_load_num, dout, dout_en, dout_sel, freq_addr);
    input clk;
    input [2:0] counter_load_num; // use 3-8 decode to generate a 7 bit counter_load signal
    input [5:0] freq_addr;

    input dout_en;  
    input [2:0] dout_sel; //select which counter data to output
    
    output reg dout;
    
    // the input ports which need to be registered outside:
    // freq_addr
    // dout_sel
    // counter_load_num
    
    // needn't to be registered outside:
    // dout_begin
    // dout_end
    
    wire [6:0] audio_out; // the output from counter
    
    
    
    // instantiate the frequency ROM
    wire [16:0] freq_data;
    freq_rom freq_rom (
      .a(freq_addr), // Bus [5 : 0] 
      .spo(freq_data)); // Bus [16 : 0] 

   // use 3-8 decoder to genreate counter_load signal 
   reg [6:0] counter_load; 
   always @(posedge clk)
         case (counter_load_num)
            3'b000  : counter_load <= 7'b0000001;
            3'b001  : counter_load <= 7'b0000010;
            3'b010  : counter_load <= 7'b0000100;
            3'b011  : counter_load <= 7'b0001000;
            3'b100  : counter_load <= 7'b0010000;
            3'b101  : counter_load <= 7'b0100000;
            3'b110  : counter_load <= 7'b1000000;
            3'b111  : counter_load <= 7'b0000000; //select none
            default : counter_load <= 7'b0000000;
         endcase



   // generate 7 counters
   generate 
   genvar i;
   
      for(i = 0; i<=6; i=i+1) 
      begin : counter_inst   
      audio_counter audio_counter (
          .clk(clk), 
          .preload(freq_data), 
          .counter_load(counter_load[i]), 
          .dout(audio_out[i])
          );
      end
   endgenerate


         
   // use dout_sel and dout_en to control dout
   always @(posedge clk)
      if (dout_en)
         case (dout_sel)
            3'b000: dout <= audio_out[0];
            3'b001: dout <= audio_out[1];
            3'b010: dout <= audio_out[2];
            3'b011: dout <= audio_out[3];
            3'b100: dout <= audio_out[4];
            3'b101: dout <= audio_out[5];
            3'b110: dout <= audio_out[6];
            3'b111: dout <= audio_out[0];
         endcase
      else
         dout <= 1'b0;
   



         
   endmodule
