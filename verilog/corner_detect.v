//Detects a predetermined color. 
//Using the least squares formula


module corner_detect
(   
    input clk,
    input reset, 
    input [7:0] r, 
    input [7:0] g, 
    input [7:0] b, 
    input [23:0] rgb_target, 
    input [9:0] threshold_in, 
    output reg corner_detected
);

    
    wire signed [18:0] threshold = {8'd0, threshold_in};

    wire signed [17:0] r_in, g_in, b_in;
    wire signed [17:0] r_target, g_target, b_target;
    wire signed [17:0] r_diff, g_diff, b_diff; 
    wire signed [17:0] r_sqrd, g_sqrd, b_sqrd;
    assign r_in = {10'd0, r}; 
    assign g_in = {10'd0, g}; 
    assign b_in = {10'd0, b}; 
    always @ (*) begin
        if ((r_in - g_in) > 50 && (r_in - b_in) > 50 && r_in > threshold_in) begin
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
            //if i detect the color I want and I'm near an edge, I know that 
            //I have the border of my piece of paper
            //Grab the corners via comparison
            if (corner_detected) begin 

            end
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
