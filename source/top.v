`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Xilinx
// Engineer: Ricky Su
// 
// Create Date:    11:07:56 07/20/2007 
// Design Name:    picoVOS
// Module Name:    Top 
// Target Devices: XC3S700AN-4FG484 (Spartan3AN Starter Kit)
// Tool versions:  ISE 10.1.02i
// Description: 
//      This Design is a clone of the game VOS - Virtual Orchestra Studio.
//      Keys drop from top of the screen, when they reach the horizon line, 
//      Player hit the keyboard and the game will generate sound.
//      If the player hit all the keys in time, the sound will become music.
//
// Dependencies: 
//      KCPSM3 by Ken Chapman at www.xilinx.com/picoblaze
//
// Revision: 1.0 - Initial Release
//                 Tool version: ISE 9.1.03i
//                 Target board: Spartan 3E Starter Kit
//           2.0 - RevUp to ISE 10.1 SP3, upgrade cores
//                 Target to Spartan3AN Starter Kit
//                 Dump RGB signals to work with SP3AN Kit
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
// Disclaimer: 
// LIMITED WARRANTY AND DISCLAIMER. These designs are
// provided to you "as is". Xilinx Technical Support doesn't provide
// support of this project. Xilinx and its licensors make and you
// receive no warranties or conditions, express, implied,
// statutory or otherwise, and Xilinx specifically disclaims any
// implied warranties of merchantability, non-infringement, or
// fitness for a particular purpose. Xilinx does not warrant that
// the functions contained in these designs will meet your
// requirements, or that the operation of these designs will be
// uninterrupted or error free, or that defects in the Designs
// will be corrected. Furthermore, Xilinx does not warrant or
// make any representations regarding use or the results of the
// use of the designs in terms of correctness, accuracy,
// reliability, or otherwise.
//
// LIMITATION OF LIABILITY. In no event will Xilinx or its
// licensors be liable for any loss of data, lost profits, cost
// or procurement of substitute goods or services, or for any
// special, incidental, consequential, or indirect damages
// arising from the use or operation of the designs or
// accompanying documentation, however caused and on any theory
// of liability. This limitation will apply even if Xilinx
// has been advised of the possibility of such damage. This
// limitation shall apply not-withstanding the failure of the 
// essential purpose of any limited remedies herein. 
//////////////////////////////////////////////////////////////////////////////////
module top(clk, rst, hsync, vsync, r, g, b, tx, kbd_clk, kbd_data, audio_out);
    input clk;
    input rst;
    output  hsync, vsync;
    output [3:0] r;
    output [3:0] g;
    output [3:0] b;
    output tx;
    input kbd_clk;
    input kbd_data;
    output audio_out;

    //input clock - clk - 50M
    //clk25 -25M
    //clk50 - 50M
    wire clk25, clk50;
    wire rst;
   
   //PicoBlaze Wires
   wire  [7:0] port_id;
   wire   	write_strobe;
   wire   	read_strobe;
   wire  [7:0] out_port;
   reg  [7:0] in_port;
   reg   	interrupt = 1'b0;
   wire   	interrupt_ack;
   wire [9:0] 	address;
   wire [17:0] instruction;
   wire internal_reset;
   
   reg musicbox_enable;
	



  

   //PicoBlaze output MUX according to port_id
   
   //******************************************************************//
   // Implement the PicoBlaze 2 VGA RAM Write connections              //
   // port_id                                                          //
   // 01h wr = vga_addrc_port   VGA ADDR Column (0-6)                  //
   // 02h wr = vga_addrrl_port  VGA ADDR Row low                       //
   // 04h wr = vga_addrrh_port  VGA ADDR Row high                      //
   // 08h wr = vga_ram_din_port                                        //
   // 0Fh wr = vga_we_port    WE signal can use wire, not register     //        
   //******************************************************************//

   //PicoBlaze output MUX wires - VGA RAM
   reg [11:0] vga_ram_addr_reg;
   reg [0:0] vga_ram_din_reg;
   wire [11:0] vga_ram_addr;
   wire [0:0] vga_ram_din;
   wire vga_ram_we;
   
   // VGA RAM connections to PicoBlaze
   always @(posedge clk50)
   begin
      if (write_strobe)
      begin
         if (port_id == 8'h01) vga_ram_addr_reg[2:0] <= out_port[2:0]; //vga_addrc
         if (port_id == 8'h02) vga_ram_addr_reg[3] <= out_port[0];  //vga_addrrl
         if (port_id == 8'h04) vga_ram_addr_reg[11:4] <= out_port;  //vga_addrrh
         if (port_id == 8'h08) vga_ram_din_reg <= out_port[0];
      end
   end
   assign vga_ram_we = write_strobe && port_id==8'h0F ;
   assign vga_ram_din = vga_ram_din_reg;
   assign vga_ram_addr = vga_ram_addr_reg;
   
   
   
   //******************************************************************//
   // Implement the PicoBlaze 2 LOGO RAM Write connections             //
   // port_id                                                          //
   // 40h wr = score_row_port       [3:0] Select ROW                   //
   // 41h wr = score_digit_port     [3:0] Select Digit                 //
   // 42h wr = score_reg_en_port    use PortID and wr_strobe to enable reg_en
   // 43h wr = score_we_port        Use PortID and wr_strobe to enable RAM WE
   //******************************************************************//  
   
   // PicoBlaze output Mux wires - score RAM
   reg [7:0] score_ram_addr_reg ; //[2:0] select row [6:3] select digit
   wire [10:0] score_ram_addr;
   
   wire score_ram_we;
   wire score_reg_en;  // enable buffer register to read in
   
   // Score RAM connections to PicoBlaze
   always @(posedge clk50)
   begin
      if (write_strobe)
      begin
         if (port_id == 8'h40) score_ram_addr_reg[3:0] <= out_port[3:0]; //row
         if (port_id == 8'h41) score_ram_addr_reg[7:4] <= out_port[3:0]; //digit
      end
   end
   assign score_ram_we = write_strobe && port_id==8'h43 ;
   assign score_reg_en = write_strobe && port_id == 8'h42;
   assign score_ram_addr = {4'b000, score_ram_addr_reg};
   
 
   
   //******************************************************************//
   // Implement the PicoBlaze 2 Score RAM Write connections            //
   // port_id                                                          //
   // 70h wr = logo_color_port
   // 71h wr = logo_disp_block_port
   //******************************************************************//
   
   reg [2:0] logo_color; 
   reg [2:0] logo_disp_block;
   
   always @(posedge clk50)
   begin
      if (write_strobe)
      begin
         if (port_id == 8'h70) logo_color <= out_port[2:0];
         if (port_id == 8'h71) logo_disp_block <= out_port[2:0];
      end
   end

   
   
   
   
   
   //***********************************
   // Instantiate of VGA Control module
   //***********************************
	
	// dump rgb signals
	wire red, green, blue; 
	
   vga_ctrl vga_ctrl0 (
       .clk25(clk25), 
       .clk50(clk50),
       .vga_ram_addr(vga_ram_addr),
       .vga_ram_din(vga_ram_din),
       .vga_ram_we(vga_ram_we),
       .r(red), 
       .g(green), 
       .b(blue), 
       .vsync(vsync), 
       .hsync(hsync),
       .score_ram_addr(score_ram_addr),
       .score_ram_we(score_ram_we),
       .score_reg_en(score_reg_en),
       .logo_color(logo_color),
       .logo_disp_block(logo_disp_block)
       );
       
   assign r = {4{red}};
   assign g = {4{green}};
   assign b = {4{blue}};
   
       


   //*****************
   //PicoBlaze
   //*****************

   //PicoBlaze Processor
  	kcpsm3 processor
	(	.address(address),
    	.instruction(instruction),
		.port_id(port_id),
    	.write_strobe(write_strobe),
    	.out_port(out_port),
    	.read_strobe(read_strobe),
    	.in_port(in_port),
    	.interrupt(interrupt),
    	.interrupt_ack(interrupt_ack),
    	.reset(internal_reset | rst),
    	.clk(clk50));

   //PicoBlaze Instruction ROM
  	vos program
 	(	.address(address),
    	.instruction(instruction),
    	.clk(clk50)); 


   // interrupt module
   wire resync_vsync;
   wire interrupt_request;
   wire vsync_pluse;
	reg resync_vsync_delay;
   synchro #(.INITIALIZE("LOGIC0"))
   synchro_vsync (.async(vsync),.sync(resync_vsync),.clk(clk50));
   // interrupt_request is a pluse of the rising edge of vsync
   always @(posedge clk50) resync_vsync_delay <= resync_vsync;
   assign interrupt_request = resync_vsync & !resync_vsync_delay;
	// vsync_pluse is used for musicbox counter
   assign vsync_pluse = resync_vsync & !resync_vsync_delay;
	
	
   always @(posedge clk50)
   begin
      if (interrupt_request) interrupt <= 1'b1;
      else if (interrupt_ack) interrupt <= 1'b0;
      else interrupt <= interrupt;
   end   
   

       
   dcm1 clock_generator (
       .CLKIN_IN(clk), 
       .RST_IN(rst), 
       .CLKDV_OUT(clk25), //25M
       .CLKIN_IBUFG_OUT(clk50), //50M
       .CLK0_OUT(), 
       .LOCKED_OUT()
       ); 
       
   //*****************
   // UART
   //*****************
   reg [9:0] 	baud_count;
   reg  		en_16_x_baud;
   reg  	write_to_uart;
   reg [7:0] uart_txdata;
   
   uart_tx transmit
   (	.data_in(uart_txdata),
    	.write_buffer(write_to_uart),
    	.reset_buffer(1'b0),
    	.en_16_x_baud(en_16_x_baud),
    	.serial_out(tx),
    	.buffer_full(),
    	.buffer_half_full(),
    	.clk(clk50));
    
   always @(posedge clk50)
   begin
      write_to_uart <= 1'b0;
      if (write_strobe)
      begin
         if (port_id == 8'hF0) begin
            uart_txdata <= out_port; 
            write_to_uart <= 1'b1;
         end   
         else begin
            uart_txdata <= uart_txdata;
            write_to_uart <= 1'b0;
         end            
      end
   end  

   // Set baud rate to 9600 for the UART communications 
   // Requires en_16_x_baud to be 153600Hz which is a single cycle pulse every 325 cycles at 50MHz 
   //
   // NOTE : If the highest value for baud_count exceeds 127 you will need to adjust 
   //        the width in the reg declaration for baud_count.
  always @(posedge clk50) begin
      if (baud_count == 324) begin
         baud_count <= 1'b0;
         en_16_x_baud <= 1'b1;
		end
      else begin
         baud_count <= baud_count + 1;
         en_16_x_baud <= 1'b0;
      end
    end   
    
    
    
    //***************************
    //keyboard control module
    // port_id                                                    
    // 10h rd = kbd2pico_count
    // 11h wr = kbd2pico_data (generate a read pluse)    
    // 11h rd = kbd2pico_data               
    //***************************
    
    //keyboard wires
    wire [3:0] kbd2pico_count;
    wire [7:0] kbd2pico_data;
    wire kbd2pico_rden;
    
    kbd keyboard_control (
    .clk(clk50), 
    .kbd_clk(kbd_clk), 
    .kbd_data(kbd_data), 
    .kbd2pico_rden(kbd2pico_rden), 
    .kbd2pico_count(kbd2pico_count), 
    .kbd2pico_data(kbd2pico_data)
    );

   
   assign kbd2pico_rden = write_strobe && (port_id == 8'h11) ;
   
   
   //**************************
   // Reset Picoblaze
	//**************************
	assign internal_reset = write_strobe && (port_id == 8'h30);
   
	//**************************
	// Music box
	// port id
	// 20h rd = musicbox_data
   // 21h wr = musicbox_enable
   // 22h wr = musicbox_reset
	//**************************
	wire [7:0] musicbox_data;
   wire musicbox_reset;
   
	musicbox musicbox (
    .clk(clk50), 
    .reset(rst | internal_reset | musicbox_reset), 
    .enable(musicbox_enable),
    .vsync(vsync_pluse), 
    .data(musicbox_data)
    );

   always @(posedge clk50)
   begin
      if (write_strobe)
      begin
         if (port_id == 8'h21) musicbox_enable <= out_port[0]; 
      end
   end   
   
   assign musicbox_reset = write_strobe && (port_id == 8'h22);

   //***********************************
   // Store Speed data outside PicoBlaze
   //***********************************   
   reg [3:0] vos_speed = 4'd2;
   always @(posedge clk50)
   begin
      if (write_strobe)
         if (port_id == 8'h60) vos_speed <= out_port[3:0];
   end




   //connect keyboard to picoblaze input 
   always @(posedge clk50) begin
      case(port_id)
         8'h10 : 
            in_port <= {4'b0000, kbd2pico_count};
         8'h11 : 
            in_port <= kbd2pico_data;
			8'h20:
				in_port <= musicbox_data;	
         8'h61:
            in_port <=  {4'b0000, vos_speed};         
      // Don't care used for all other addresses to ensure minimum logic implementation
         default : 
            in_port <= 8'b XXXXXXXX;
      endcase
   end

   //****************
   // Audio Module
   // port_id
   // 50h wr freq_addr - preload counter value to synthesize a certain frequency, 6bit
   // 51h wr counter_load_num - select which counter register to preload counter value, 3bit
   // 
   // 
   // 58h wr audio_out_en - end pulse
   // 54h wr audio_out_sel - choose which counter dout to output, 3bit
   //****************

   wire audio_out ;
   reg [5:0] freq_addr;
   reg [2:0] counter_load_num;
   reg [2:0] audio_out_sel =3'b111;
   reg audio_out_en = 1'b0;
   
   
   audio audio_generate (
       .clk(clk50), 
       .counter_load_num(counter_load_num), //3 bit
       .dout(audio_out), 
       .dout_en(audio_out_en), 
       .dout_sel(audio_out_sel), //3bit
       .freq_addr(freq_addr) //6bit
       );
     
       
   // Audio connections to PicoBlaze
   always @(posedge clk50)
   begin
      if (write_strobe)
      begin
         if (port_id == 8'h50) freq_addr <= out_port[7:2]; 
         if (port_id == 8'h51) counter_load_num <= out_port[7:5];
         if (port_id == 8'h54) audio_out_sel <= out_port[2:0];
         if (port_id == 8'h58) audio_out_en <= out_port[0];
      end
   end

   
    endmodule
