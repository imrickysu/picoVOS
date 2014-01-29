`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:26:05 07/11/2007 
// Design Name:    picoVOS
// Module Name:    vga control 
// Target Devices: XC3S500E-5FG320 (Spartan3E Starter Kit)
// Tool versions:  ISE 9.1.03i
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module vga_ctrl(clk25, clk50,  r, g, b, vsync, hsync, vga_ram_addr, vga_ram_din, vga_ram_we,
                score_ram_addr, score_ram_we, score_reg_en,
                logo_color,logo_disp_block);
    input clk25;
    input clk50;

    
    input [11:0] vga_ram_addr;
    input [0:0] vga_ram_din;
    input vga_ram_we;
    
    output r;
    output g;
    output b;
    output vsync;
    output hsync;
    
    input [10:0] score_ram_addr;
    input score_ram_we;
    input score_reg_en;
    
    input [2:0] logo_color; // registered outside   
    input [2:0] logo_disp_block;   
  

    reg  r, g, b;
    wire r_i, g_i, b_i; //internal rgb signal

    wire vsync;
    wire hsync;
	 
    //for vga ram
	 wire [0:0] doutA ;
    wire [11:0] addrA;



    

	 wire [9:0] hcount; //640 --> 1024, 10-bit
    wire [8:0] vcount; //480 --> 512, 9-bit
    wire clk25; //25M DCM input

//VGA Time signal Generation    
//640x480

vgatime vga_time_gen (
    .tc_hsblnk(11'd639), 
    .tc_hssync(11'd655), 
    .tc_hesync(11'd751), 
    .tc_heblnk(11'd799), 
    .hcount(hcount), 
    .hsync(hsync), 
    .hblnk(hblnk), 
    .tc_vsblnk(11'd479), 
    .tc_vssync(11'd488), 
    .tc_vesync(11'd490), 
    .tc_veblnk(11'd519), 
    .vcount(vcount), 
    .vsync(vsync), 
    .vblnk(vblnk), 
    .clk(clk25)
    );
	


    
// *****************
// VGA frame buffer
// Port A Write only  --> PicoBlaze 
// Post B Read only --> VGA Control
// *****************

vga_ram vga_ram (
	.addrb(addrA), // 
	.addra(vga_ram_addr), // 9bit row, 5 bit column
	.clkb(clk25),
	.clka(clk50),
	.dina(vga_ram_din), //
	.doutb(doutA), //
	.wea(vga_ram_we));
   
   
   
//***********************
// Score RAM
// Fucntion: Store score vga frame buffer and font data
// PortA: 2048x8bit 
// ADDRA: [3:0] - row of digit
//        [7:4] - Choose which digit to move
//        [10:7] - Null
//
// PortB: 16k x 1bit
// ADDRB: [2:0] - column of digit
//        [6:3] - row of digit
//        [8:7] - Choose which digit to display
//        [13:9] - Null
//   
//***********************   
wire [13:0] score_disp_addr;
wire score_disp_dout;
reg [7:0]score_ram_data; // buffer from dout to din

wire [7:0] score_ram_din;
wire [7:0] score_ram_dout;

score_ram score_ram0 (
	.clka(clk50),
	.dina(score_ram_din), // Bus [7 : 0] 
	.addra(score_ram_addr), // Bus [10 : 0] 
	.wea(score_ram_we), // Bus [0 : 0] 
	.douta(score_ram_dout), // Bus [7 : 0] 
	.clkb(clk25),
	.dinb(1'b0), // Bus [0 : 0] 
	.addrb(score_disp_addr), // Bus [13 : 0] 
	.web(1'b0), // Bus [0 : 0] 
	.doutb(score_disp_dout)); // Bus [0 : 0]   

// connect score_ram_dout and score_ram_din with
// internal buffer register score_ram_data   
always @(posedge clk50)
begin
   if (score_reg_en)
      score_ram_data <= score_ram_dout;
   else
      score_ram_data <= score_ram_data;   
end   
assign score_ram_din = score_ram_data;   
   

//***********************
// Logo RAM -- 128 x 64 dots
// Fucntion: Store picoVOS logo, usage, 
//           HIT, Cool, Miss pic
// PortA: 1536(1.5k) x32bit 
// ADDRA: [1:0] - 4 x 32bit to complete a line of 128bits
//        [7:1] - row number (64 rows)
//        [10:8] - Choose the block
//
// PortB: 49152(48k) x 1bit
// ADDRB: [6:0] - 128 bits complete a line
//        [12:7] - row number
//        [15:13] - always zero because it only display the first block
//   
//*********************** 


wire [16:0] logo_disp_addr;
wire logo_disp_dout;

wire logo_disp_dout_r, logo_disp_dout_g, logo_disp_dout_b;

logo_ram logo_ram0 (
	.clka(clk50),
	.dina(32'b0), // Bus [31 : 0] 
	.addra(11'b0), // Bus [10 : 0] 
	.wea(1'b0), // Bus [0 : 0] 
	.douta(), // Bus [31 : 0] 
	.clkb(clk25),
	.dinb(1'b0), // Bus [0 : 0] 
	.addrb(logo_disp_addr), // Bus [15 : 0] 
	.web(1'b0), // Bus [0 : 0] 
	.doutb(logo_disp_dout)); // Bus [0 : 0] 


// Give different color for different block
// invert logo_disp_dout because bmp data background is 1
assign logo_disp_dout_r = logo_color[2] ? ~logo_disp_dout : 1'b0;
assign logo_disp_dout_g = logo_color[1] ? ~logo_disp_dout : 1'b0;
assign logo_disp_dout_b = logo_color[0] ? ~logo_disp_dout : 1'b0;

// invert row
wire [5:0] logo_addr_vcount;

assign logo_addr_vcount = ~vcount[5:0];

wire [6:0] logo_addr_hcount;
assign logo_addr_hcount[6:5] = hcount[6:5]-2;
assign logo_addr_hcount[4:0] = ~hcount[4:0];
assign logo_disp_addr = {logo_disp_block,      logo_addr_vcount,   logo_addr_hcount};
//                      [15:13]block           [12:7]row           [6:0]column







   

wire blank;
assign blank = hblnk | vblnk;

//******************
//RGB=111 -> White
//RGB=000 -> Black
//******************
always @(posedge clk25)
begin
	r <= blank ? 1'b0 : r_i;
	g <= blank ? 1'b0 : g_i;
	b <= blank ? 1'b0 : b_i;
end	


// Display the content in memory in the middle of the screen
// Pixel 128-383
//wire [2:0] haddr; // horizon address for BRAM address
//assign haddr = hcount[7:5];


//assign addrA = (hcount > 127 && hcount < 384) ? {vcount[8:0],haddr} : 0 ;
assign addrA = (hcount[9:5]==5'b00100) ? {vcount,3'b000} :
               (hcount[9:5]==5'b00101) ? {vcount,3'b001} :
               (hcount[9:5]==5'b00110) ? {vcount,3'b010} :
               (hcount[9:5]==5'b00111) ? {vcount,3'b011} :
               (hcount[9:5]==5'b01000) ? {vcount,3'b100} :
               (hcount[9:5]==5'b01001) ? {vcount,3'b101} :
               (hcount[9:5]==5'b01010) ? {vcount,3'b110} : 0 ;
               
               
assign score_disp_addr = {5'b00000,hcount[4:3],vcount[3:0],hcount[2:0]};      //14bit      
//                                 digit-2bit   row-4bit    column-3bit
               
assign r_i = (hcount == 10'b0010000000 || hcount == 10'b0010100000 || hcount == 10'b0011000000 ||
              hcount == 10'b0011100000 || hcount == 10'b0100000000 || hcount == 10'b0100100000 ||
              hcount == 10'b0101000000 || hcount == 10'b0101100000 || //8 vertical lines
             (vcount[8:1] == 8'b11010010 && (hcount > 128 && hcount < 352)) ) ? 1'b1 : //horizon line
             
             (hcount > 128 && hcount < 160) ? 1'b0 :   // center key dropping area
             (hcount > 160 && hcount < 192) ? 1'b0 : 
             (hcount > 192 && hcount < 224) ? 1'b0 : 
             (hcount > 224 && hcount < 256) ? 1'b0:
             (hcount > 256 && hcount < 288) ? 1'b0 : 
             (hcount > 288 && hcount < 320) ? 1'b0 : 
             (hcount > 320 && hcount < 352) ? 1'b0 : 
             
             (hcount > 480 && hcount < 513  && vcount[8:4] == 5'b11100) ? score_disp_dout: //score area
             
             // LOGO area
             (hcount > 448 && hcount < 577  && vcount[8:6] == 3'b010) ? logo_disp_dout_r: 
             
             
              1'b0;
assign g_i = (hcount == 10'b0010000000 || hcount == 10'b0010100000 || hcount == 10'b0011000000 ||
              hcount == 10'b0011100000 || hcount == 10'b0100000000 || hcount == 10'b0100100000 ||
              hcount == 10'b0101000000 || hcount == 10'b0101100000 ||
             (vcount[8:1] == 8'b11010010 && (hcount > 128 && hcount < 352)) ) ? 1'b1 :
             
             (hcount > 128 && hcount < 160) ? 1'b0 :   // center key dropping area
             (hcount > 160 && hcount < 192) ? 1'b0 :
             (hcount > 192 && hcount < 224) ? 1'b0 :
             (hcount > 224 && hcount < 256) ? doutA :
             (hcount > 256 && hcount < 288) ? 1'b0 :
             (hcount > 288 && hcount < 320) ? 1'b0 :
             (hcount > 320 && hcount < 352) ? 1'b0 :
             
             (hcount > 480 && hcount < 513  && vcount[8:4] == 5'b11100) ? score_disp_dout: //score area
             
             // LOGO area
             (hcount > 448 && hcount < 577  && vcount[8:6] == 3'b010) ? logo_disp_dout_g: 
             
             1'b0;
assign b_i = (hcount == 10'b0010000000 || hcount == 10'b0010100000 || hcount == 10'b0011000000 ||
              hcount == 10'b0011100000 || hcount == 10'b0100000000 || hcount == 10'b0100100000 ||
              hcount == 10'b0101000000 || hcount == 10'b0101100000 ||
             (vcount[8:1] == 8'b11010010 && (hcount > 128 && hcount < 352)) ) ? 1'b1 :
             
             (hcount > 128 && hcount < 160) ? doutA :   // center key dropping area
             (hcount > 160 && hcount < 192) ? doutA :
             (hcount > 192 && hcount < 224) ? doutA :
             (hcount > 224 && hcount < 256) ? 1'b0 :
             (hcount > 256 && hcount < 288) ? doutA :
             (hcount > 288 && hcount < 320) ? doutA :
             (hcount > 320 && hcount < 352) ? doutA :
             
             (hcount > 480 && hcount < 513  && vcount[8:4] == 5'b11100) ? score_disp_dout: //score area
             
             // LOGO area
             (hcount > 448 && hcount < 577  && vcount[8:6] == 3'b010) ? logo_disp_dout_b: 
             
             1'b0;
// rgb_i comparator need to be bigger than addrA comparator because of the read memory latency
//assign b_i = (hcount > 127 && hcount < 384) ? 1'b1 : 1'b1;
//background = black
//item = blue   



endmodule
