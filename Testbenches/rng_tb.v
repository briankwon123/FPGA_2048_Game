`timescale 1ns/1ns

module rng_tb();

    reg clk;
    reg b1, b3, b2, b4;
    wire gen;
    wire [2:0] btn_cnt;
    reg rst;
    reg [63:0] in_vals;
    wire [63:0] out_vals;
    wire gen_active;

    rng UUT (.clk(clk), .up(b1), .down(b2), .left(b3), .right(b4),
    .rst(rst), .in_vals(in_vals), .out_vals(out_vals), .waiting(gen_active));

    task generate_new();
    begin
        b1 = 1;
        #10
        b1 = 0;
        #15
        b2 = 1;
        #10
        b2 = 0;
        #20
        b4 = 1;
        #10
        b4 = 0;
        while (gen_active == 1) begin
            #1;
        end
        in_vals = out_vals;
    end
    endtask


    initial begin 
        // initialize
        clk <= 0;
        in_vals = 63'd0;
        rst = 1;
        b1 = 0;
        b2 = 0;
        b3 = 0;
        b4 = 0;
        #20
        rst = 0;
        // wait and then request value
        #50
        generate_new();
        #50
        generate_new();
        #80
        generate_new();
        #30
        generate_new();
        #100
        generate_new();
        #150
        generate_new();
        #50
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end


endmodule
