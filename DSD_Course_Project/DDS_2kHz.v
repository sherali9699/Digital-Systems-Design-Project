`timescale 1ns / 1ps

module DDS_2kHz (
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
    parameter [7:0] frequency_control_register = 8'd61;

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
            8'd1:   sine_out =   8'sd3;
            8'd2:   sine_out =   8'sd6;
            8'd3:   sine_out =   8'sd9;
            8'd4:   sine_out =  8'sd12;
            8'd5:   sine_out =  8'sd16;
            8'd6:   sine_out =  8'sd19;
            8'd7:   sine_out =  8'sd22;
            8'd8:   sine_out =  8'sd25;
            8'd9:   sine_out =  8'sd28;
            8'd10:  sine_out =  8'sd31;
            8'd11:  sine_out =  8'sd34;
            8'd12:  sine_out =  8'sd37;
            8'd13:  sine_out =  8'sd40;
            8'd14:  sine_out =  8'sd43;
            8'd15:  sine_out =  8'sd46;
            8'd16:  sine_out =  8'sd49;
            8'd17:  sine_out =  8'sd51;
            8'd18:  sine_out =  8'sd54;
            8'd19:  sine_out =  8'sd57;
            8'd20:  sine_out =  8'sd60;
            8'd21:  sine_out =  8'sd63;
            8'd22:  sine_out =  8'sd65;
            8'd23:  sine_out =  8'sd68;
            8'd24:  sine_out =  8'sd70;
            8'd25:  sine_out =  8'sd73;
            8'd26:  sine_out =  8'sd75;
            8'd27:  sine_out =  8'sd78;
            8'd28:  sine_out =  8'sd80;
            8'd29:  sine_out =  8'sd82;
            8'd30:  sine_out =  8'sd84;
            8'd31:  sine_out =  8'sd87;
            8'd32:  sine_out =  8'sd89;
            8'd33:  sine_out =  8'sd91;
            8'd34:  sine_out =  8'sd93;
            8'd35:  sine_out =  8'sd95;
            8'd36:  sine_out =  8'sd96;
            8'd37:  sine_out =  8'sd98;
            8'd38:  sine_out =  8'sd100;
            8'd39:  sine_out =  8'sd101;
            8'd40:  sine_out =  8'sd103;
            8'd41:  sine_out =  8'sd104;
            8'd42:  sine_out =  8'sd106;
            8'd43:  sine_out =  8'sd107;
            8'd44:  sine_out =  8'sd108;
            8'd45:  sine_out =  8'sd109;
            8'd46:  sine_out =  8'sd110;
            8'd47:  sine_out =  8'sd111;
            8'd48:  sine_out =  8'sd112;
            8'd49:  sine_out =  8'sd113;
            8'd50:  sine_out =  8'sd114;
            8'd51:  sine_out =  8'sd115;
            8'd52:  sine_out =  8'sd115;
            8'd53:  sine_out =  8'sd116;
            8'd54:  sine_out =  8'sd116;
            8'd55:  sine_out =  8'sd117;
            8'd56:  sine_out =  8'sd117;
            8'd57:  sine_out =  8'sd117;
            8'd58:  sine_out =  8'sd118;
            8'd59:  sine_out =  8'sd118;
            8'd60:  sine_out =  8'sd118;
            8'd61:  sine_out =  8'sd118;
            8'd62:  sine_out =  8'sd118;
            8'd63:  sine_out =  8'sd118;
            8'd64:  sine_out =  8'sd118;
            8'd65:  sine_out =  8'sd118;
            8'd66:  sine_out =  8'sd117;
            8'd67:  sine_out =  8'sd117;
            8'd68:  sine_out =  8'sd117;
            8'd69:  sine_out =  8'sd116;
            8'd70:  sine_out =  8'sd116;
            8'd71:  sine_out =  8'sd115;
            8'd72:  sine_out =  8'sd115;
            8'd73:  sine_out =  8'sd114;
            8'd74:  sine_out =  8'sd113;
            8'd75:  sine_out =  8'sd112;
            8'd76:  sine_out =  8'sd111;
            8'd77:  sine_out =  8'sd110;
            8'd78:  sine_out =  8'sd109;
            8'd79:  sine_out =  8'sd108;
            8'd80:  sine_out =  8'sd107;
            8'd81:  sine_out =  8'sd106;
            8'd82:  sine_out =  8'sd104;
            8'd83:  sine_out =  8'sd103;
            8'd84:  sine_out =  8'sd101;
            8'd85:  sine_out =  8'sd100;
            8'd86:  sine_out =   8'sd98;
            8'd87:  sine_out =   8'sd96;
            8'd88:  sine_out =   8'sd95;
            8'd89:  sine_out =   8'sd93;
            8'd90:  sine_out =   8'sd91;
            8'd91:  sine_out =   8'sd89;
            8'd92:  sine_out =   8'sd87;
            8'd93:  sine_out =   8'sd84;
            8'd94:  sine_out =   8'sd82;
            8'd95:  sine_out =   8'sd80;
            8'd96:  sine_out =   8'sd78;
            8'd97:  sine_out =   8'sd75;
            8'd98:  sine_out =   8'sd73;
            8'd99:  sine_out =   8'sd70;
            8'd100: sine_out =   8'sd68;
            8'd101: sine_out =   8'sd65;
            8'd102: sine_out =   8'sd63;
            8'd103: sine_out =   8'sd60;
            8'd104: sine_out =   8'sd57;
            8'd105: sine_out =   8'sd54;
            8'd106: sine_out =   8'sd51;
            8'd107: sine_out =   8'sd49;
            8'd108: sine_out =   8'sd46;
            8'd109: sine_out =   8'sd43;
            8'd110: sine_out =   8'sd40;
            8'd111: sine_out =   8'sd37;
            8'd112: sine_out =   8'sd34;
            8'd113: sine_out =   8'sd31;
            8'd114: sine_out =   8'sd28;
            8'd115: sine_out =   8'sd25;
            8'd116: sine_out =   8'sd22;
            8'd117: sine_out =   8'sd19;
            8'd118: sine_out =   8'sd16;
            8'd119: sine_out =   8'sd12;
            8'd120: sine_out =   8'sd9;
            8'd121: sine_out =   8'sd6;
            8'd122: sine_out =   8'sd3;
            8'd123: sine_out =   8'sd0;
            8'd124: sine_out =  -8'sd3;
            8'd125: sine_out =  -8'sd6;
            8'd126: sine_out =  -8'sd9;
            8'd127: sine_out = -8'sd12;
            8'd128: sine_out = -8'sd16;
            8'd129: sine_out = -8'sd19;
            8'd130: sine_out = -8'sd22;
            8'd131: sine_out = -8'sd25;
            8'd132: sine_out = -8'sd28;
            8'd133: sine_out = -8'sd31;
            8'd134: sine_out = -8'sd34;
            8'd135: sine_out = -8'sd37;
            8'd136: sine_out = -8'sd40;
            8'd137: sine_out = -8'sd43;
            8'd138: sine_out = -8'sd46;
            8'd139: sine_out = -8'sd49;
            8'd140: sine_out = -8'sd51;
            8'd141: sine_out = -8'sd54;
            8'd142: sine_out = -8'sd57;
            8'd143: sine_out = -8'sd60;
            8'd144: sine_out = -8'sd63;
            8'd145: sine_out = -8'sd65;
            8'd146: sine_out = -8'sd68;
            8'd147: sine_out = -8'sd70;
            8'd148: sine_out = -8'sd73;
            8'd149: sine_out = -8'sd75;
            8'd150: sine_out = -8'sd78;
            8'd151: sine_out = -8'sd80;
            8'd152: sine_out = -8'sd82;
            8'd153: sine_out = -8'sd84;
            8'd154: sine_out = -8'sd87;
            8'd155: sine_out = -8'sd89;
            8'd156: sine_out = -8'sd91;
            8'd157: sine_out = -8'sd93;
            8'd158: sine_out = -8'sd95;
            8'd159: sine_out = -8'sd96;
            8'd160: sine_out = -8'sd98;
            8'd161: sine_out = -8'sd100;
            8'd162: sine_out = -8'sd101;
            8'd163: sine_out = -8'sd103;
            8'd164: sine_out = -8'sd104;
            8'd165: sine_out = -8'sd106;
            8'd166: sine_out = -8'sd107;
            8'd167: sine_out = -8'sd108;
            8'd168: sine_out = -8'sd109;
            8'd169: sine_out = -8'sd110;
            8'd170: sine_out = -8'sd111;
            8'd171: sine_out = -8'sd112;
            8'd172: sine_out = -8'sd113;
            8'd173: sine_out = -8'sd114;
            8'd174: sine_out = -8'sd115;
            8'd175: sine_out = -8'sd115;
            8'd176: sine_out = -8'sd116;
            8'd177: sine_out = -8'sd116;
            8'd178: sine_out = -8'sd117;
            8'd179: sine_out = -8'sd117;
            8'd180: sine_out = -8'sd117;
            8'd181: sine_out = -8'sd118;
            8'd182: sine_out = -8'sd118;
            8'd183: sine_out = -8'sd118;
            8'd184: sine_out = -8'sd118;
            8'd185: sine_out = -8'sd118;
            8'd186: sine_out = -8'sd118;
            8'd187: sine_out = -8'sd118;
            8'd188: sine_out = -8'sd118;
            8'd189: sine_out = -8'sd117;
            8'd190: sine_out = -8'sd117;
            8'd191: sine_out = -8'sd117;
            8'd192: sine_out = -8'sd116;
            8'd193: sine_out = -8'sd116;
            8'd194: sine_out = -8'sd115;
            8'd195: sine_out = -8'sd115;
            8'd196: sine_out = -8'sd114;
            8'd197: sine_out = -8'sd113;
            8'd198: sine_out = -8'sd112;
            8'd199: sine_out = -8'sd111;
            8'd200: sine_out = -8'sd110;
            8'd201: sine_out = -8'sd109;
            8'd202: sine_out = -8'sd108;
            8'd203: sine_out = -8'sd107;
            8'd204: sine_out = -8'sd106;
            8'd205: sine_out = -8'sd104;
            8'd206: sine_out = -8'sd103;
            8'd207: sine_out = -8'sd101;
            8'd208: sine_out = -8'sd100;
            8'd209: sine_out =  -8'sd98;
            8'd210: sine_out =  -8'sd96;
            8'd211: sine_out =  -8'sd95;
            8'd212: sine_out =  -8'sd93;
            8'd213: sine_out =  -8'sd91;
            8'd214: sine_out =  -8'sd89;
            8'd215: sine_out =  -8'sd87;
            8'd216: sine_out =  -8'sd84;
            8'd217: sine_out =  -8'sd82;
            8'd218: sine_out =  -8'sd80;
            8'd219: sine_out =  -8'sd78;
            8'd220: sine_out =  -8'sd75;
            8'd221: sine_out =  -8'sd73;
            8'd222: sine_out =  -8'sd70;
            8'd223: sine_out =  -8'sd68;
            8'd224: sine_out =  -8'sd65;
            8'd225: sine_out =  -8'sd63;
            8'd226: sine_out =  -8'sd60;
            8'd227: sine_out =  -8'sd57;
            8'd228: sine_out =  -8'sd54;
            8'd229: sine_out =  -8'sd51;
            8'd230: sine_out =  -8'sd49;
            8'd231: sine_out =  -8'sd46;
            8'd232: sine_out =  -8'sd43;
            8'd233: sine_out =  -8'sd40;
            8'd234: sine_out =  -8'sd37;
            8'd235: sine_out =  -8'sd34;
            8'd236: sine_out =  -8'sd31;
            8'd237: sine_out =  -8'sd28;
            8'd238: sine_out =  -8'sd25;
            8'd239: sine_out =  -8'sd22;
            8'd240: sine_out =  -8'sd19;
            8'd241: sine_out =  -8'sd16;
            8'd242: sine_out =  -8'sd12;
            8'd243: sine_out =   -8'sd9;
            8'd244: sine_out =   -8'sd6;
            8'd245: sine_out =   -8'sd3;
            8'd246: sine_out =    8'sd0;
            8'd247: sine_out =    8'sd3;
            8'd248: sine_out =    8'sd6;
            8'd249: sine_out =    8'sd9;
            8'd250: sine_out =   8'sd12;
            8'd251: sine_out =   8'sd16;
            8'd252: sine_out =   8'sd19;
            8'd253: sine_out =   8'sd22;
            8'd254: sine_out =   8'sd25;
            8'd255: sine_out =   8'sd28;
        default: 
            sine_out = 8'sd0;
        endcase
    end

endmodule
