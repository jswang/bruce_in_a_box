module fsm (
	input clk,
	input reset,
	input VGA_VS, 
    input               pixel_valid, 
	input unsigned [9:0] pixel_x, 
	input unsigned [9:0] pixel_y,
	input unsigned [9:0] threshold,

	output reg unsigned [9:0]    out_top_left_x,
    output reg unsigned [9:0]    out_top_left_y,
    output reg unsigned [9:0]    out_top_right_x,
    output reg unsigned [9:0]    out_top_right_y,
    output reg unsigned [9:0]    out_bot_left_x,
    output reg unsigned [9:0]    out_bot_left_y,
    output reg unsigned [9:0]    out_bot_right_x,
    output reg unsigned [9:0]    out_bot_right_y, 

    output reg [3:0] state, 
    output[3:0] thresh_flags


	);
assign thresh_flags[3] = x_max_exceeded;
assign thresh_flags[2] = x_min_exceeded;
assign thresh_flags[1] = y_max_exceeded;
assign thresh_flags[0] = y_min_exceeded;

wire falling_VGA_VS = (VGA_VS_prev && ~VGA_VS);
wire threshold_exceeded = (count_x_max > threshold || count_x_min > threshold
                         || count_y_max > threshold || count_y_min > threshold);
wire x_max_exceeded = count_x_max > threshold;
wire x_min_exceeded = count_x_min > threshold;
wire y_max_exceeded = count_y_max > threshold;
wire y_min_exceeded = count_y_min > threshold;

localparam offset = 5;
localparam x = 0;
localparam y = 2;
localparam x_local_max = 0;
localparam x_local_min = 1;
localparam y_local_max = 1;
localparam y_local_min = 2;

localparam state_pre_init 	= 4'd9;
localparam state_init 		= 4'd10;
localparam state_orient1 	= 4'd1;
localparam state_orient2 	= 4'd2;
localparam state_orient3 	= 4'd3;
localparam state_orient4 	= 4'd4;
localparam state_orient5 	= 4'd5;
localparam state_orient6 	= 4'd6;
localparam state_orient7 	= 4'd7;
localparam state_orient8 	= 4'd8;

reg unsigned [9:0] x_max[0:2];
reg unsigned [9:0] x_min[0:2];
reg unsigned [9:0] y_max[0:2];
reg unsigned [9:0] y_min[0:2];

reg unsigned [9:0] count_x_max, count_x_min, count_y_max, count_y_min;
reg VGA_VS_prev;

reg unsigned [9:0]    top_left_x_prev;
reg unsigned [9:0]    top_left_y_prev;
reg unsigned [9:0]    top_right_x_prev;
reg unsigned [9:0]    top_right_y_prev;
reg unsigned [9:0]    bot_left_x_prev;
reg unsigned [9:0]    bot_left_y_prev;
reg unsigned [9:0]    bot_right_x_prev;
reg unsigned [9:0]    bot_right_y_prev;

