`timescale 1ns / 1ps
`define DEBUG
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:39:09 02/07/2022 
// Design Name: 
// Module Name:    testbench 
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
module button_tb();
    
    reg clk;
    reg btn_in;
    wire btn_out;

    button #(5) b_test(.clk(clk), .btn(btn_in), .out(btn_out));
    task bounce_btn();
    begin
        btn_in = 1;
        #12
        btn_in = 0;
        #17
        btn_in = 1;
        #23
        btn_in = 0;
        #14
        btn_in = 1;
    end
    endtask
   
    
    initial begin
        clk = 1'b0;
        #50
        bounce_btn;
        #300
        btn_in = 0;
        #100
        $finish;
    end
    
    always begin
        #5
        clk = ~clk;
    end
    
    


endmodule
