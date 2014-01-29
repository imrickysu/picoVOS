`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:14:43 09/10/2007 
// Design Name:    picoVOS
// Module Name:    kbd_receive 
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
module kbd_receive(clk, kbd_clk, kbd_data, dataout, kbd_data_a);
    input clk;
    input kbd_clk;
    input kbd_data;
    output [7:0] dataout;
    output kbd_data_a; //data availabe

    
    //******************
    //debounce kbd_clk and find the falling edge
    //******************
    reg [7:0] debounce_reg; // the debounce shift register
    reg kbd_clk_fall;
    always @(posedge clk)
    begin
      debounce_reg[6:0] <= debounce_reg[7:1];
      debounce_reg[7] <= kbd_clk;    
    end
    
    always @ (posedge clk)
    begin
      if (debounce_reg == 8'b00001111)
         kbd_clk_fall <= 1'b1;
      else
         kbd_clk_fall <= 1'b0;      
    end
    
    
    //**************
    // trig kbd_data
    //**************
    reg kbd_data_i; //the trigged internal kbd data
    always @(posedge clk)
    begin
      if (kbd_clk_fall) //enable signal
         kbd_data_i <= kbd_data;
      else
         kbd_data_i <= kbd_data_i; 
    end
    
    
    //*********
    //trig FSM
    //*********
   parameter idle = 5'b00001;
   parameter start_trig = 5'b00010;
   parameter trig = 5'b00100;
   parameter check_parity = 5'b01000;
   parameter waitone = 5'b10000;
   
   reg [3:0] counter = 4'b0000;
   reg [7:0] kbd_data_p; //parallel kbd data
   reg data_a; //data available

   (* FSM_ENCODING="ONE-HOT", SAFE_IMPLEMENTATION="NO" *) reg [4:0] state = idle;

   always@(posedge clk)
        case (state)
            idle : begin
// 2007.10.10 Keyboard bug, replaced with if (kbd_clk_fall)            
//               if (kbd_data_i == 1'b0)
               if (kbd_clk_fall)
                  state <= start_trig;
               else
                  state <= idle;
            end
            start_trig : begin
               if (kbd_clk_fall)
                  if (counter == 4'b1000)
                     state <= check_parity;
                  else   
                     state <= trig;
               else
                  state <= start_trig;
            end
            trig : 
                  state <= start_trig;
            check_parity : 
               state <= waitone;
            waitone:
               if (kbd_clk_fall)
                  state <= idle;

         endcase
   
   
   //FSM Output
   always @(posedge clk)
   begin
      if (state == trig)
      begin
         kbd_data_p[6:0] <= kbd_data_p[7:1];
         kbd_data_p[7] <= kbd_data_i;
         counter <= counter + 1;
         data_a <= 1'b0;
      end
      
      //Check Parity state
      //But doesn't do check parity
      //Just skip the parity bit
      //Tested on Dell keyboard, 100% accruaticy
      else if (state == check_parity)
      begin 
         data_a <= 1'b1;
         kbd_data_p <= kbd_data_p;
         counter <= 4'b0000;
      end 
      
      else if (state == start_trig)
      begin
         kbd_data_p <= kbd_data_p;
         counter <= counter;
         data_a <= 1'b0;
      end
      
      else begin
         kbd_data_p <= kbd_data_p;
         counter <= 4'b0000;
         data_a <= 1'b0;
      end   
   end
   

   
   
   assign dataout = kbd_data_p;
   assign kbd_data_a = data_a;
   
   


endmodule
