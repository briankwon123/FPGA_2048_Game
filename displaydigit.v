/////////////////////////////////////////////////
// Each digit is 18 pixels wide
// The digits are generated like a 7 segment display
// Input values of 0-9 display a value
// Other input values set to background color
// The area controlled by this digit is 18x42 pixels
/////////////////////////////////////////////////

module displaydigit #(parameter XPOS=0, parameter YPOS=0) (
    input wire [9:0] hc,        //horizontal counter
    input wire [9:0] vc,        //vertical counter
    input wire [3:0] val,       //value of the tile
    output wire [2:0] red,	    //red vga output
    output wire [2:0] green,     //green vga output
    output wire [1:0] blue,	    //blue vga output
    output wire active          //if this digit is driving output
);

    // Overall width and height
    parameter width = 18;
    parameter height = 42;

    // Deliminiters for segments
    parameter hbot = 3;         // bottom of top segment
    parameter hmidbot = 19;     // bottom of middle segment
    parameter hmidtop = 23;     // top of middle segment
    parameter hmid = 21;        // separator of side segments
    parameter htop = 39;       // bottom of top segment
    parameter wright = 15;           // right of left segments
    parameter wleft = 3;          // left of right segments
    parameter XNULL = 5'b11111; // invalid x index
    parameter YNULL = 6'b111111;

    wire [4:0] xidx;
    wire [5:0] yidx;

    // Create normalized indices for within this digit
    // If out of range, set indices to max value
    assign xidx = hc < XPOS ? XNULL :
                hc < XPOS + width ? hc - XPOS : XNULL;
    assign yidx = vc < YPOS ? YNULL :
                vc < YPOS + height ? vc - YPOS : YNULL;

    // Segments to display
    reg [6:0] segments;

    // Set segment values
    always @(*) begin
        case(val)
        0: segments = 7'b1111110;
        1: segments = 7'b0110000;
        2: segments = 7'b1101101;
        3: segments = 7'b1111001;
        4: segments = 7'b0110011;
        5: segments = 7'b1011011;
        6: segments = 7'b1011111;
        7: segments = 7'b1110000;
        8: segments = 7'b1111111;
        9: segments = 7'b1111011;
        default: segments = 7'd0000000; // off
        endcase
    end

    wire on; // denotes whether to drive output as white

    // Determine if current position corresponds to illuminated segment 
    assign active = (xidx != XNULL && yidx != YNULL) && (
                    (segments[6] && yidx < hbot) || // top segment
                    (segments[5] && xidx > wright && yidx < hmid && yidx > hbot) || // top right segment
                    (segments[4] && xidx > wright && yidx > hmid && yidx < htop) || // bottom right segment
                    (segments[3] && yidx > htop) || // bottom segment
                    (segments[2] && xidx < wleft  && yidx > hmid && yidx < htop) ||  // bottom left segment
                    (segments[1] && xidx < wleft  && yidx > hbot && yidx < hmid) ||  // top left segment
                    (segments[0] && xidx > wleft  && xidx < wright && yidx > hmidbot && yidx < hmidtop)); // middle segment

    // Assign colors module is driving output
    assign red   = active ? 3'b111 : 3'b000;
    assign green = active ? 3'b111 : 3'b000;
    assign blue  = active ? 3'b111 : 3'b000;

endmodule 