always @ (posedge clk) begin
	VGA_VS_prev <= VGA_VS;
	if (reset) begin
		state <= state_pre_init;
		x_max[x]           		<= 10'd0; 
        x_max[y_local_max]      <= 10'd0;
        x_max[y_local_min]      <= 10'd479;

        x_min[x]           		<= 10'd639;
        x_min[y_local_max]      <= 10'd0;
        x_min[y_local_min]      <= 10'd479;

        y_max[y]          		<= 10'd0;
        y_max[x_local_max]      <= 10'd0;
        y_max[x_local_min]      <= 10'd639;

        y_min[y]          		<= 10'd479;
        y_min[x_local_max]      <= 10'd0;
        y_min[x_local_min]      <= 10'd639;

        out_top_left_x  <= 10'd0;
        out_top_left_y  <= 10'd0;
        out_top_right_x <= 10'd0;
        out_top_right_y <= 10'd0;
        out_bot_left_x  <= 10'd0;
        out_bot_left_y  <= 10'd0;
        out_bot_right_x <= 10'd0;
        out_bot_right_y <= 10'd0;
        top_left_x_prev  <= 10'd0;
        top_left_y_prev  <= 10'd0;
        top_right_x_prev <= 10'd0;
        top_right_y_prev <= 10'd0;
        bot_left_x_prev  <= 10'd0;
        bot_left_y_prev  <= 10'd0;
        bot_right_x_prev <= 10'd0;
        bot_right_y_prev <= 10'd0;

        count_x_max 	<= 10'd0;
        count_x_min 	<= 10'd0;
        count_y_max 	<= 10'd0;
        count_y_min 	<= 10'd0;
		
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
                count_x_max     <= (pixel_x == x_max[x]) ? count_x_max + 10'd1 : 10'd1;
            end

            if (pixel_valid && pixel_x <= x_min[x]) begin
                x_min[x]        <= pixel_x; 
                if (pixel_y > x_min[y_local_max]) x_min[y_local_max] <= pixel_y;
                if (pixel_y < x_min[y_local_min]) x_min[y_local_min] <= pixel_y;
                count_x_min     <= (pixel_x == x_min[x]) ? count_x_min + 10'd1 : 10'd1;
            end

            if (pixel_valid && pixel_y >= y_max[y]) begin
                y_max[y]        <= pixel_y; 
                if (pixel_x > y_max[x_local_max]) y_max[x_local_max] <= pixel_x;
                if (pixel_x < y_max[x_local_min]) y_max[x_local_min] <= pixel_x;
                count_y_max     <= (pixel_y == y_max[y]) ? count_y_max + 10'd1 : 10'd1;
            end

            if (pixel_valid && pixel_y <= y_min[y]) begin
                y_min[y]        <= pixel_y; 
                if (pixel_x > y_min[x_local_max]) y_min[x_local_max] <= pixel_x;
                if (pixel_x < y_min[x_local_min]) y_min[x_local_min] <= pixel_x;
                count_y_min     <= (pixel_y == y_min[y]) ? count_y_min + 10'd1 : 10'd1;
            end
        end

		if (falling_VGA_VS) begin
            //Reset for next frame
            x_max[x]                <= 10'd0; 
            x_max[y_local_max]      <= 10'd0;
            x_max[y_local_min]      <= 10'd479;
            x_min[x]                <= 10'd639;
            x_min[y_local_max]      <= 10'd0;
            x_min[y_local_min]      <= 10'd479;
            y_max[y]                <= 10'd0;
            y_max[x_local_max]      <= 10'd0;
            y_max[x_local_min]      <= 10'd639;
            y_min[y]                <= 10'd479;
            y_min[x_local_max]      <= 10'd0;
            y_min[x_local_min]      <= 10'd639;
            count_x_max             <= 10'd0;
            count_x_min             <= 10'd0;
            count_y_max             <= 10'd0;
            count_y_min             <= 10'd0;

            top_left_x_prev         <= out_top_left_x;
            top_left_y_prev         <= out_top_left_y;
            top_right_x_prev        <= out_top_right_x;
            top_right_y_prev        <= out_top_right_y;
            bot_left_x_prev         <= out_bot_left_x;
            bot_left_y_prev         <= out_bot_left_y;
            bot_right_x_prev        <= out_bot_right_x;
            bot_right_y_prev        <= out_bot_right_y;

            //Depending on state, assign top/bottom left/right: 
            case (state) 
                state_init: begin
                    //Set up the correct corners according to which thresholds were exceeded
                    if (x_min_exceeded || x_max_exceeded) begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_max];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_min];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded || y_max_exceeded) begin
                        out_top_left_x <= y_min[x_local_min];
                        out_top_left_y <= y_min[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= y_max[x_local_max];
                        out_bot_right_y <= y_max[y];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    //State transition
                    if (threshold_exceeded) state <= state_orient1;
                    else state <= state_orient8;
                end

                state_orient1: begin
                    if (x_min_exceeded || x_max_exceeded) begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_max];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_min];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded || y_max_exceeded) begin
                        out_top_left_x <= y_min[x_local_min];
                        out_top_left_y <= y_min[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= y_max[x_local_max];
                        out_bot_right_y <= y_max[y];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    if (threshold_exceeded) state <= state_orient1;
                    else begin
                        if (x_min[y_local_min] < top_left_y_prev)       
                            state <= state_orient8;
                        else if (x_min[y_local_min] > top_left_y_prev)  
                            state <= state_orient2;
                    end
                end

                state_orient2: begin
                    if (x_min_exceeded || x_max_exceeded) begin
                        out_bot_left_x  <= x_min[x];
                        out_bot_left_y  <= x_min[y_local_min];
                        out_bot_right_x <= x_min[x];
                        out_bot_right_y <= x_min[y_local_max];
                        out_top_left_x  <= x_max[x];
                        out_top_left_y  <= x_max[y_local_min];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    else begin
                        out_bot_left_x  <= x_min[x];
                        out_bot_left_y  <= x_min[y_local_min];
                        out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_left_x  <= y_min[x_local_max];
                        out_top_left_y  <= y_min[y];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded || y_max_exceeded) begin
                        out_bot_left_x <= y_min[x_local_min];
                        out_bot_left_y <= y_min[y];
                        out_top_left_x <= y_min[x_local_max];
                        out_top_left_y <= y_min[y];
                        out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_right_x <= y_max[x_local_max];
                        out_top_right_y <= y_max[y];
                    end
                    else begin
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_min];
                        out_top_left_x <= y_min[x_local_max];
                        out_top_left_y <= y_min[y];
                        out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    if (threshold_exceeded) begin
                        if (x_min[x] < bot_left_x_prev) state <= state_orient1;
                        else if (x_min[x] > bot_left_x_prev) state <= state_orient3;
                    end 
                    else state <= state_orient2;
                end

                state_orient3: begin
                    if (x_min_exceeded || x_max_exceeded) begin
                        out_bot_left_x  <= x_min[x];
                        out_bot_left_y  <= x_min[y_local_min];
                        out_bot_right_x  <= x_min[x];
                        out_bot_right_y  <= x_min[y_local_max];
                        out_top_left_x  <= x_max[x];
                        out_top_left_y  <= x_max[y_local_min];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    else begin
                        out_bot_left_x  <= x_min[x];
                        out_bot_left_y  <= x_min[y_local_min];
                        out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_left_x  <= y_min[x_local_max];
                        out_top_left_y  <= y_min[y];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded || y_max_exceeded) begin
                        out_bot_left_x <= y_min[x_local_min];
                        out_bot_left_y <= y_min[y];
                        out_top_left_x <= y_min[x_local_max];
                        out_top_left_y <= y_min[y];
                         out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_right_x <= y_max[x_local_max];
                        out_top_right_y <= y_max[y];
                    end
                    else begin
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_min];
                        out_top_left_x <= y_min[x_local_max];
                        out_top_left_y <= y_min[y];
                        out_bot_right_x <= y_max[x_local_min];
                        out_bot_right_y <= y_max[y];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_max];
                    end
                    if (threshold_exceeded) state <= state_orient3;
                    else begin
                        if (x_min[x] < bot_left_x_prev) state <= state_orient2;
                        else if (x_min[x] > bot_left_x_prev) state <= state_orient4;
                    end
                end

                state_orient8: begin
                    if (x_min_exceeded || x_max_exceeded) begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= x_min[x];
                        out_bot_left_y <= x_min[y_local_max];
                        out_top_right_x <= x_max[x];
                        out_top_right_y <= x_max[y_local_min];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end
                    if (y_min_exceeded || y_max_exceeded) begin
                        out_top_left_x <= y_min[x_local_min];
                        out_top_left_y <= y_min[y];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= y_max[x_local_max];
                        out_bot_right_y <= y_max[y];
                    end
                    else begin
                        out_top_left_x <= x_min[x];
                        out_top_left_y <= x_min[y_local_min];
                        out_top_right_x <= y_min[x_local_max];
                        out_top_right_y <= y_min[y];
                        out_bot_left_x <= y_max[x_local_min];
                        out_bot_left_y <= y_max[y];
                        out_bot_right_x <= x_max[x];
                        out_bot_right_y <= x_max[y_local_max];
                    end

                    if (threshold_exceeded) begin
                        if (x_min[y_local_min] < top_left_y_prev) 
                            state <= state_orient7;
                        else if (x_min[y_local_min] > top_left_y_prev)
                            state <= state_orient1;
                    end
                    else state <= state_orient8;
                end

                default: begin
                    state <= state_init;
                end
            endcase
        end
	end
end
endmodule