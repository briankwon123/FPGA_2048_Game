`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 03/19/2013 
// Design Name: 
// Module Name:    clockdiv 
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
module disp_clkdiv(
	input wire clk,		//master clock: 100MHz
	input wire clr,		//asynchronous reset
	output wire dclk,	//pixel clock: 25MHz
	output wire segclk	//7-segment clock: 762.9Hz
	);

// 17-bit counter variable
reg [16:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk or posedge clr)
begin
	// reset condition
	if (clr == 1)
		q <= 0;
	// increment counter by one
	else
		q <= q + 1;
end

// 100Mhz / 2^17 = 762.9Hz
assign segclk = q == 17'd0;

// 100Mhz � 2^2 = 25MHz
assign dclk = q[1];

endmodule
