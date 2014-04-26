module fsm (
	input clk,
	input reset,
	input VGA_VS, 
    input               pixel_valid, 
	input signed [10:0] pixel_x, 
	input signed [10:0] pixel_y,
	input signed [10:0] threshold,

    input [7:0] Cb, 
    input [7:0] Cr,

	output reg unsigned [9:0]    out_top_left_x,
    output reg unsigned [9:0]    out_top_left_y,
    output reg unsigned [9:0]    out_top_right_x,
    output reg unsigned [9:0]    out_top_right_y,
    output reg unsigned [9:0]    out_bot_left_x,
    output reg unsigned [9:0]    out_bot_left_y,
    output reg unsigned [9:0]    out_bot_right_x,
    output reg unsigned [9:0]    out_bot_right_y


	);

wire falling_VGA_VS = (VGA_VS_prev && ~VGA_VS);
wire threshold_exceeded = (count_x_max > threshold || count_x_min > threshold
                         || count_y_max > threshold || count_y_min > threshold);
wire x_max_exceeded = count_x_max > threshold;
wire x_min_exceeded = count_x_min > threshold;
wire y_max_exceeded = count_y_max > threshold;
wire y_min_exceeded = count_y_min > threshold;
wire (Cb < threshold_Cb_orange && Cr > threshold_Cr_orange);
reg [3:0] state; 

localparam offset = 5;
localparam x = 0;
localparam y = 2;
localparam x_local_max = 0;
localparam x_local_min = 1;
localparam y_local_max = 1;
localparam y_local_min = 2;

localparam state_pre_init 	= 4'd0;
localparam state_init 		= 4'd1;
localparam state_orient1 	= 4'd2;
localparam state_orient2 	= 4'd3;
localparam state_orient3 	= 4'd4;
localparam state_orient4 	= 4'd5;
localparam state_orient5 	= 4'd6;
localparam state_orient6 	= 4'd7;
localparam state_orient7 	= 4'd8;
localparam state_orient8 	= 4'd9;

reg signed [10:0] x_max[0:2];
reg signed [10:0] x_min[0:2];
reg signed [10:0] y_max[0:2];
reg signed [10:0] y_min[0:2];

reg signed [10:0] count_x_max, count_x_min, count_y_max, count_y_min;
reg VGA_VS_prev;

