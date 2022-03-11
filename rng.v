/* Generates random numbers to fill grid
    Fills an empty spot with a new value
    New values are either 2 or 4 (1 or 2 in output)
    Adding a 2 has higher probability than 4
*/

module rng(
    input clk,          // system clock
	 input rst,
	input wire up,
	input wire down,
    input wire left,
    input wire right,
    input [63:0] in_vals,
	output reg [63:0] out_vals,
    output reg waiting          // if currently searching for new value
);

    // monitor updates to count button presses
    reg [2:0] btn_cnt;
    parameter MAX_BTN_CNT = 3'd2;
    reg gen;
    
    // state of module
    // determines which bits to pull from output 
    reg [7:0] state;
    reg [15:0] cnt;

    // index in the board
    wire [3:0] idx;
    // value to insert in board
    wire [3:0] val;

    // set new value to 2 11/16 of the time
    assign val = cnt[3:0] < 11 ? 4'd1 : 4'd2;

    // select "random" bits for the new tile location based on state
    assign idx[3] = state[1:0] == 2'd0 ? cnt[0] : 
                    state[1:0] == 2'd1 ? cnt[4] :
                    state[1:0] == 2'd2 ? cnt[8] : cnt[12];
    assign idx[2] = state[3:2] == 2'd0 ? cnt[1] : 
                    state[3:2] == 2'd1 ? cnt[5] :
                    state[3:2] == 2'd2 ? cnt[9] : cnt[13];
    assign idx[1] = state[5:4] == 2'd0 ? cnt[2] : 
                    state[5:4] == 2'd1 ? cnt[6] :
                    state[5:4] == 2'd2 ? cnt[10] : cnt[14];
    assign idx[0] = state[7:6] == 2'd0 ? cnt[3] : 
                    state[7:6] == 2'd1 ? cnt[7] :
                    state[7:6] == 2'd2 ? cnt[11] : cnt[15];

    // Decide what value (2 or 4) to set
    always @(posedge clk) begin 
		if (rst) begin
            cnt <= 16'd0;
            state <= 8'd0;
            waiting <= 1;
            out_vals <= in_vals;
        end else if (gen) begin
            cnt <= cnt + 1;
            state <= state + 1;
            waiting <= 1;
            out_vals <= in_vals;
        end else begin 
            // Increment counter
            cnt <= cnt + 1;
            //out_vals <= in_vals;
            // maintain internal state state
            state <= state;
            if (waiting) begin // find random number
                if (((in_vals >> (4*idx)) & 4'b1111) == 4'd0) begin // check of tile is empty
                    out_vals <= in_vals | ({60'd0, val} << (4*idx));
                    waiting <= 0;
                end else begin // continue looking for new number
                    waiting <= 1;
                    out_vals <= in_vals;
                end
            end else begin
                waiting <= 0;
                out_vals <= in_vals;
            end
        end
    end
    
    
    // register new update
    always @(posedge clk) begin
        if (rst) begin
            gen <= 0;
            btn_cnt <= 3'd0;
        end else if (left | right | up | down) begin
            if (btn_cnt >= MAX_BTN_CNT) begin
                gen <= 1;
                btn_cnt <= 3'd0;
            end else begin
                btn_cnt <= btn_cnt + 3'd1;
                gen <= 0;
            end
        end else begin
            btn_cnt <= btn_cnt;
            gen <= 0;
        end
    end

endmodule