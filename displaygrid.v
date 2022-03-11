//////////////////////////////////////////////////////////////////////////////////
// 4x4 Grid to display the 2048 game
// Instantiates 16 tiles corresponding to each cell in the board
//////////////////////////////////////////////////////////////////////////////////
module displaygrid(
	input wire dclk,		//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input wire [63:0] vals, //values of each tile as the power of 2
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
);

	// video structure constants
	parameter hpixels = 800;// horizontal pixels per line
	parameter vlines = 521; // vertical lines per frame
	parameter hpulse = 96; 	// hsync pulse length
	parameter vpulse = 2; 	// vsync pulse length
	parameter hbp = 144; 	// end of horizontal back porch
	parameter hfp = 784; 	// beginning of horizontal front porch
	parameter vbp = 31; 		// end of vertical back porch
	parameter vfp = 511; 	// beginning of vertical front porch
	// active horizontal video is therefore: 784 - 144 = 640
	// active vertical video is therefore: 511 - 31 = 480

	// Grid area is 480 x 480
	// Spacing between tiles is 12 pixels
	// Each tile is (480 - 5*12) / 4 = 105 x 105 pixels
	// Grid begins at x = 80
	parameter TILE_LEN = 117; // tile length plus padding
	parameter TILE_PAD = 12;
	parameter XPAD = 92; // x padding plus padding around border

	// registers for storing the horizontal & vertical counters
	reg [9:0] hc;
	reg [9:0] vc;
    
    // horizontal and vertical counters with porches subtracted
    wire [9:0] hc_norm;
    wire [9:0] vc_norm;
    assign hc_norm = hc - hbp;
    assign vc_norm = vc - vbp;

	// Horizontal & vertical counters --
	// this is how we keep track of where we are on the screen.
	// ------------------------
	// Sequential "always block", which is a block that is
	// only triggered on signal transitions or "edges".
	// posedge = rising edge  &  negedge = falling edge
	// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
	always @(posedge dclk or posedge clr)
	begin
		// reset condition
		if (clr == 1)
		begin
			hc <= 0;
			vc <= 0;
		end
		else
		begin
			// keep counting until the end of the line
			if (hc < hpixels - 1)
				hc <= hc + 1;
			else
			// When we hit the end of the line, reset the horizontal
			// counter and increment the vertical counter.
			// If vertical counter is at the end of the frame, then
			// reset that one too.
			begin
				hc <= 0;
				if (vc < vlines - 1)
					vc <= vc + 1;
				else
					vc <= 0;
			end
			
		end
	end

	// generate sync pulses (active low)
	// ----------------
	// "assign" statements are a quick way to
	// give values to variables of type: wire
	assign hsync = (hc < hpulse) ? 0:1;
	assign vsync = (vc < vpulse) ? 0:1;

	// display the tiles
	// ------------------------
	// Combinational "always block", which is a block that is
	// triggered when anything in the "sensitivity list" changes.
	// The asterisk implies that everything that is capable of triggering the block
	// is automatically included in the sensitivty list.  In this case, it would be
	// equivalent to the following: always @(hc, vc)
	// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =

	// Output values from each tile
	wire [47:0] reds;
	wire [47:0] greens;
	wire [31:0] blues;

	always @(*) begin
		// first check if we're within vertical active video range
		if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp) begin
			// Go through each tile and assign output to correct tile
			// Tiles are numbered left to right, top to bottom
			if (hc_norm >= XPAD && hc_norm < XPAD+TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD && vc_norm < TILE_LEN) begin // top left
				red = reds[2:0];
				green = greens[2:0];
				blue = blues[1:0];
			end else if (hc_norm >= XPAD+TILE_LEN &&hc_norm < XPAD+2*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD && vc_norm < TILE_LEN) begin
				red = reds[5:3];
				green = greens[5:3];
				blue = blues[3:2];
			end else if (hc_norm >= XPAD+2*TILE_LEN && hc_norm < XPAD+3*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD && vc_norm < TILE_LEN) begin
				red = reds[8:6];
				green = greens[8:6];
				blue = blues[5:4];
			end else if (hc_norm >= XPAD+3*TILE_LEN && hc_norm < XPAD+4*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD && vc_norm < TILE_LEN) begin
				red = reds[11:9];
				green = greens[11:9];
				blue = blues[7:6];
			end 
			// END ROW 0
			else if (hc_norm >= XPAD && hc_norm < XPAD+TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+TILE_LEN && vc_norm < 2*TILE_LEN) begin
				red = reds[14:12];
				green = greens[14:12];
				blue = blues[9:8];
			end else if (hc_norm >= XPAD+TILE_LEN && hc_norm < XPAD+2*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+TILE_LEN && vc_norm < 2*TILE_LEN) begin
				red = reds[17:15];
				green = greens[17:15];
				blue = blues[11:10];
			end else if (hc_norm >= XPAD+2*TILE_LEN && hc_norm < XPAD+3*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+TILE_LEN && vc_norm < 2*TILE_LEN) begin
				red = reds[20:18];
				green = greens[20:18];
				blue = blues[13:12];
			end else if (hc_norm >= XPAD+3*TILE_LEN && hc_norm < XPAD+4*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+TILE_LEN && vc_norm < 2*TILE_LEN) begin
				red = reds[23:21];
				green = greens[23:21];
				blue = blues[15:14];
			end
			// END ROW 1
			else if (hc_norm >= XPAD && hc_norm < XPAD+TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+2*TILE_LEN && vc_norm < 3*TILE_LEN) begin
				red = reds[26:24];
				green = greens[26:24];
				blue = blues[17:16];
			end else if (hc_norm >= XPAD+TILE_LEN && hc_norm < XPAD+2*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+2*TILE_LEN && vc_norm < 3*TILE_LEN) begin
				red = reds[29:27];
				green = greens[29:27];
				blue = blues[19:18];
			end else if (hc_norm >= XPAD+2*TILE_LEN && hc_norm < XPAD+3*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+2*TILE_LEN && vc_norm < 3*TILE_LEN) begin
				red = reds[32:30];
				green = greens[32:30];
				blue = blues[21:20];
			end else if (hc_norm >= XPAD+3*TILE_LEN && hc_norm < XPAD+4*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+2*TILE_LEN && vc_norm < 3*TILE_LEN) begin
				red = reds[35:33];
				green = greens[35:33];
				blue = blues[23:22];
			end
			// END ROW 2
			else if (hc_norm >= XPAD && hc_norm < XPAD+TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+3*TILE_LEN && vc_norm < 4*TILE_LEN) begin
				red = reds[38:36];
				green = greens[38:36];
				blue = blues[25:24];
			end else if (hc_norm >= XPAD+TILE_LEN && hc_norm < XPAD+2*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+3*TILE_LEN && vc_norm < 4*TILE_LEN) begin
				red = reds[41:39];
				green = greens[41:39];
				blue = blues[27:26];
			end else if (hc_norm >= XPAD+2*TILE_LEN && hc_norm < XPAD+3*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+3*TILE_LEN && vc_norm < 4*TILE_LEN) begin
				red = reds[44:42];
				green = greens[44:42];
				blue = blues[29:28];
			end else if (hc_norm >= XPAD+3*TILE_LEN && hc_norm < XPAD+4*TILE_LEN-TILE_PAD && vc_norm >= TILE_PAD+3*TILE_LEN && vc_norm < 4*TILE_LEN) begin
				red = reds[47:45];
				green = greens[47:45];
				blue = blues[31:30];
			end else begin // set to background color
				red = 3'd5;
				green = 3'd5;
				blue = 2'd2;
			end
		end
		// outside active range so display black
		else begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// Create all 16 tiles
	displaytile #(.XIDX(0), .YIDX(0)) t0(.hc(hc_norm), .vc(vc_norm), .val(vals[3:0]), .red(reds[2:0]), .green(greens[2:0]), .blue(blues[1:0]));
	displaytile #(.XIDX(1), .YIDX(0)) t1(.hc(hc_norm), .vc(vc_norm), .val(vals[7:4]), .red(reds[5:3]), .green(greens[5:3]), .blue(blues[3:2]));
	displaytile #(.XIDX(2), .YIDX(0)) t2(.hc(hc_norm), .vc(vc_norm), .val(vals[11:8]), .red(reds[8:6]), .green(greens[8:6]), .blue(blues[5:4]));
	displaytile #(.XIDX(3), .YIDX(0)) t3(.hc(hc_norm), .vc(vc_norm), .val(vals[15:12]), .red(reds[11:9]), .green(greens[11:9]), .blue(blues[7:6]));
	displaytile #(.XIDX(0), .YIDX(1)) t4(.hc(hc_norm), .vc(vc_norm), .val(vals[19:16]), .red(reds[14:12]), .green(greens[14:12]), .blue(blues[9:8]));
	displaytile #(.XIDX(1), .YIDX(1)) t5(.hc(hc_norm), .vc(vc_norm), .val(vals[23:20]), .red(reds[17:15]), .green(greens[17:15]), .blue(blues[11:10]));
	displaytile #(.XIDX(2), .YIDX(1)) t6(.hc(hc_norm), .vc(vc_norm), .val(vals[27:24]), .red(reds[20:18]), .green(greens[20:18]), .blue(blues[13:12]));
	displaytile #(.XIDX(3), .YIDX(1)) t7(.hc(hc_norm), .vc(vc_norm), .val(vals[31:28]), .red(reds[23:21]), .green(greens[23:21]), .blue(blues[15:14]));
	displaytile #(.XIDX(0), .YIDX(2)) t8(.hc(hc_norm), .vc(vc_norm), .val(vals[35:32]), .red(reds[26:24]), .green(greens[26:24]), .blue(blues[17:16]));
	displaytile #(.XIDX(1), .YIDX(2)) t9(.hc(hc_norm), .vc(vc_norm), .val(vals[39:36]), .red(reds[29:27]), .green(greens[29:27]), .blue(blues[19:18]));
	displaytile #(.XIDX(2), .YIDX(2)) t10(.hc(hc_norm), .vc(vc_norm), .val(vals[43:40]), .red(reds[32:30]), .green(greens[32:30]), .blue(blues[21:20]));
	displaytile #(.XIDX(3), .YIDX(2)) t11(.hc(hc_norm), .vc(vc_norm), .val(vals[47:44]), .red(reds[35:33]), .green(greens[35:33]), .blue(blues[23:22]));
	displaytile #(.XIDX(0), .YIDX(3)) t12(.hc(hc_norm), .vc(vc_norm), .val(vals[51:48]), .red(reds[38:36]), .green(greens[38:36]), .blue(blues[25:24]));
	displaytile #(.XIDX(1), .YIDX(3)) t13(.hc(hc_norm), .vc(vc_norm), .val(vals[55:52]), .red(reds[41:39]), .green(greens[41:39]), .blue(blues[27:26]));
	displaytile #(.XIDX(2), .YIDX(3)) t14(.hc(hc_norm), .vc(vc_norm), .val(vals[59:56]), .red(reds[44:42]), .green(greens[44:42]), .blue(blues[29:28]));
	displaytile #(.XIDX(3), .YIDX(3)) t15(.hc(hc_norm), .vc(vc_norm), .val(vals[63:60]), .red(reds[47:45]), .green(greens[47:45]), .blue(blues[31:30]));

endmodule