always @ (posedge clk) begin
	VGA_VS_prev <= VGA_VS;
	if (reset) begin
		state <= state_pre_init;
		x_max[x]           		<= 11'd0; 
        x_max[y_local_max]      <= 11'd0;
        x_max[y_local_min]      <= 11'd479;

        x_min[x]           		<= 11'd639;
        x_min[y_local_max]      <= 11'd0;
        x_min[y_local_min]      <= 11'd479;

        y_max[y]          		<= 11'd0;
        y_max[x_local_max]      <= 11'd0;
        y_max[x_local_min]      <= 11'd639;

        y_min[y]          		<= 11'd479;
        y_min[x_local_max]      <= 11'd0;
        y_min[x_local_min]      <= 11'd0;

        out_top_left_x  <= 11'd0;
        out_top_left_y  <= 11'd0;
        out_top_right_x <= 11'd0;
        out_top_right_y <= 11'd0;
        out_bot_left_x  <= 11'd0;
        out_bot_left_y  <= 11'd0;
        out_bot_right_x <= 11'd0;
        out_bot_right_y <= 11'd0;

        count_x_max 	<= 11'd0;
        count_x_min 	<= 11'd0;
        count_y_max 	<= 11'd0;
        count_y_min 	<= 11'd0;
		
	end
	else begin

		if (state == state_pre_init) begin
			if (falling_VGA_VS) state <= state_init;
            else state <= state_pre_init;
		end
        else begin
            //Go through the VGA screen and find the max and min
            if (pixel_valid && pixel_x >= x_max[x]) begin
                x_max[x]        <= pixel_x; 
                if (pixel_y > x_max[y_local_max]) x_max[y_local_max] <= pixel_y;
                if (pixel_y < x_max[y_local_min]) x_max[y_local_min] <= pixel_y;
                count_x_max     <= (pixel_x == x_max[x]) ? count_x_max + 11'd1 : 11'd1;
            end

            if (pixel_valid && pixel_x <= x_min[x]) begin
                x_min[x]        <= pixel_x; 
                if (pixel_y > x_min[y_local_max]) x_min[y_local_max] <= pixel_y;
                if (pixel_y < x_min[y_local_min]) x_min[y_local_min] <= pixel_y;
                count_x_min     <= (pixel_x == x_min[x]) ? count_x_min + 11'd1 : 11'd1;
            end

            if (pixel_valid && pixel_y > y_max) begin
                y_max[y]        <= pixel_y; 
                if (pixel_x > y_max[x_local_max]) y_max[x_local_max] <= pixel_x;
                if (pixel_x < y_max[x_local_min]) y_max[x_local_min] <= pixel_x;
                count_y_max     <= (pixel_y == y_max[y]) ? count_y_max + 11'd1 : 11'd1;
            end

            if (pixel_valid && pixel_y < y_min) begin
                y_min[y]        <= pixel_y; 
                if (pixel_x > y_min[x_local_max]) y_min[x_local_max] <= pixel_x;
                if (pixel_x < y_min[x_local_min]) y_min[x_local_min] <= pixel_x;
                count_y_min     <= (pixel_y == y_min[y]) ? count_y_min + 11'd1 : 11'd1;
            end
        end

		if (falling_VGA_VS) begin
            //Reset for next frame
            x_max[x]                <= 11'd0; 
            x_max[y_local_max]      <= 11'd0;
            x_max[y_local_min]      <= 11'd479;
            x_min[x]                <= 11'd639;
            x_min[y_local_max]      <= 11'd0;
            x_min[y_local_min]      <= 11'd479;
            y_max[y]                <= 11'd0;
            y_max[x_local_max]      <= 11'd0;
            y_max[x_local_min]      <= 11'd639;
            y_min[y]                <= 11'd479;
            y_min[x_local_max]      <= 11'd0;
            y_min[x_local_min]      <= 11'd0;
            count_x_max     <= 11'd0;
            count_x_min     <= 11'd0;
            count_y_max     <= 11'd0;
            count_y_min     <= 11'd0;

            //Depending on state, assign top/bottom left/right: 
            case (state) 
                state_init: begin
                    out_top_left_x      <= top_left[x];
                    out_top_left_y      <= top_left[y];
                    out_top_right_x     <= top_right[x];
                    out_top_right_y     <= top_right[y];
                    out_bot_left_x      <= bot_left[x];
                    out_bot_left_y      <= bot_left[y];
                    out_bot_right_x     <= bot_right[x];
                    out_bot_right_y     <= bot_right[y];

                end

                state_orient1: begin
                    if (x_min_exceeded) begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_max];
                    end
                    if (x_max_exceeded) begin
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_min];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded) begin
                        out_top_left_x <= y_min[x_local_min];
                        out_top_left_y <= y_min[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                    end
                    if (y_max_exceeded) begin
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= y_max[x_local_max];
                        out_bot_right_y <= y_max[y];
                    end
                    if (!threshold_exceeded) begin
                        if x_min[y_local_min] < y_min[y]
                    end

                end

                state_orient2: begin
                    
                end

            endcase
	        //Decide where to go next based on current
            case (state) 
                //Determine initial orientation
                state_init: begin

                    if (threshold_exceeded) begin 
                    	if (bot_left[x] > top_left[x] + offset || bot_left[x] < top_left[x] - offset) begin
                    		bot_left[x] <= x_min;
                    		bot_left[y] <= ;
                    	end
                    	state <= state_orient1;
                    end
                    else                    state <= state_orient8;
                end

                state_orient1: begin
                    if (threshold_exceeded) state <= state_orient1;
                    else begin
                        if (top_left[y] < top_right[y]) state <= state_orient2;
                        else if (top_left[y] > top_right[y]) state <= state_orient8;
                    end
                end

                state_orient2: begin
                    if (threshold_exceeded) begin
                        if (top_left[y] == top_right[y]) state <= state_orient1;
                        else if (top_left[x] == top_right[x]) state <= state_orient3;
                    end
                    else state <= state_orient2;
                end

                state_orient3: begin
                    if (threshold_exceeded) state <= state_orient3;
                    else begin
                        if (top_left[x] < top_right[x]) state <= state_orient2;
                        else if (top_left[x] > top_right[x]) state <= state_orient4;
                    end
                end

                state_orient4: begin
                    if (threshold_exceeded) begin
                        if (top_left[x] == top_right[x]) state <= state_orient3;
                        else if (top_left[y] == top_right[y]) state <= state_orient5;
                    end
                    else state <= state_orient4;
                end

                state_orient5: begin
                    if (threshold_exceeded) state <= state_orient5;
                    else begin
                        if (top_left[y] < top_right[y]) state <= state_orient4;
                        else if (top_left[y] > top_right[y]) state <= state_orient6;
                    end
                end

                state_orient6: begin
                    if (threshold_exceeded) begin
                        if (top_left[y] == top_right[y]) state <= state_orient5;
                        else if (top_left[x] == top_right[x]) state <= state_orient7;
                    end
                    else state <= state_orient6;
                end

                state_orient7: begin
                    if (threshold_exceeded) state <= state_orient7;
                    else begin
                        if (top_left[x] > top_right[x]) state <= state_orient6;
                        else if (top_left[x] < top_right[x]) state <= state_orient8;
                    end
                end

                state_orient8: begin
                    if (threshold_exceeded) begin
                        if (top_left[y] == top_right[y]) state <= state_orient1;
                        else if (top_left[x] == top_right[x]) state <= state_orient7;
                    end
                    else state <= state_orient8;                        
                end
                
                default: begin
                    
                end
            endcase
        end
	end
end
endmodule