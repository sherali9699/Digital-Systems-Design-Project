`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2025 18:21:35
// Design Name: 
// Module Name: FIR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Filter(
    Data_out,
    Data_in,
    clk,
    rst
);
  
    parameter order = 51;
    parameter word_size_in = 8;
    parameter word_size_out = (2*word_size_in);  // 16 bits

    parameter signed [9:0] b0  = 10'sd0;
    parameter signed [9:0] b1  = 10'sd0;
    parameter signed [9:0] b2  = 10'sd0;
    parameter signed [9:0] b3  = 10'sd0;
    parameter signed [9:0] b4  = 10'sd0;
    parameter signed [9:0] b5  = 10'sd0;
    parameter signed [9:0] b6  = 10'sd0;
    parameter signed [9:0] b7  = 10'sd1;
    parameter signed [9:0] b8  = 10'sd0;
    parameter signed [9:0] b9  = 10'sd0;
    parameter signed [9:0] b10 = -10'd1;
    parameter signed [9:0] b11 = -10'd1;
    parameter signed [9:0] b12 = -10'd1;
    parameter signed [9:0] b13 = -10'd0;
    parameter signed [9:0] b14 = 10'sd2;
    parameter signed [9:0] b15 = 10'sd3;
    parameter signed [9:0] b16 = 10'sd2;
    parameter signed [9:0] b17 = 10'sd0;
    parameter signed [9:0] b18 = -10'd3;
    parameter signed [9:0] b19 = -10'd6;
    parameter signed [9:0] b20 = -10'd5;
    parameter signed [9:0] b21 = -10'd0;
    parameter signed [9:0] b22 = 10'sd9;
    parameter signed [9:0] b23 = 10'sd20;
    parameter signed [9:0] b24 = 10'sd29;
    parameter signed [9:0] b25 = 10'sd32;
    parameter signed [9:0] b26 = 10'sd29;
    parameter signed [9:0] b27 = 10'sd20;
    parameter signed [9:0] b28 = 10'sd9;
    parameter signed [9:0] b29 = 10'sd0;
    parameter signed [9:0] b30 = -10'd5;
    parameter signed [9:0] b31 = -10'd6;
    parameter signed [9:0] b32 = -10'd3;
    parameter signed [9:0] b33 = 10'sd0;
    parameter signed [9:0] b34 = 10'sd2;
    parameter signed [9:0] b35 = 10'sd3;
    parameter signed [9:0] b36 = 10'sd2;
    parameter signed [9:0] b37 = 10'sd0;
    parameter signed [9:0] b38 = -10'd1;
    parameter signed [9:0] b39 = -10'd1;
    parameter signed [9:0] b40 = -10'd1;
    parameter signed [9:0] b41 = 10'sd0;
    parameter signed [9:0] b42 = 10'sd0;
    parameter signed [9:0] b43 = 10'sd1;
    parameter signed [9:0] b44 = 10'sd0;
    parameter signed [9:0] b45 = 10'sd0;
    parameter signed [9:0] b46 = 10'sd0;
    parameter signed [9:0] b47 = 10'sd0;
    parameter signed [9:0] b48 = 10'sd0;
    parameter signed [9:0] b49 = 10'sd0;
    parameter signed [9:0] b50 = 10'sd0;

    output signed [word_size_out-1:0] Data_out;

    input signed [word_size_in-1:0] Data_in;
    input clk, rst;
  
    reg signed [word_size_in-1:0] Samples [1:order];

    integer k;

    assign Data_out =
          b0  * (Data_in      >>> 3) +
          b1  * (Samples[1]   >>> 3) +
          b2  * (Samples[2]   >>> 3) +
          b3  * (Samples[3]   >>> 3) +
          b4  * (Samples[4]   >>> 3) +
          b5  * (Samples[5]   >>> 3) +
          b6  * (Samples[6]   >>> 3) +
          b7  * (Samples[7]   >>> 3) +
          b8  * (Samples[8]   >>> 3) +
          b9  * (Samples[9]   >>> 3) +
          b10 * (Samples[10]  >>> 3) +
          b11 * (Samples[11]  >>> 3) +
          b12 * (Samples[12]  >>> 3) +
          b13 * (Samples[13]  >>> 3) +
          b14 * (Samples[14]  >>> 3) +
          b15 * (Samples[15]  >>> 3) +
          b16 * (Samples[16]  >>> 3) +
          b17 * (Samples[17]  >>> 3) +
          b18 * (Samples[18]  >>> 3) +
          b19 * (Samples[19]  >>> 3) +
          b20 * (Samples[20]  >>> 3) +
          b21 * (Samples[21]  >>> 3) +
          b22 * (Samples[22]  >>> 3) +
          b23 * (Samples[23]  >>> 3) +
          b24 * (Samples[24]  >>> 3) +
          b25 * (Samples[25]  >>> 3) +
          b26 * (Samples[26]  >>> 3) +
          b27 * (Samples[27]  >>> 3) +
          b28 * (Samples[28]  >>> 3) +
          b29 * (Samples[29]  >>> 3) +
          b30 * (Samples[30]  >>> 3) +
          b31 * (Samples[31]  >>> 3) +
          b32 * (Samples[32]  >>> 3) +
          b33 * (Samples[33]  >>> 3) +
          b34 * (Samples[34]  >>> 3) +
          b35 * (Samples[35]  >>> 3) +
          b36 * (Samples[36]  >>> 3) +
          b37 * (Samples[37]  >>> 3) +
          b38 * (Samples[38]  >>> 3) +
          b39 * (Samples[39]  >>> 3) +
          b40 * (Samples[40]  >>> 3) +
          b41 * (Samples[41]  >>> 3) +
          b42 * (Samples[42]  >>> 3) +
          b43 * (Samples[43]  >>> 3) +
          b44 * (Samples[44]  >>> 3) +
          b45 * (Samples[45]  >>> 3) +
          b46 * (Samples[46]  >>> 3) +
          b47 * (Samples[47]  >>> 3) +
          b48 * (Samples[48]  >>> 3) +
          b49 * (Samples[49]  >>> 3) +
          b50 * (Samples[50]  >>> 3);

    // Shift register for samples 
    always @(posedge clk) begin
        if (rst == 1) begin
            for (k = 1; k <= order; k = k + 1)
                Samples[k] <= 0;
        end else begin
            Samples[1] <= Data_in;
            for (k = 2; k <= order; k = k + 1)
                Samples[k] <= Samples[k-1];
        end
    end

endmodule

