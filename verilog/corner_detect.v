//Detects green
module corner_detect
(   
    input               clk,
    input               reset, 
    input               VGA_VS,
    input [7:0]         Cb, 
    input [7:0]         Cr,
    input [3:0]         color_history, 
    input               color_valid, 
    input [18:0]        read_addr, 
    input unsigned [9:0]         read_x, 
    input unsigned [9:0]         read_y,
    input [7:0]         threshold_Cb,
    input [7:0]         threshold_Cr,
    input [1:0]         threshold_history,

    output reg [2:0]    corner_detected, 

    output reg [3:0]    updated_color_history, 
    output reg          we, 
    output reg [18:0]   write_addr, 
    output reg [7:0]    test_led
);
    localparam x = 0;
    localparam y = 1;
    localparam NONE = 3'd0;
    localparam TOP_LEFT = 3'd1;
    localparam TOP_RIGHT = 3'd2;
    localparam BOTTOM_LEFT = 3'd3; 
    localparam BOTTOM_RIGHT = 3'd4;
    localparam PINK         = 3'd5;

    reg [2:0] num_history;

    reg [9:0] x_max, x_min, y_max, y_min;
    reg [9:0] top_left  [0:1];
    reg [9:0] top_right [0:1];
    reg [9:0] bot_left  [0:1];
    reg [9:0] bot_right [0:1];

    reg [9:0] x_max_prev, x_min_prev, y_max_prev, y_min_prev;
    reg [9:0] top_left_prev  [0:1];
    reg [9:0] top_right_prev [0:1];
    reg [9:0] bot_left_prev  [0:1];
    reg [9:0] bot_right_prev [0:1];


    always @(negedge VGA_VS) begin
        x_max_prev           <= x_max; 
        x_min_prev           <= x_min;
        y_max_prev           <= y_max;
        y_min_prev           <= y_min;
        top_left_prev[x]     <= top_left[x];
        top_left_prev[y]     <= top_left[y];
        top_right_prev[x]    <= top_right[x];
        top_right_prev[y]    <= top_right[y];
        bot_left_prev[x]     <= bot_left[x];
        bot_left_prev[y]     <= bot_left[y];
        bot_right_prev[x]    <= bot_right[x];
        bot_right_prev[y]    <= bot_right[y];
        x_max           <= 10'd0; 
        x_min           <= 10'd0;
        y_max           <= 10'd0;
        y_min           <= 10'd0;
        top_left[x]     <= 10'd0;
        top_left[y]     <= 10'd0;
        top_right[x]    <= 10'd0;
        top_right[y]    <= 10'd0;
        bot_left[x]     <= 10'd0;
        bot_left[y]     <= 10'd0;
        bot_right[x]    <= 10'd0;
        bot_right[y]    <= 10'd0;
    end
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
    //Update History and current color_detected
    always @ (posedge clk) begin
        if (reset) begin
            corner_detected <= NONE;
        end
        else begin
            if (Cb < threshold_Cb && Cr < threshold_Cr && num_history > threshold_history) begin
                corner_detected             <= PINK;
                updated_color_history[3:1]  <= color_history[2:0];
                updated_color_history[0]    <= (Cb < threshold_Cb && Cr < threshold_Cr);
                write_addr                  <= read_addr;
                we                          <= 1'b1;
                //If I am the highest, I am new top right
                //If I am the lowest, I am the new bottom left
                //If I am the most left, I am the new top left
                //If I am the most right, I am the new bottom right

                //Most right -> New bottom right
                if (read_x >= x_max && read_x < 10'd640) begin
                    x_max <= read_x; 
                    bot_right[x] <= read_x;
                    bot_right[y] <= read_y;
                    // corner_detected <= BOTTOM_RIGHT;
                end 
                //Most left -> New top left
                if (read_x <= x_min && read_x < 10'd640) begin
                    x_min <= read_x;
                    top_left[x] <= read_x;
                    top_left[y] <= read_y;
                    // corner_detected <= TOP_LEFT;
                end
                // lowest -> New bottom left
                if (read_y >= y_max && read_y < 10'd480) begin
                    y_max <= read_y;
                    bot_left[x] <= read_x;
                    bot_left[y] <= read_y;
                    // corner_detected <= BOTTOM_LEFT;
                end 
                //highest -> New top right
                if (read_y <= y_min && read_y < 10'd480) begin
                    y_min <= read_y;
                    top_right[x] <= read_x;
                    top_right[y] <= read_y;
                    // corner_detected <= TOP_RIGHT;
                end
                
                if (read_x == top_left_prev[x] && read_y == top_left_prev[y]) 
                    corner_detected <= TOP_LEFT;
                else if (read_x == top_right_prev[x] && read_y == top_right_prev[y]) 
                    corner_detected <= TOP_RIGHT;
                else if (read_x == bot_left_prev[x] && read_y == bot_left_prev[y]) 
                    corner_detected <= BOTTOM_LEFT;
                else if (read_x == bot_right_prev[x] && read_y == bot_right_prev[y]) 
                    corner_detected <= BOTTOM_RIGHT;
            end

            else begin
                corner_detected             <= NONE;
                updated_color_history[3:1]  <= color_history[2:0];
                updated_color_history[0]    <= (Cb < threshold_Cb && Cr < threshold_Cr);
                write_addr                  <= read_addr;
                we                          <= 1'b1;
            end
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