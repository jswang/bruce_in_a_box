//Detects green
module corner_detect
(   
    input clk,
    input reset, 
    input [7:0] Cb, 
    input [7:0] Cr,
    input [3:0] color_history, 
    input       color_valid, 
    input [9:0] x, 
    input [9:0] y, 
    input [7:0] threshold_Cb,
    input [7:0] threshold_Cr,
    input [1:0] threshold_history,

    output reg corner_detected, 

    output reg [3:0] updated_color_history, 
    output reg we, 
    output reg [9:0] write_x, 
    output reg [9:0] write_y
);
    reg [2:0] num_history;
    //encode # 1's in color_histor
    always @(color_history) begin
        case (color_history)
            4'b0000: num_history <= 3'd0; 
            4'b0001: num_history <= 3'd1; 
            4'b0010: num_history <= 3'd1;
            4'b0011: num_history <= 3'd2;
            4'b0100: num_history <= 3'd1;
            4'b0101: num_history <= 3'd2; 
            4'b0110: num_history <= 3'd2; 
            4'b0111: num_history <= 3'd3; 
            4'b1000: num_history <= 3'd1; 
            4'b1001: num_history <= 3'd2; 
            4'b1010: num_history <= 3'd2;
            4'b1011: num_history <= 3'd3;
            4'b1100: num_history <= 3'd2;
            4'b1101: num_history <= 3'd3; 
            4'b1110: num_history <= 3'd3; 
            4'b1111: num_history <= 3'd4;  
        endcase
    end

    always @ (posedge clk) begin
        //write the new history and determine if color detected
        if (Cb < threshold_Cb && Cr < threshold_Cr && num_history > threshold_history) begin
            corner_detected             <= 1'b1;
            we                          <= 1'b1;
            updated_color_history[3:1]  <= color_history[2:0];
            updated_color_history[0]    <= (Cb < threshold_Cb && Cr < threshold_Cr);
            write_x                     <= x; 
            write_y                     <= y;
        end
        else begin
            corner_detected             <= 1'b0;
            we                          <= 1'b1;
            updated_color_history[3:1]  <= color_history[2:0];
            updated_color_history[0]    <= (Cb < threshold_Cb && Cr < threshold_Cr);
            write_x                     <= x; 
            write_y                     <= y;
        end
        


    end



    // always @ (posedge clk) begin
    //     if (Cb < threshold_Cb && Cr < threshold_Cr) begin
    //         corner_detected <= 1'b1;
    //     end
    //     else begin
    //         corner_detected <= 1'b0;
    //     end

    // end
endmodule 
    //Corners: 
    /**
        edge case: perfectly aligned square
            1: topmost and leftmost

        otherwise: 
            1: topmost
            2: rightmost
            3: bottomost
            4: leftmost
    
    Find the left most, right most, up, down coordinates
    If this pixel is green:
        read from sram and write back the current value
        if it has been green for the past 4 frames: 
            consider for min/maxing

    Determine where corners are
    if (area around ideal corners > threshold * #green_pixels) {
        use perfect case: (left, up), (left, down), (right, up), (right, down)
    }
    else {
        use original edge coordinates: (left, ), (right, ), ( , up), ( , down)
    }

    must keep track of all of the pixels marked as green. see if portion is ok

    */