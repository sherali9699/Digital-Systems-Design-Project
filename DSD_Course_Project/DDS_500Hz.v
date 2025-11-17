`timescale 1ns / 1ps

module DDS_500Hz (
    input wire master_clk,   // 100 kHz master clock
    input wire reset,
    output reg signed [7:0] sine_out
);

    // Clock divider: 100 kHz to 8 kHz
    // 100kHz/8kHz = 12
    // so every 12 master_clk cycles, generate one discretized sine pulse (sample_en)
    reg [3:0] div_cnt;     
    reg sample_en;   

    always @(posedge master_clk or posedge reset) begin
        if (reset) begin
            div_cnt <= 4'd0;
            sample_en <= 1'b0;
        end else begin
            if (div_cnt == 4'd11) begin
                div_cnt <= 4'd0;
                sample_en <= 1'b1;   
            end else begin
                div_cnt <= div_cnt + 4'd1;
                sample_en <= 1'b0;
            end
        end
    end

    // 8-bit phase accumulator
    reg [7:0] phase_accumulator;

    // For DDS with f_out = 500Hz
    // f_out = f_s * K / 2^8, f_s = 8kHz 
    // K = 500 * (2^8) / 8000 = 16 
    parameter [7:0] frequency_control_register = 8'd16;

    always @(posedge master_clk or posedge reset) begin
        if (reset) begin
            phase_accumulator <= 8'd0;
        end else if (sample_en) begin
            // Only update at 8 kHz rate
            phase_accumulator <= phase_accumulator + frequency_control_register;
        end
        else begin
            // hold phase accumulator
            phase_accumulator <= phase_accumulator + 4'd0;
        end
    end

    // Sine lookup table with 256 entries
    // sine_out = round(127 * sin(2*pi*phase_accumulator / 256))
    always @(*) begin
        case (phase_accumulator)
            8'd0:   sine_out =   8'sd0;
            8'd16:  sine_out =   8'sd49;
            8'd32:  sine_out =   8'sd90;
            8'd48:  sine_out =  8'sd117;
            8'd64:  sine_out =  8'sd127;
            8'd80:  sine_out =  8'sd117;
            8'd96:  sine_out =   8'sd90;
            8'd112: sine_out =   8'sd49;
            8'd128: sine_out =   8'sd0;
            8'd144: sine_out =  -8'sd49;
            8'd160: sine_out =  -8'sd90;
            8'd176: sine_out = -8'sd117;
            8'd192: sine_out = -8'sd127;
            8'd208: sine_out = -8'sd117;
            8'd224: sine_out =  -8'sd90;
            8'd240: sine_out =  -8'sd49;
        default: 
            sine_out = 8'sd0;
        endcase
    end

endmodule
