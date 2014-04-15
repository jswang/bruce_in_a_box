//Detects a predetermined color. 
//Using the least squares formula

//Detects green
module corner_detect
(   
    input clk,
    input reset, 
    input [7:0] r, 
    input [7:0] g, 
    input [7:0] b, 
    input [7:0] Y,
    input [7:0] Cb, 
    input [7:0] Cr,
    input [23:0] rgb_target, 
    input [7:0] threshold_Cb,
    input [7:0] threshold_Cr, 
    output reg corner_detected, 
    output [9:0] hue, 
    output [9:0] saturation, 
    output [9:0] lightness

);
    // wire [9:0] oHue, oSat, oLight;
    // assign hue = oHue;
    // assign saturation = oSat; 
    // assign lightness = oLight;
    //Get results on next rising clock edge
    // wire [9:0] hue, saturation, lightness;
    // RGBtoHSL RGB_to_HSL (
    //     .clk(clk), 
    //     .iRed(r), 
    //     .iGreen(g), 
    //     .iBlue(b), 
    //     .oHue(hue), 
    //     .oSaturation(saturation), 
    //     .oLightness(lightness)
    // );

    // wire signed [18:0] threshold = {8'd0, threshold_in};
    // wire signed [17:0] r_in, g_in, b_in;
    // wire signed [17:0] r_target, g_target, b_target;
    // wire signed [17:0] r_diff, g_diff, b_diff; 
    // wire signed [17:0] r_sqrd, g_sqrd, b_sqrd;
    // assign r_in = {10'd0, r}; 
    // assign g_in = {10'd0, g}; 
    // assign b_in = {10'd0, b}; 
    always @ (*) begin
        // if (g_in > 18'd255 - threshold && b_in < threshold && r_in < threshold) begin
        //     corner_detected = 1'b1;
        // end
        // else 
        //     corner_detected = 1'b0;
        if (Cb < threshold_Cb && Cr < threshold_Cr) begin
            corner_detected = 1'b1;
        end
        else 
            corner_detected = 1'b0;
    end
    
    // Pick certain points as my corners 
    always @ (posedge clk) begin
        if (reset) begin
            
        end
        else begin
            
        end
    end


    // assign r_target = {10'd0, rgb_target[23:16]}; 
    // assign g_target = {10'd0, rgb_target[15:8]}; 
    // assign b_target = {10'd0, rgb_target[7:0]}; 
    // assign r_diff = r_in - r_target; 
    // assign g_diff = g_in - g_target; 
    // assign b_diff = b_in - b_target; 
    // assign r_sqrd = r_diff * r_diff;
    // assign g_sqrd = g_diff * g_diff;
    // assign b_sqrd = b_diff * b_diff;

    // wire signed [18:0] sum; 
    // assign sum = r_sqrd + g_sqrd + b_sqrd;
    // assign corner_detected = sum < threshold ? 1'b1 : 1'b0;

endmodule 
