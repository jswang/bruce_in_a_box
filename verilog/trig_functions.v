module fp_s20 (
    input signed [19:0] a, 
    input signed [19:0] b, 
    output signed [19:0] out
);
    wire [39:0] result = a * b;
    assign out = {result[39], result[26:8]};
endmodule

module arctan_LUT(
    input signed [11:0] quotient,  //quotient and remainder are positive
    input signed [11:0] remainder,  
    input               sign_x, 
    input               sign_y, 
    input signed [9:0]  theta
);
    reg signed [9:0] temp_theta;
    always @ (quotient, remainder) begin
        case({quotient, remainder})


        default: temp_theta = 10'd0;
        endcase
    end
endmodule


//1b sign, [18:8] integer, [7:0] precision
module sine_LUT(
    input  signed [9:0]  theta, 
    output signed [19:0] sine_theta_out
);
    wire signed [9:0] theta_mod90 = (theta >= 10'd0 && theta <= 10'd90) ? theta : 
        (theta > 10'd90 && theta <= 10'd180) ? 10'd180 - theta : 
        (theta > 10'd180 && theta <= 10'd270) ? 10'd270 - theta : 10'd360 - theta;
    assign sine_theta_out = (theta >= 10'd0 && theta <= 10'd180) ? 
                    sine_theta : 20'd0 - sine_theta; 

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
endmodule

//1b sign, 11bit integer, 8 bit precision
//1b sign, [18:8] integer, [7:0] precision
module cosine_LUT(
    input       signed [9:0] theta,
    output signed [19:0] cos_theta_out
);
    wire signed [9:0] theta_mod90 = (theta >= 10'd0 && theta <= 10'd90) ? theta : 
        (theta > 10'd90 && theta <= 10'd180) ? 10'd180 - theta : 
        (theta > 10'd180 && theta <= 10'd270) ? 10'd270 - theta : 10'd360 - theta;
    assign cos_theta_out = (theta >= 10'd0 && theta <= 10'd90) || (theta > 10'd270 && theta <= 10'd360) ? 
                    cos_theta : 20'd0 - cos_theta; 

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


endmodule