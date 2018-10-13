module arctan_LUT(
    input               clk,
    input signed [11:0] numer,  //y in range [-c_max, c_max -1)
    input signed [11:0] denom,  //x in range [-c_max, c_max -1)
    output signed [9:0]  theta
);
	wire signed [11:0] numer_abs_long = 12'd0 - numer;
    wire signed [11:0] denom_abs_long = 12'd0 - denom;

    wire unsigned [10:0] numer_abs = (numer > 0) ? numer[10:0] : numer_abs_long[10:0];
    wire unsigned [10:0] denom_abs = (denom > 0) ? denom[10:0] : denom_abs_long[10:0];

    reg unsigned [13:0] div_fp_abs_d0;
    wire unsigned [13:0] div_fp_abs_d2; //since ingeter range [0, 57]
    // 6b integer, 8b fraction
    always @ (*) begin
        if (numer_abs == 11'd0)                                    div_fp_abs_d0 = 14'd0;
        else if (denom_abs == 11'd0)                               div_fp_abs_d0 = {6'd57, 8'd0};
        else if (numer_abs < 11'd57)                               div_fp_abs_d0 = {6'd60, 8'd0}; //use lut
        else begin
            if      (denom_abs == 11'd2 && numer_abs < 11'd114)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd3 && numer_abs < 11'd171)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd4 && numer_abs < 11'd228)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd5 && numer_abs < 11'd285)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd6 && numer_abs < 11'd342)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd7 && numer_abs < 11'd399)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd8 && numer_abs < 11'd456)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd9 && numer_abs < 11'd513)    div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd10 && numer_abs < 11'd570)   div_fp_abs_d0 = {6'd60, 8'd0};
            else if (denom_abs == 11'd11 && numer_abs < 11'd627)   div_fp_abs_d0 = {6'd60, 8'd0};
            else                                                   div_fp_abs_d0 = {6'd57, 8'd0};
        end                                                   
    end

    reg unsigned [15:0] lut_address;
    always @ (*) begin
        if (numer_abs < 11'd57) begin
            lut_address = (numer_abs - 1) * 639 + (denom_abs -1);
        end
        else begin
            case(denom_abs) 
                11'd1: lut_address = {1'b0, numer_abs} + 16'd35784;
                11'd2: lut_address = {1'b0, numer_abs} + 16'd57+ 16'd35784;
                11'd3: lut_address = {1'b0, numer_abs} + 16'd171+ 16'd35784;
                11'd4: lut_address = {1'b0, numer_abs} + 16'd342+ 16'd35784;
                11'd5: lut_address = {1'b0, numer_abs} + 16'd570+ 16'd35784;
                11'd6: lut_address = {1'b0, numer_abs} + 16'd855+ 16'd35784;
                11'd7: lut_address = {1'b0, numer_abs} + 16'd1197+ 16'd35784;
                11'd8: lut_address = {1'b0, numer_abs} + 16'd1596+ 16'd35784;
                11'd9: lut_address = {1'b0, numer_abs} + 16'd2052+ 16'd35784;
                11'd10: lut_address = {1'b0, numer_abs} + 16'd2565+ 16'd35784;
                11'd11: lut_address = {1'b0, numer_abs} + 16'd3135+ 16'd35784;
                default: lut_address = 12'd0;
            endcase
        end
        
    end

    //only lookup in the table if result is <57. otherwise doesn' make dif for arctan
    wire unsigned [13:0] lut_output;
    rom_fp_divide_new fp_divide_LUT (
        .clock(clk), 
        .address(lut_address), 
        .q(lut_output)
    );
    
    delay #(.DATA_WIDTH(14), .DELAY(2)) delay_div_fp_abs(
        .clk (clk), 
        .data_in (div_fp_abs_d0), 
        .data_out(div_fp_abs_d2)
    );
    wire signed [19:0] div_fp_abs = (div_fp_abs_d2 == {6'd60, 8'd0}) ? {6'd0, lut_output} : {6'd0, div_fp_abs_d2};
    reg signed [9:0] temp_theta;
    wire pos_x = !denom[11];
    wire pos_y = !numer[11];
    //using the result of the floating point division, arctan
    always @ (div_fp_abs) begin
        if (div_fp_abs < 20'b00000000000000000101) temp_theta = 10'd0;
        else if (div_fp_abs < 20'b00000000000000001001) temp_theta = 10'b0000000001;
        else if (div_fp_abs < 20'b00000000000000001110) temp_theta = 10'b0000000010;
        else if (div_fp_abs < 20'b00000000000000010010) temp_theta = 10'b0000000011;
        else if (div_fp_abs < 20'b00000000000000010111) temp_theta = 10'b0000000100;
        else if (div_fp_abs < 20'b00000000000000011011) temp_theta = 10'b0000000101;
        else if (div_fp_abs < 20'b00000000000000100000) temp_theta = 10'b0000000110;
        else if (div_fp_abs < 20'b00000000000000100100) temp_theta = 10'b0000000111;
        else if (div_fp_abs < 20'b00000000000000101001) temp_theta = 10'b0000001000;
        else if (div_fp_abs < 20'b00000000000000101110) temp_theta = 10'b0000001001;
        else if (div_fp_abs < 20'b00000000000000110010) temp_theta = 10'b0000001010;
        else if (div_fp_abs < 20'b00000000000000110111) temp_theta = 10'b0000001011;
        else if (div_fp_abs < 20'b00000000000000111100) temp_theta = 10'b0000001100;
        else if (div_fp_abs < 20'b00000000000001000000) temp_theta = 10'b0000001101;
        else if (div_fp_abs < 20'b00000000000001000101) temp_theta = 10'b0000001110;
        else if (div_fp_abs < 20'b00000000000001001010) temp_theta = 10'b0000001111;
        else if (div_fp_abs < 20'b00000000000001001111) temp_theta = 10'b0000010000;
        else if (div_fp_abs < 20'b00000000000001010100) temp_theta = 10'b0000010001;
        else if (div_fp_abs < 20'b00000000000001011001) temp_theta = 10'b0000010010;
        else if (div_fp_abs < 20'b00000000000001011110) temp_theta = 10'b0000010011;
        else if (div_fp_abs < 20'b00000000000001100011) temp_theta = 10'b0000010100;
        else if (div_fp_abs < 20'b00000000000001101000) temp_theta = 10'b0000010101;
        else if (div_fp_abs < 20'b00000000000001101101) temp_theta = 10'b0000010110;
        else if (div_fp_abs < 20'b00000000000001110010) temp_theta = 10'b0000010111;
        else if (div_fp_abs < 20'b00000000000001111000) temp_theta = 10'b0000011000;
        else if (div_fp_abs < 20'b00000000000001111101) temp_theta = 10'b0000011001;
        else if (div_fp_abs < 20'b00000000000010000011) temp_theta = 10'b0000011010;
        else if (div_fp_abs < 20'b00000000000010001001) temp_theta = 10'b0000011011;
        else if (div_fp_abs < 20'b00000000000010001110) temp_theta = 10'b0000011100;
        else if (div_fp_abs < 20'b00000000000010010100) temp_theta = 10'b0000011101;
        else if (div_fp_abs < 20'b00000000000010011010) temp_theta = 10'b0000011110;
        else if (div_fp_abs < 20'b00000000000010100000) temp_theta = 10'b0000011111;
        else if (div_fp_abs < 20'b00000000000010100111) temp_theta = 10'b0000100000;
        else if (div_fp_abs < 20'b00000000000010101101) temp_theta = 10'b0000100001;
        else if (div_fp_abs < 20'b00000000000010110100) temp_theta = 10'b0000100010;
        else if (div_fp_abs < 20'b00000000000010111010) temp_theta = 10'b0000100011;
        else if (div_fp_abs < 20'b00000000000011000001) temp_theta = 10'b0000100100;
        else if (div_fp_abs < 20'b00000000000011001001) temp_theta = 10'b0000100101;
        else if (div_fp_abs < 20'b00000000000011010000) temp_theta = 10'b0000100110;
        else if (div_fp_abs < 20'b00000000000011010111) temp_theta = 10'b0000100111;
        else if (div_fp_abs < 20'b00000000000011011111) temp_theta = 10'b0000101000;
        else if (div_fp_abs < 20'b00000000000011100111) temp_theta = 10'b0000101001;
        else if (div_fp_abs < 20'b00000000000011101111) temp_theta = 10'b0000101010;
        else if (div_fp_abs < 20'b00000000000011111000) temp_theta = 10'b0000101011;
        else if (div_fp_abs < 20'b00000000000100000000) temp_theta = 10'b0000101100;
        else if (div_fp_abs < 20'b00000000000100001010) temp_theta = 10'b0000101101;
        else if (div_fp_abs < 20'b00000000000100010011) temp_theta = 10'b0000101110;
        else if (div_fp_abs < 20'b00000000000100011101) temp_theta = 10'b0000101111;
        else if (div_fp_abs < 20'b00000000000100100111) temp_theta = 10'b0000110000;
        else if (div_fp_abs < 20'b00000000000100110010) temp_theta = 10'b0000110001;
        else if (div_fp_abs < 20'b00000000000100111101) temp_theta = 10'b0000110010;
        else if (div_fp_abs < 20'b00000000000101001000) temp_theta = 10'b0000110011;
        else if (div_fp_abs < 20'b00000000000101010100) temp_theta = 10'b0000110100;
        else if (div_fp_abs < 20'b00000000000101100001) temp_theta = 10'b0000110101;
        else if (div_fp_abs < 20'b00000000000101101110) temp_theta = 10'b0000110110;
        else if (div_fp_abs < 20'b00000000000101111100) temp_theta = 10'b0000110111;
        else if (div_fp_abs < 20'b00000000000110001011) temp_theta = 10'b0000111000;
        else if (div_fp_abs < 20'b00000000000110011010) temp_theta = 10'b0000111001;
        else if (div_fp_abs < 20'b00000000000110101011) temp_theta = 10'b0000111010;
        else if (div_fp_abs < 20'b00000000000110111100) temp_theta = 10'b0000111011;
        else if (div_fp_abs < 20'b00000000000111001110) temp_theta = 10'b0000111100;
        else if (div_fp_abs < 20'b00000000000111100010) temp_theta = 10'b0000111101;
        else if (div_fp_abs < 20'b00000000000111110111) temp_theta = 10'b0000111110;
        else if (div_fp_abs < 20'b00000000001000001101) temp_theta = 10'b0000111111;
        else if (div_fp_abs < 20'b00000000001000100101) temp_theta = 10'b0001000000;
        else if (div_fp_abs < 20'b00000000001000111111) temp_theta = 10'b0001000001;
        else if (div_fp_abs < 20'b00000000001001011100) temp_theta = 10'b0001000010;
        else if (div_fp_abs < 20'b00000000001001111010) temp_theta = 10'b0001000011;
        else if (div_fp_abs < 20'b00000000001010011011) temp_theta = 10'b0001000100;
        else if (div_fp_abs < 20'b00000000001011000000) temp_theta = 10'b0001000101;
        else if (div_fp_abs < 20'b00000000001011101000) temp_theta = 10'b0001000110;
        else if (div_fp_abs < 20'b00000000001100010100) temp_theta = 10'b0001000111;
        else if (div_fp_abs < 20'b00000000001101000110) temp_theta = 10'b0001001000;
        else if (div_fp_abs < 20'b00000000001101111101) temp_theta = 10'b0001001001;
        else if (div_fp_abs < 20'b00000000001110111100) temp_theta = 10'b0001001010;
        else if (div_fp_abs < 20'b00000000010000000011) temp_theta = 10'b0001001011;
        else if (div_fp_abs < 20'b00000000010001010101) temp_theta = 10'b0001001100;
        else if (div_fp_abs < 20'b00000000010010110101) temp_theta = 10'b0001001101;
        else if (div_fp_abs < 20'b00000000010100100110) temp_theta = 10'b0001001110;
        else if (div_fp_abs < 20'b00000000010110101100) temp_theta = 10'b0001001111;
        else if (div_fp_abs < 20'b00000000011001010001) temp_theta = 10'b0001010000;
        else if (div_fp_abs < 20'b00000000011100011110) temp_theta = 10'b0001010001;
        else if (div_fp_abs < 20'b00000000100000100101) temp_theta = 10'b0001010010;
        else if (div_fp_abs < 20'b00000000100110000100) temp_theta = 10'b0001010011;
        else if (div_fp_abs < 20'b00000000101101101111) temp_theta = 10'b0001010100;
        else if (div_fp_abs < 20'b00000000111001001101) temp_theta = 10'b0001010101;
        else if (div_fp_abs < 20'b00000001001100010101) temp_theta = 10'b0001010110;
        else if (div_fp_abs < 20'b00000001110010100011) temp_theta = 10'b0001010111;
        else if (div_fp_abs < 20'b00000011100101001011) temp_theta = 10'b0001011000;
        else                                            temp_theta = 10'b0001011001;
    end
    assign theta = (pos_x && pos_y) ? temp_theta : 
                    (!pos_x && pos_y) ? 10'd180 - temp_theta : 
                    (!pos_x && !pos_y) ? 10'd180 + temp_theta : 
                                          10'd360 - temp_theta;
endmodule


//1b sign, [18:8] integer, [7:0] precision
module sine_LUT(
    input  signed [9:0]  theta, 
    output signed [19:0] sine_theta_out
);
    wire signed [9:0] theta_mod90 = (theta >= 10'd0 && theta <= 10'd90) ? theta : 
        (theta > 10'd90 && theta <= 10'd180) ? 10'd180 - theta : 
        (theta > 10'd180 && theta <= 10'd270) ? theta - 10'd180 : 10'd360 - theta;
    reg signed [19:0] sine_theta;

    always @ (theta, theta_mod90) begin
        case (theta_mod90) 
            10'd0: sine_theta = 20'b00000000000000000000;
            10'd1: sine_theta = 20'b00000000000000000100;
            10'd2: sine_theta = 20'b00000000000000001000;
            10'd3: sine_theta = 20'b00000000000000001101;
            10'd4: sine_theta = 20'b00000000000000010001;
            10'd5: sine_theta = 20'b00000000000000010110;
            10'd6: sine_theta = 20'b00000000000000011010;
            10'd7: sine_theta = 20'b00000000000000011111;
            10'd8: sine_theta = 20'b00000000000000100011;
            10'd9: sine_theta = 20'b00000000000000101000;
            10'd10: sine_theta = 20'b00000000000000101100;
            10'd11: sine_theta = 20'b00000000000000110000;
            10'd12: sine_theta = 20'b00000000000000110101;
            10'd13: sine_theta = 20'b00000000000000111001;
            10'd14: sine_theta = 20'b00000000000000111101;
            10'd15: sine_theta = 20'b00000000000001000010;
            10'd16: sine_theta = 20'b00000000000001000110;
            10'd17: sine_theta = 20'b00000000000001001010;
            10'd18: sine_theta = 20'b00000000000001001111;
            10'd19: sine_theta = 20'b00000000000001010011;
            10'd20: sine_theta = 20'b00000000000001010111;
            10'd21: sine_theta = 20'b00000000000001011011;
            10'd22: sine_theta = 20'b00000000000001011111;
            10'd23: sine_theta = 20'b00000000000001100100;
            10'd24: sine_theta = 20'b00000000000001101000;
            10'd25: sine_theta = 20'b00000000000001101100;
            10'd26: sine_theta = 20'b00000000000001110000;
            10'd27: sine_theta = 20'b00000000000001110100;
            10'd28: sine_theta = 20'b00000000000001111000;
            10'd29: sine_theta = 20'b00000000000001111100;
            10'd30: sine_theta = 20'b00000000000001111111;
            10'd31: sine_theta = 20'b00000000000010000011;
            10'd32: sine_theta = 20'b00000000000010000111;
            10'd33: sine_theta = 20'b00000000000010001011;
            10'd34: sine_theta = 20'b00000000000010001111;
            10'd35: sine_theta = 20'b00000000000010010010;
            10'd36: sine_theta = 20'b00000000000010010110;
            10'd37: sine_theta = 20'b00000000000010011010;
            10'd38: sine_theta = 20'b00000000000010011101;
            10'd39: sine_theta = 20'b00000000000010100001;
            10'd40: sine_theta = 20'b00000000000010100100;
            10'd41: sine_theta = 20'b00000000000010100111;
            10'd42: sine_theta = 20'b00000000000010101011;
            10'd43: sine_theta = 20'b00000000000010101110;
            10'd44: sine_theta = 20'b00000000000010110001;
            10'd45: sine_theta = 20'b00000000000010110101;
            10'd46: sine_theta = 20'b00000000000010111000;
            10'd47: sine_theta = 20'b00000000000010111011;
            10'd48: sine_theta = 20'b00000000000010111110;
            10'd49: sine_theta = 20'b00000000000011000001;
            10'd50: sine_theta = 20'b00000000000011000100;
            10'd51: sine_theta = 20'b00000000000011000110;
            10'd52: sine_theta = 20'b00000000000011001001;
            10'd53: sine_theta = 20'b00000000000011001100;
            10'd54: sine_theta = 20'b00000000000011001111;
            10'd55: sine_theta = 20'b00000000000011010001;
            10'd56: sine_theta = 20'b00000000000011010100;
            10'd57: sine_theta = 20'b00000000000011010110;
            10'd58: sine_theta = 20'b00000000000011011001;
            10'd59: sine_theta = 20'b00000000000011011011;
            10'd60: sine_theta = 20'b00000000000011011101;
            10'd61: sine_theta = 20'b00000000000011011111;
            10'd62: sine_theta = 20'b00000000000011100010;
            10'd63: sine_theta = 20'b00000000000011100100;
            10'd64: sine_theta = 20'b00000000000011100110;
            10'd65: sine_theta = 20'b00000000000011101000;
            10'd66: sine_theta = 20'b00000000000011101001;
            10'd67: sine_theta = 20'b00000000000011101011;
            10'd68: sine_theta = 20'b00000000000011101101;
            10'd69: sine_theta = 20'b00000000000011101110;
            10'd70: sine_theta = 20'b00000000000011110000;
            10'd71: sine_theta = 20'b00000000000011110010;
            10'd72: sine_theta = 20'b00000000000011110011;
            10'd73: sine_theta = 20'b00000000000011110100;
            10'd74: sine_theta = 20'b00000000000011110110;
            10'd75: sine_theta = 20'b00000000000011110111;
            10'd76: sine_theta = 20'b00000000000011111000;
            10'd77: sine_theta = 20'b00000000000011111001;
            10'd78: sine_theta = 20'b00000000000011111010;
            10'd79: sine_theta = 20'b00000000000011111011;
            10'd80: sine_theta = 20'b00000000000011111100;
            10'd81: sine_theta = 20'b00000000000011111100;
            10'd82: sine_theta = 20'b00000000000011111101;
            10'd83: sine_theta = 20'b00000000000011111110;
            10'd84: sine_theta = 20'b00000000000011111110;
            10'd85: sine_theta = 20'b00000000000011111111;
            10'd86: sine_theta = 20'b00000000000011111111;
            10'd87: sine_theta = 20'b00000000000011111111;
            10'd88: sine_theta = 20'b00000000000011111111;
            10'd89: sine_theta = 20'b00000000000011111111;
            10'd90: sine_theta = 20'b00000000000100000000;
            default: sine_theta = 20'd0;
        endcase
    end

    assign sine_theta_out = (theta >= 10'd0 && theta <= 10'd180) ? 
                sine_theta : 20'd0 - sine_theta; 

endmodule

//1b sign, 11bit integer, 8 bit precision
//1b sign, [18:8] integer, [7:0] precision
module cosine_LUT(
    input       signed [9:0] theta,
    output signed [19:0] cos_theta_out
);
    wire signed [9:0] theta_mod90 = (theta >= 10'd0 && theta <= 10'd90) ? theta : 
        (theta > 10'd90 && theta <= 10'd180) ? 10'd180 - theta : 
        (theta > 10'd180 && theta <= 10'd270) ? theta - 10'd180 : 10'd360 - theta;

    reg signed [19:0] cos_theta;
    always @ (theta, theta_mod90) begin

        case (theta_mod90) 
            10'd0: cos_theta = 20'b00000000000100000000;
            10'd1: cos_theta = 20'b00000000000011111111;
            10'd2: cos_theta = 20'b00000000000011111111;
            10'd3: cos_theta = 20'b00000000000011111111;
            10'd4: cos_theta = 20'b00000000000011111111;
            10'd5: cos_theta = 20'b00000000000011111111;
            10'd6: cos_theta = 20'b00000000000011111110;
            10'd7: cos_theta = 20'b00000000000011111110;
            10'd8: cos_theta = 20'b00000000000011111101;
            10'd9: cos_theta = 20'b00000000000011111100;
            10'd10: cos_theta = 20'b00000000000011111100;
            10'd11: cos_theta = 20'b00000000000011111011;
            10'd12: cos_theta = 20'b00000000000011111010;
            10'd13: cos_theta = 20'b00000000000011111001;
            10'd14: cos_theta = 20'b00000000000011111000;
            10'd15: cos_theta = 20'b00000000000011110111;
            10'd16: cos_theta = 20'b00000000000011110110;
            10'd17: cos_theta = 20'b00000000000011110100;
            10'd18: cos_theta = 20'b00000000000011110011;
            10'd19: cos_theta = 20'b00000000000011110010;
            10'd20: cos_theta = 20'b00000000000011110000;
            10'd21: cos_theta = 20'b00000000000011101110;
            10'd22: cos_theta = 20'b00000000000011101101;
            10'd23: cos_theta = 20'b00000000000011101011;
            10'd24: cos_theta = 20'b00000000000011101001;
            10'd25: cos_theta = 20'b00000000000011101000;
            10'd26: cos_theta = 20'b00000000000011100110;
            10'd27: cos_theta = 20'b00000000000011100100;
            10'd28: cos_theta = 20'b00000000000011100010;
            10'd29: cos_theta = 20'b00000000000011011111;
            10'd30: cos_theta = 20'b00000000000011011101;
            10'd31: cos_theta = 20'b00000000000011011011;
            10'd32: cos_theta = 20'b00000000000011011001;
            10'd33: cos_theta = 20'b00000000000011010110;
            10'd34: cos_theta = 20'b00000000000011010100;
            10'd35: cos_theta = 20'b00000000000011010001;
            10'd36: cos_theta = 20'b00000000000011001111;
            10'd37: cos_theta = 20'b00000000000011001100;
            10'd38: cos_theta = 20'b00000000000011001001;
            10'd39: cos_theta = 20'b00000000000011000110;
            10'd40: cos_theta = 20'b00000000000011000100;
            10'd41: cos_theta = 20'b00000000000011000001;
            10'd42: cos_theta = 20'b00000000000010111110;
            10'd43: cos_theta = 20'b00000000000010111011;
            10'd44: cos_theta = 20'b00000000000010111000;
            10'd45: cos_theta = 20'b00000000000010110101;
            10'd46: cos_theta = 20'b00000000000010110001;
            10'd47: cos_theta = 20'b00000000000010101110;
            10'd48: cos_theta = 20'b00000000000010101011;
            10'd49: cos_theta = 20'b00000000000010100111;
            10'd50: cos_theta = 20'b00000000000010100100;
            10'd51: cos_theta = 20'b00000000000010100001;
            10'd52: cos_theta = 20'b00000000000010011101;
            10'd53: cos_theta = 20'b00000000000010011010;
            10'd54: cos_theta = 20'b00000000000010010110;
            10'd55: cos_theta = 20'b00000000000010010010;
            10'd56: cos_theta = 20'b00000000000010001111;
            10'd57: cos_theta = 20'b00000000000010001011;
            10'd58: cos_theta = 20'b00000000000010000111;
            10'd59: cos_theta = 20'b00000000000010000011;
            10'd60: cos_theta = 20'b00000000000010000000;
            10'd61: cos_theta = 20'b00000000000001111100;
            10'd62: cos_theta = 20'b00000000000001111000;
            10'd63: cos_theta = 20'b00000000000001110100;
            10'd64: cos_theta = 20'b00000000000001110000;
            10'd65: cos_theta = 20'b00000000000001101100;
            10'd66: cos_theta = 20'b00000000000001101000;
            10'd67: cos_theta = 20'b00000000000001100100;
            10'd68: cos_theta = 20'b00000000000001011111;
            10'd69: cos_theta = 20'b00000000000001011011;
            10'd70: cos_theta = 20'b00000000000001010111;
            10'd71: cos_theta = 20'b00000000000001010011;
            10'd72: cos_theta = 20'b00000000000001001111;
            10'd73: cos_theta = 20'b00000000000001001010;
            10'd74: cos_theta = 20'b00000000000001000110;
            10'd75: cos_theta = 20'b00000000000001000010;
            10'd76: cos_theta = 20'b00000000000000111101;
            10'd77: cos_theta = 20'b00000000000000111001;
            10'd78: cos_theta = 20'b00000000000000110101;
            10'd79: cos_theta = 20'b00000000000000110000;
            10'd80: cos_theta = 20'b00000000000000101100;
            10'd81: cos_theta = 20'b00000000000000101000;
            10'd82: cos_theta = 20'b00000000000000100011;
            10'd83: cos_theta = 20'b00000000000000011111;
            10'd84: cos_theta = 20'b00000000000000011010;
            10'd85: cos_theta = 20'b00000000000000010110;
            10'd86: cos_theta = 20'b00000000000000010001;
            10'd87: cos_theta = 20'b00000000000000001101;
            10'd88: cos_theta = 20'b00000000000000001000;
            10'd89: cos_theta = 20'b00000000000000000100;
            10'd90: cos_theta = 20'b00000000000000000000;
            default: cos_theta = 20'd0;

        endcase
    end
    assign cos_theta_out = (theta >= 10'd0 && theta <= 10'd90) || (theta > 10'd270 && theta <= 10'd360) ? 
            cos_theta : 20'd0 - cos_theta; 



endmodule

module fp_s20 (
    input signed [19:0] a, 
    input signed [19:0] b, 
    output signed [19:0] out
);
    wire [39:0] result = a * b;
    assign out = {result[39], result[26:8]};
endmodule