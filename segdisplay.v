/*
    Driver of 7-segment display
        val1, ..., val4 are the decimal values to display
        A is the anodes to multiplex, one for each 7-segment display
        C are the cathodes connected to all displays
*/

module segdisplay(
    input clk,
    input mux_clk,
    input rst,
    input [3:0] val1,
    input [3:0] val2,
    input [3:0] val3,
    input [3:0] val4,
    output [3:0] A,     // Anodes
    output [6:0] C      // Cathods
);

    reg [1:0] a_num;
    
    function [7:0] digit (input [3:0] val);
        begin
            case(val)
            0: digit = ~7'b1111110;
            1: digit = ~7'b0110000;
            2: digit = ~7'b1101101;
            3: digit = ~7'b1111001;
            4: digit = ~7'b0110011;
            5: digit = ~7'b1011011;
            6: digit = ~7'b1011111;
            7: digit = ~7'b1110000;
            8: digit = ~7'b1111111;
            9: digit = ~7'b1111011;
            default: digit = ~7'b0000000; // off
            endcase
        end
	 endfunction
    
    assign A = a_num == 2'd0 ? 4'b1110 :
               a_num == 2'd1 ? 4'b1101 :
               a_num == 2'd2 ? 4'b1011 :
               4'b0111;
      
    assign C = a_num == 2'd0 ? digit(val4) :
               a_num == 2'd1 ? digit(val3) :
               a_num == 2'd2 ? digit(val2) :
               digit(val1);
       
    always @(posedge clk) begin
        if (rst) begin
            a_num <= 2'd0;
        end else if (mux_clk) begin
            a_num <= a_num + 2'd1;
        end else begin
            a_num <= a_num;
        end
    end
endmodule