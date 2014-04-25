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

    output reg [2:0]    color_detected, 

    output  [9:0]    top_left_prev_x,
    output  [9:0]    top_left_prev_y,
    output  [9:0]    top_right_prev_x,
    output  [9:0]    top_right_prev_y,
    output  [9:0]    bot_left_prev_x,
    output  [9:0]    bot_left_prev_y,
    output  [9:0]    bot_right_prev_x,
    output  [9:0]    bot_right_prev_y,

    output reg [3:0]    updated_color_history, 
    output reg          we, 
    output reg [18:0]   write_addr
);
    localparam x = 0;
    localparam y = 1;
    localparam NONE = 3'd0;
    localparam TOP_LEFT = 3'd1;
    localparam TOP_RIGHT = 3'd2;
    localparam BOTTOM_LEFT = 3'd3; 
    localparam BOTTOM_RIGHT = 3'd4;
    localparam GREEN         = 3'd5;
    
    


    reg [2:0] num_history;

    reg unsigned [9:0] x_max, x_min, y_max, y_min;
    reg unsigned [9:0] top_left  [0:1];
    reg unsigned [9:0] top_right [0:1];
    reg unsigned [9:0] bot_left  [0:1];
    reg unsigned [9:0] bot_right [0:1];

    reg unsigned [9:0] x_max_prev, x_min_prev, y_max_prev, y_min_prev;
    reg unsigned [9:0] top_left_prev  [0:1];
    reg unsigned [9:0] top_right_prev [0:1];
    reg unsigned [9:0] bot_left_prev  [0:1];
    reg unsigned [9:0] bot_right_prev [0:1];

    reg VGA_VS_prev;

    wire signed [10:0] x_max_signed, x_min_signed, y_max_signed, y_min_signed; 
    assign x_max_signed = {1'b0, x_max};
    assign x_min_signed = {1'b0, x_min};
    assign y_max_signed = {1'b0, y_max};
    assign y_min_signed = {1'b0, y_min};

    assign top_left_prev_x = top_left_prev[x];
    assign top_left_prev_y = top_left_prev[y];
    assign top_right_prev_x = top_right_prev[x];
    assign top_right_prev_y = top_right_prev[y];
    assign bot_left_prev_x = bot_left_prev[x];
    assign bot_left_prev_y = bot_left_prev[y];
    assign bot_right_prev_x = bot_right_prev[x];
    assign bot_right_prev_y = bot_right_prev[y];

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
        VGA_VS_prev <= VGA_VS;
        if (reset) begin
            x_max_prev           <= 10'd0; 
            x_min_prev           <= 10'd639;
            y_max_prev           <= 10'd0;
            y_min_prev           <= 10'd479;
            top_left_prev[x]     <= 10'd0;
            top_left_prev[y]     <= 10'd0;
            top_right_prev[x]    <= 10'd0;
            top_right_prev[y]    <= 10'd0;
            bot_left_prev[x]     <= 10'd0;
            bot_left_prev[y]     <= 10'd0;
            bot_right_prev[x]    <= 10'd0;
            bot_right_prev[y]    <= 10'd0;
            x_max           <= 10'd0; 
            x_min           <= 10'd639;
            y_max           <= 10'd0;
            y_min           <= 10'd479;
            top_left[x]     <= 10'd0;
            top_left[y]     <= 10'd0;
            top_right[x]    <= 10'd0;
            top_right[y]    <= 10'd0;
            bot_left[x]     <= 10'd0;
            bot_left[y]     <= 10'd0;
            bot_right[x]    <= 10'd0;
            bot_right[y]    <= 10'd0;
            color_detected <= NONE;
        end
        else begin
            //Falling edge of VS
            if (VGA_VS_prev && ~VGA_VS) begin

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

                //If top left y too close to top right y = same y, max/min x
                //if top left x too close to bottom left x = same x,  max/min y

                //if bot right y too close to bottom left y = same y, max/min x
                //if bot right x too close to top right x = same x, max/min y
                // if ( (top_left[y] < top_right[y] && top_right[y] - top_left[y] <= threshold_y_diff)
                //     || (top_right[y] < top_left[y] && top_left[y] - top_right[y] <= threshold_y_diff)
                //     || (top_left[y] == top_right[y]) ) begin
                //         top_left_prev[x] <= x_min;
                //         top_right_prev[x] <= x_max;
                //         top_left_prev[y] <= y_min;
                //         top_right_prev[y] <= y_min;
                //     end

                // if ( (top_left[x] < bot_left[x] && bot_left[x] - top_left[x] <= threshold_x_diff)
                //     || (bot_left[x] < top_left[x] && top_left[x] - bot_left[x] <= threshold_x_diff)
                //     || (top_left[x] == bot_left[x]) ) begin
                //         top_left_prev[x] <= x_min;
                //         bot_left_prev[x] <= x_min;
                //         top_left_prev[y] <= y_min;
                //         bot_left_prev[y] <= y_max;
                //     end
                    

                // if ((bot_right[y] < bot_left[y] && bot_left[y] - bot_right[y] <= threshold_y_diff)
                //     || (bot_left[y] < bot_right[y] && bot_right[y] - bot_left[y] <= threshold_y_diff)
                //     || (bot_right[y] == bot_left[y]) ) begin
                //         bot_right_prev[x] <= x_max;
                //         bot_left_prev[x] <= x_min;
                //         bot_right_prev[y] <= y_max;
                //         bot_left_prev[y] <= y_max;
                //     end

                // if ((bot_right[x] < top_right[x] && top_right[x] - bot_right[x] <= threshold_x_diff)
                //     || (top_right[x] < bot_right[x] && bot_right[x] - top_right[x] <= threshold_x_diff)
                //     || (bot_right[x] == top_right[x]) ) begin
                //         bot_right_prev[x] <= x_max;
                //         top_right_prev[x] <= x_max;
                //         bot_right_prev[y] <= y_max;
                //         top_right_prev[y] <= y_min;
                //     end

                //Reset for next frame of VGA screen
                x_max           <= 10'd0; 
                x_min           <= 10'd639;
                y_max           <= 10'd0;
                y_min           <= 10'd479;
                top_left[x]     <= 10'd0;
                top_left[y]     <= 10'd0;
                top_right[x]    <= 10'd0;
                top_right[y]    <= 10'd0;
                bot_left[x]     <= 10'd0;
                bot_left[y]     <= 10'd0;
                bot_right[x]    <= 10'd0;
                bot_right[y]    <= 10'd0;
            end
            //otherwise keep updating
            else begin
                if (Cb < threshold_Cb && Cr < threshold_Cr && num_history > threshold_history) begin
                    color_detected              <= GREEN;
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
                        // color_detected <= BOTTOM_RIGHT;
                    end 
                    //Most left -> New top left
                    if (read_x <= x_min && read_x < 10'd640) begin
                        x_min <= read_x;
                        top_left[x] <= read_x;
                        top_left[y] <= read_y;
                        // color_detected <= TOP_LEFT;
                    end
                    // lowest -> New bottom left
                    if (read_y >= y_max && read_y < 10'd480) begin
                        y_max <= read_y;
                        bot_left[x] <= read_x;
                        bot_left[y] <= read_y;
                        // color_detected <= BOTTOM_LEFT;
                    end 
                    //highest -> New top right
                    if (read_y <= y_min && read_y < 10'd480) begin
                        y_min <= read_y;
                        top_right[x] <= read_x;
                        top_right[y] <= read_y;
                        // color_detected <= TOP_RIGHT;
                    end
                    
                    //Assign corner detected based on the previous cycle's information
                    if (read_x == top_left_prev[x] && read_y == top_left_prev[y]) 
                        color_detected <= TOP_LEFT;
                    else if (read_x == top_right_prev[x] && read_y == top_right_prev[y]) 
                        color_detected <= TOP_RIGHT;
                    else if (read_x == bot_left_prev[x] && read_y == bot_left_prev[y]) 
                        color_detected <= BOTTOM_LEFT;
                    else if (read_x == bot_right_prev[x] && read_y == bot_right_prev[y]) 
                        color_detected <= BOTTOM_RIGHT;
                end

                else begin
                    color_detected              <= NONE;
                    updated_color_history[3:1]  <= color_history[2:0];
                    updated_color_history[0]    <= (Cb < threshold_Cb && Cr < threshold_Cr);
                    write_addr                  <= read_addr;
                    we                          <= 1'b1;
                end
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