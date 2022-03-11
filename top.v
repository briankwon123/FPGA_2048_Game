`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:13 03/02/2022 
// Design Name: 
// Module Name:    top 
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
module top(
    input wire clk,			//master clock = 100MHz
    input wire RST,			//center pushbutton for reset
    input wire BTN_RIGHT,   //right-most pushbutton
    input wire BTN_LEFT,    //left-most pushbutton
    input wire BTN_TOP,     //top-most pushbutton
    input wire BTN_BOT,     //bottom-most pushbutton
    output wire [6:0] C,    //cathods ofseven-segment displays
    output wire [3:0] A,    //anodes of seven-segment displays
    output wire [2:0] red,	//red vga output - 3 bits
    output wire [2:0] green,//green vga output - 3 bits
    output wire [1:0] blue,	//blue vga output - 2 bits
    output wire hsync,		//horizontal sync out
    output wire vsync		//vertical sync out
	);

    // 7-segment clock interconnect
    wire segclk;

    // VGA display clock interconnect
    wire dclk;

    // processed reset button
    wire rst;
    wire btn_right, btn_left, btn_top, btn_bot;

    wire gen_rand, gen_active, game_over, move_en;
    assign move_en = ~gen_active & ~game_over;

    wire [63:0] moved_vals, tilevals;
    wire [15:0] score;
    wire [3:0] score1, score10, score100, score1000; // Values to drive 7-segment display
    assign score1 = score % 10;
    assign score10 = score > 9  ? (score % 100) / 10 : 4'b1111;
    assign score100 = score > 99  ? (score % 1000) / 100 : 4'b1111;
    assign score1000 = score > 999  ? (score % 10000) / 1000 : 4'b1111;

    // generate 7-segment clock & display clock
    disp_clkdiv U1(
        .clk(clk),
        .clr(rst),
        .segclk(segclk),
        .dclk(dclk)
    );

    // Instantiate all button debouncers
    button b1(
        .clk(clk),
        .btn(RST),
        .out(rst)
    );
    
    button b2(
        .clk(clk),
        .btn(BTN_RIGHT),
        .out(btn_right)
    );
    
    button b3(
        .clk(clk),
        .btn(BTN_LEFT),
        .out(btn_left)
    );
    
    button b4(
        .clk(clk),
        .btn(BTN_TOP),
        .out(btn_top)
    );
    
    button b5(
        .clk(clk),
        .btn(BTN_BOT),
        .out(btn_bot)
    );

	 
        // Register movements
    movement U2(
        .up(btn_top),
	    .down(btn_bot),
        .left(btn_left),
        .right(btn_right),
        .rst(rst),
        .enable(move_en),
        .inTilevals(tilevals),
        .outTilevals(moved_vals)
	);
	
    // Generate random numbers
    rng U3(
        .clk(clk),
        .up(btn_top),
	    .down(btn_bot),
        .left(btn_left),
        .right(btn_right),
        .rst(rst),
        .in_vals(moved_vals),
        .out_vals(tilevals),
        .waiting(gen_active)
    );
	 

    // 7-segment display controller
    segdisplay U4(
        .clk(clk),
        .mux_clk(segclk),
        .rst(rst),
        .val1(score1000),
        .val2(score100),
        .val3(score10),
        .val4(score1),
        .C(C),
        .A(A)
    );

    // VGA controller
    displaygrid U5(
        .dclk(dclk),
        .clr(rst),
        .vals(tilevals),	//BK: changed this from moved_vals to tilevals
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );


    gamestate U6(
        .tilevals(tilevals),
        .score(score),
        .game_over(game_over)
    );

endmodule