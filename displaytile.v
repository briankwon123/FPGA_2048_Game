/////////////////////////////////////////////////
// Module to drive a single tile in the display grid
// Tile size is 105x105 pixels and is indexed from the top left
// The tiles are index from 0-3 from top left to bottom right along both axes
// The tile's background color is determined by its value
// Each tile can display 4 digits
// There are 12 pixels of padding between the edge of the tile and the numbers
// There are 32 pixels of padding between the top and the digit
// There are 31 pixels of padding between the bottom and the digits
// 3 pixels separate each digit
// Each digit is 18x42
// The digits are generated like a 7 segment display
/////////////////////////////////////////////////

`define DISP_FULL

module displaytile #(parameter XIDX=0, parameter YIDX=0) (
    input wire [9:0] hc,    //horizontal counter
    input wire [9:0] vc,    //vertical counter
    input wire [3:0] val,   //power of 2 of the tile's value
    output wire [2:0] red,	//red vga output
    output wire [2:0] green, //green vga output
    output wire [1:0] blue	//blue vga output
);
    ///////// POSITIONING LOGIC /////////
    parameter TILE_LEN = 117;   // length of one tile plus padding
    parameter OUTER_PAD = 92;   // empty space on x axis to left
    parameter TILE_PAD = 12;     // padding between digits
    parameter LEFT_PAD = 12;    // edge of tile to start of numbers
    parameter TOP_PAD = 32;     // top of tile to start of numbers
    parameter DIGIT_LEN = 21; // digit length + padding
 

    // Calculate pixel location of top left corner
    parameter xpos = OUTER_PAD + LEFT_PAD + XIDX * TILE_LEN; // start of leftmost digit
    parameter ypos = TILE_PAD + TOP_PAD + YIDX * TILE_LEN;   // top location of digits

    ///////// BACKGROUND COLOR LOGIC /////////
    // outputs from digits 
`ifdef DISP_FULL
    wire [2:0] redbase, red1, red2, red3, red4;
    wire [2:0] greenbase, green1, green2, green3, green4;
    wire [1:0] bluebase, blue1, blue2, blue3, blue4;
    wire active1, active2, active3, active4;
`else
    wire [2:0] redbase, red1, red2;
    wire [2:0] greenbase, green1, green2;
    wire [1:0] bluebase, blue1, blue2;
    wire active1, active2;
`endif

    // background color values
    reg [2:0] bgred;
    reg [2:0] bggreen;
    reg [1:0] bgblue;

    // Preset background colors
    //             value:   0     2     4     8     16    32    64   128   256   512   1024  2048  4096  8192
    reg [41:0] bgreds   = {3'd7, 3'd7, 3'd7, 3'd6, 3'd7, 3'd7, 3'd7, 3'd7, 3'd5, 3'd7, 3'd6, 3'd6, 3'd4, 3'd2};
    reg [41:0] bggreens = {3'd7, 3'd6, 3'd7, 3'd7, 3'd5, 3'd4, 3'd3, 3'd7, 3'd7, 3'd7, 3'd7, 3'd6, 3'd6, 3'd6};
    reg [28:0] bgblues  = {2'd3, 2'd3, 2'd2, 2'd2, 2'd2, 2'd1, 2'd0, 2'd0, 2'd0, 2'd1, 2'd2, 2'd2, 2'd3, 2'd1};

    // Set background color
    always @(*) begin
        case(val)
        1: begin bgred = 3'd7;
           bggreen = 3'd6;
           bgblue = 2'd2; end
        2: begin bgred = 3'd7;
           bggreen = 3'd6;
           bgblue = 2'd1; end
        3: begin bgred = 3'd7;
           bggreen = 3'd6;
           bgblue = 2'd0; end
        4: begin bgred = 3'd6;
           bggreen = 3'd5;
           bgblue = 2'd2; end
        5: begin bgred = 3'd6;
           bggreen = 3'd5;
           bgblue = 2'd1; end
        6: begin bgred = 3'd6;
           bggreen = 3'd5;
           bgblue = 2'd0; end
        7: begin bgred = 3'd5;
           bggreen = 3'd4;
           bgblue = 2'd2; end
        8: begin bgred = 3'd5;
           bggreen = 3'd4;
           bgblue = 2'd1; end
        9: begin bgred = 3'd5;
           bggreen = 3'd3;
           bgblue = 2'd1; end
        10: begin bgred = 3'd5;
           bggreen = 3'd4;
           bgblue = 2'd0; end
        11: begin bgred = 3'd4;
           bggreen = 3'd6;
           bgblue = 2'd3; end
        12: begin bgred = 3'd4;
           bggreen = 3'd4;
           bgblue = 2'd2; end
        13: begin bgred = 3'd4;
           bggreen = 3'd4;
           bgblue = 2'd1; end
        default: begin bgred = 3'd3;
           bggreen = 3'd3;
           bgblue = 2'd1; end
        endcase
    end

    // Values to send to each digit
