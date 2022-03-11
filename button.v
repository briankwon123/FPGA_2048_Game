/*
    Debounces an input button signal
    After debounce period, there are 3 pulses of one clock cycle
    Triggers on negative edges for tinming reasons 
*/

module button #(parameter DEBOUNCE_PERIOD = 1000000)(
    input clk,
    input btn,
    output reg out
);

    reg [31:0] debounce_timer;
    
    reg [2:0]   pulse_cnt;
    reg registered;
    
    // Perform debouncing
    always @(posedge clk) begin 
        if (pulse_cnt < 3'd4) begin   // output active
           out <= ~out;
           pulse_cnt <= pulse_cnt + 3'd1;
           registered <= registered;
           debounce_timer <= debounce_timer;
        end else if (btn && debounce_timer < DEBOUNCE_PERIOD) begin // Debouncing
            out <= 0;
            debounce_timer <= debounce_timer + 1;
            registered <= 0;
            pulse_cnt <= 3'd7; // set to max count so it doesn't trigger
        end else if (btn && ~registered) begin // begin pulsing output
            out <= 1;
            debounce_timer <= debounce_timer;
            pulse_cnt <= 3'd0;
            registered <= 1;
        end else if (~btn) begin  // Button not pressed, reset output 
            debounce_timer <= 32'd0;
            out <= 0;
            registered <= registered;
            pulse_cnt <= 3'd7;
        end else begin
            debounce_timer <= debounce_timer;
            out <= 0;
            registered <= registered;
            pulse_cnt <= pulse_cnt;
        end
    end


endmodule 


/*
    Debounces an input button signal
    Output goes high for one clock cycle
    Triggers on negative edges for tinming reasons 
*/
/*
module button #(parameter DEBOUNCE_PERIOD = 1000000)(
    input clk,
    input btn,
    output reg out
);

    reg [31:0] debounce_timer;
    reg registered;
    
    // Perform debouncing
    always @(posedge clk) begin 
        if (btn && debounce_timer < DEBOUNCE_PERIOD) begin // Debouncing
            out <= 0;
            debounce_timer <= debounce_timer + 1;
            registered <= 0;
        end else if (btn & ~registered) begin 
            out <= 1;
            debounce_timer <= debounce_timer;
            registered <= 1;
        end else if (btn) begin // Have output go back low
            out <= 0;
            debounce_timer <= debounce_timer;
            registered <= registered;
        end else begin  // Button not pressed, reset outputs 
            debounce_timer <= 32'd0;
            out <= 0;
            registered <= 0;
        end
    end


endmodule 
*/