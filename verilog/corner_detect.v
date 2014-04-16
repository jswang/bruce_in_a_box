//Detects green
module corner_detect
(   
    input clk,
    input reset, 
    input [7:0] Cb, 
    input [7:0] Cr,
    input [9:0] x, 
    input [9:0] y, 
    input [7:0] threshold_Cb,
    input [7:0] threshold_Cr, 
    output reg corner_detected

);

    always @ (posedge clk) begin
        if (Cb < threshold_Cb && Cr < threshold_Cr) begin
            corner_detected <= 1'b1;
        end
        else begin
            corner_detected <= 1'b0;
        end

    end
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