`ifdef DISP_FULL
reg [3:0] ones, tens, hundreds, thousands;
`else
wire [3:0] ones, tens, hundreds, thousands;
`endif

    //wire [16:0] actual_val;
    //assign actual_val = val == 0 ? 0 : 1 << val;
`ifndef DISP_FULL
    assign ones      = val % 10;
    assign tens      = val > 9   ? (val % 100) / 10 : 4'b1111;
    //assign hundreds  = actual_val > 99  ? (actual_val % 1000) / 100 : 4'b1111;
    //assign thousands = actual_val > 999 ? (actual_val % 10000) / 1000 : 4'b1111;*/

`else
    always @(*) begin
       case(val)
       0: begin
          ones = 4'b1111;
          tens = 4'b1111;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       1: begin
          ones = 4'd2;
          tens = 4'b1111;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       2: begin
          ones = 4'd4;
          tens = 4'b1111;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       3: begin
          ones = 4'd8;
          tens = 4'b1111;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       4: begin
          ones = 4'd6;
          tens = 4'd1;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       5: begin
          ones = 4'd2;
          tens = 4'd3;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       6: begin
          ones = 4'd4;
          tens = 4'd6;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       7: begin
          ones = 4'd8;
          tens = 4'd2;
          hundreds = 4'd1;
          thousands = 4'b1111;
       end
       8: begin
          ones = 4'd6;
          tens = 4'd5;
          hundreds = 4'd2;
          thousands = 4'b1111;
       end
       9: begin
          ones = 4'd2;
          tens = 4'd1;
          hundreds = 4'd5;
          thousands = 4'b1111;
       end
       10: begin
          ones = 4'd4;
          tens = 4'd2;
          hundreds = 4'd0;
          thousands = 4'd1;
       end
       11: begin
          ones = 4'd8;
          tens = 4'd4;
          hundreds = 4'd0;
          thousands = 4'd2;
       end
       12: begin
          ones = 4'd6;
          tens = 4'd9;
          hundreds = 4'd0;
          thousands = 4'd4;
       end
       13: begin
          ones = 4'd2;
          tens = 4'd9;
          hundreds = 4'd1;
          thousands = 4'd8;
       end
       default: begin
          ones = 4'b1111;
          tens = 4'b1111;
          hundreds = 4'b1111;
          thousands = 4'b1111;
       end
       endcase
    end
`endif

`ifdef DISP_FULL
    displaydigit #(.XPOS(xpos), .YPOS(ypos)) d1000(
        .hc(hc),
        .vc(vc),
        .val(thousands),
        .red(red4),
        .green(green4),
        .blue(blue4),
        .active(active4)
    );
`endif

    displaydigit #(.XPOS(xpos+DIGIT_LEN), .YPOS(ypos)) d100(
        .hc(hc),
        .vc(vc),
`ifdef DISP_FULL
        .val(hundreds),
`else
        .val(tens),
`endif
        .red(red2),
        .green(green2),
        .blue(blue2),
        .active(active2)
    );

    displaydigit #(.XPOS(xpos+2*DIGIT_LEN), .YPOS(ypos)) d10(
        .hc(hc),
        .vc(vc),
`ifdef DISP_FULL
        .val(tens),
`else
        .val(ones),
`endif
        .red(red1),
        .green(green1),
        .blue(blue1),
        .active(active1)
    );
    
`ifdef DISP_FULL
    displaydigit #(.XPOS(xpos+3*DIGIT_LEN), .YPOS(ypos)) d1(
        .hc(hc),
        .vc(vc),
        .val(ones),
        .red(red3),
        .green(green3),
        .blue(blue3),
        .active(active3)
    );
`endif

    // Assign final output
    // Determine if a digit is currently driving the output
    // Assign to either background color or output from digit
    wire digitactive;
`ifdef DISP_FULL
    assign digitactive = active1 | active2 | active3 | active4;
    assign red = ~digitactive ? bgred :
                  red1 | red2 | red3 | red4;
    assign green = ~digitactive ? bggreen :
                   green1 | green2 | green3 | green4;
    assign blue = ~digitactive ? bgblue :
                  blue1 | blue2 | blue3 | blue4;
`else
    assign digitactive = active1 | active2;
    assign red = ~digitactive ? bgred : red1 | red2;
    assign green = ~digitactive ? bggreen : green1 | green2;
    assign blue = ~digitactive ? bgblue : blue1 | blue2;
`endif

endmodule 