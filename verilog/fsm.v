module fsm (
	input clk,
	input reset,
	input VGA_VS, 
	input unsigned [9:0] pixel_x, 
	input unsigned [9:0] pixel_y, 
	input 		pixel_valid, 
	input unsigned [9:0] threshold,

	output reg unsigned [9:0]    out_top_left_x,
    output reg unsigned [9:0]    out_top_left_y,
    output reg unsigned [9:0]    out_top_right_x,
    output reg unsigned [9:0]    out_top_right_y,
    output reg unsigned [9:0]    out_bot_left_x,
    output reg unsigned [9:0]    out_bot_left_y,
    output reg unsigned [9:0]    out_bot_right_x,
    output reg unsigned [9:0]    out_bot_right_y,


	);

wire falling_VGA_VS = (VGA_VS_prev && ~VGA_VS);
wire threshold_exceeded = (count_x_max > threshold || count_x_min > threshold
                         || count_y_max > threshold || count_y_min > threshold);
reg [3:0] state; 

localparam x = 0;
localparam y = 1;

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


reg unsigned [9:0] x_max, x_min, y_max, y_min;
reg unsigned [9:0] top_left  [0:1];
reg unsigned [9:0] top_right [0:1];
reg unsigned [9:0] bot_left  [0:1];
reg unsigned [9:0] bot_right [0:1];

reg unsigned [9:0] count_x_max, count_x_min, count_y_max, count_y_min;
always @ (posedge clk) begin
	VGA_VS_prev <= VGA_VS;
	if (reset) begin
		state <= state_pre_init;
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

        out_top_left_x  <= 10'd0;
        out_top_left_y  <= 10'd0;
        out_top_right_x <= 10'd0;
        out_top_right_y <= 10'd0;
        out_bot_left_x  <= 10'd0;
        out_bot_left_y  <= 10'd0;
        out_bot_right_x <= 10'd0;
        out_bot_right_y <= 10'd0;

        count_x_max 	<= 10'd0;
        count_x_min 	<= 10'd0;
        count_y_max 	<= 10'd0;
        count_y_min 	<= 10'd0;
		
	end
	else begin
        if (state == state_pre_init) begin
            if (falling_VGA_VS) 
                state <= state_init;
            else 
                state <= state_pre_init;
        end
        //Go through the VGA screen and find the max and min
        else begin
            if (pixel_valid && pixel_x > x_max) begin
                x_max           <= pixel_x; 
                bot_right[x]    <= pixel_x;
                bot_right[y]    <= pixel_y;
                count_x_max     <= 10'd1;
            end
            else if (pixel_valid && pixel_x == x_max) begin
                bot_right[x]    <= pixel_x;
                bot_right[y]    <= pixel_y;
                count_x_max     <= count_x_max + 10'd1;
            end

            if (pixel_valid && pixel_x < x_min) begin
                x_min           <= pixel_x; 
                top_left[x]     <= pixel_x;
                top_left[y]     <= pixel_y;
                count_x_min     <= 10'd1;
            end
            else if (pixel_valid && pixel_x == x_min) begin
                top_left[x]     <= pixel_x;
                top_left[y]     <= pixel_y;
                count_x_min     <= count_x_min + 10'd1;
            end

            if (pixel_valid && pixel_y > y_max) begin
                y_max           <= pixel_y; 
                bot_left[x]     <= pixel_x;
                bot_left[y]     <= pixel_y;
                count_y_max     <= 10'd1;
            end
            else if (pixel_valid && pixel_y == y_max) begin
                bot_left[x]     <= pixel_x;
                bot_left[y]     <= pixel_y;
                count_y_max     <= count_y_max + 10'd1;
            end

            if (pixel_valid && pixel_y < y_min) begin
                y_min           <= pixel_y; 
                top_right[x]    <= pixel_x;
                top_right[y]    <= pixel_y;
                count_y_min     <= 10'd1;
            end
            else if (pixel_valid && pixel_y == y_min) begin
                top_right[x]    <= pixel_x;
                top_right[y]    <= pixel_y;
                count_y_min     <= count_y_min + 10'd1;
            end
            //Clear for a new screen
            if (falling_VGA_VS) begin
                out_top_left_x      <= top_left[x];
                out_top_left_y      <= top_left[y];
                out_top_right_x     <= top_right[x];
                out_top_right_y     <= top_right[y];
                out_bot_left_x      <= bot_left[x];
                out_bot_left_y      <= bot_left[y];
                out_bot_right_x     <= bot_right[x];
                out_bot_right_y     <= bot_right[y];

                top_left[x]     <= 10'd0;
                top_left[y]     <= 10'd0;
                top_right[x]    <= 10'd0;
                top_right[y]    <= 10'd0;
                bot_left[x]     <= 10'd0;
                bot_left[y]     <= 10'd0;
                bot_right[x]    <= 10'd0;
                bot_right[y]    <= 10'd0;

                //Decide where to go next based on current
                case (state) 
                    //Determine initial orientation
                    state_init: begin
                        if (threshold_exceeded) state <= state_orient1;
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
end
