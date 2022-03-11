`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:48:38 03/07/2022 
// Design Name: 
// Module Name:    movement_tb 
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
module movement_tb(
    );
	
	reg up, down, left, right, rst, enable;
	reg [63:0] inTilevals;
	wire [63:0] outTilevals; //Exponent of the values
	
	movement UUT(.up(up),.down(down),.left(left),.right(right),.rst(rst),.enable(enable),.inTilevals(inTilevals),.outTilevals(outTilevals));
	
	initial begin
		inTilevals = {4'd0,4'd0,4'd0,4'd0,
							4'd1,4'd0,4'd0,4'd0,
							4'd0,4'd1,4'd0,4'd0,
							4'd0,4'd0,4'd1,4'd0
							};
		#10;
		up = 1;
		#10;
		up=0;
		#50;
		inTilevals = {4'd1,4'd1,4'd0,4'd1,
					4'd0,4'd0,4'd1,4'd0,
					4'd1,4'd2,4'd0,4'd0,
					4'd1,4'd0,4'd1,4'd1
					};
		#10;
		up=1;
		
	end
	
	

endmodule
