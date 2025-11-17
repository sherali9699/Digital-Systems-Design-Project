`timescale 1ns / 1ps

module Top_module (
    input wire master_clk,    
    input wire reset,

    output wire signed [7:0] dds500_before,   
    output wire signed [7:0] dds2k_before, 
    output wire signed [15:0] dds500_after,  
    output wire signed [15:0] dds2k_after    
);

    
    // 500 Hz DDS
    DDS_500Hz u_dds_500 (
        .master_clk(master_clk),
        .reset(reset),
        .sine_out(dds500_before)
    );

    // 2 kHz DDS 
    DDS_2kHz u_dds_2k (
        .master_clk(master_clk),
        .reset(reset),
        .sine_out(dds2k_before)
    );

    // FIR for 500 Hz signal
    FIR_Filter fir_500 (
        .Data_out(dds500_after),
        .Data_in(dds500_before),
        .clk(master_clk),
        .rst(reset)
    );

    // FIR for 2 kHz signal
    FIR_Filter fir_2k (
        .Data_out(dds2k_after),
        .Data_in(dds2k_before),
        .clk(master_clk),
        .rst(reset)
    );

endmodule

