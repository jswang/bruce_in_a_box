module fsm (
    input clk,
    input reset,
    input VGA_VS, 
    input               pixel_valid, 
    input signed [10:0] pixel_x, 
    input signed [10:0] pixel_y,
    input signed [10:0] threshold,
    // input unsigned [10:0] movement_threshold,

    output reg signed [10:0]    out_top_left_x,
    output reg signed [10:0]    out_top_left_y,
    output reg signed [10:0]    out_top_right_x,
    output reg signed [10:0]    out_top_right_y,
    output reg signed [10:0]    out_bot_left_x,
    output reg signed [10:0]    out_bot_left_y,
    output reg signed [10:0]    out_bot_right_x,
    output reg signed [10:0]    out_bot_right_y, 

    output reg [3:0] state, 
    output reg [3:0] thresh_exceeded_flags, //test
    output reg [15:0] thresh_flags, //test
    output reg [10:0] count,  //test

    output reg [9:0] test_x_max, 
    output reg [9:0] test_x_min,
    output reg [9:0] test_y_max, 
    output reg [9:0] test_y_min, 

    output reg [9:0] test_x_max_ylocalmin,
    output reg [9:0] test_x_max_ylocalmax,
    output reg [9:0] test_x_min_ylocalmin,
    output reg [9:0] test_x_min_ylocalmax,
    output reg [9:0] test_y_max_xlocalmin,
    output reg [9:0] test_y_max_xlocalmax,
    output reg [9:0] test_y_min_xlocalmin,
    output reg [9:0] test_y_min_xlocalmax


    );
// assign test_x_max = x_max[x][9:0]; 
// assign test_x_min = x_min[x][9:0]; 
// assign test_y_max = y_max[y][9:0]; 
// assign test_y_min = y_min[y][9:0]; 

// wire signed [10:0] threshold = 11'd80;

//Signal wires
wire falling_VGA_VS = (VGA_VS_prev && ~VGA_VS);
wire x_max_exceeded = (count_x_max_offset > threshold);
wire x_min_exceeded = (count_x_min_offset > threshold);
wire y_max_exceeded = (count_y_max_offset > threshold);
wire y_min_exceeded = (count_y_min_offset > threshold);

//Parameters
localparam offset = 5;
localparam x = 0;
localparam y = 2;
localparam x_local_max = 0;
localparam x_local_min = 1;
localparam y_local_max = 1;
localparam y_local_min = 2;
localparam state_pre_init   = 4'd0;
localparam state_init       = 4'd1;
localparam state_rotating   = 4'd2;
localparam state_bad       = 4'd3;

//Internal registers
reg VGA_VS_prev;

reg signed [10:0] x_max[0:2];
reg signed [10:0] x_min[0:2];
reg signed [10:0] y_max[0:2];
reg signed [10:0] y_min[0:2];
reg signed [10:0] count_x_max, count_x_min, count_y_max, count_y_min;

reg signed [10:0] x_max_prev[0:2];
reg signed [10:0] x_min_prev[0:2];
reg signed [10:0] y_max_prev[0:2];
reg signed [10:0] y_min_prev[0:2];


reg signed [10:0] x_max_offset[0:2];
reg signed [10:0] x_min_offset[0:2];
reg signed [10:0] y_max_offset[0:2];
reg signed [10:0] y_min_offset[0:2];
reg signed [10:0] count_x_max_offset, count_x_min_offset, count_y_max_offset, count_y_min_offset;

reg signed [10:0]    top_left_x_prev;
reg signed [10:0]    top_left_y_prev;
reg signed [10:0]    top_right_x_prev;
reg signed [10:0]    top_right_y_prev;
reg signed [10:0]    bot_left_x_prev;
reg signed [10:0]    bot_left_y_prev;
reg signed [10:0]    bot_right_x_prev;
reg signed [10:0]    bot_right_y_prev;


//Distance calculations: xthreshold exceeded. so current TL = (x_min[x], x_min[y_local_min])
wire signed [10:0] x_thresh_TL_x = (x_min[x]           - top_left_x_prev);
wire signed [10:0] x_thresh_TL_y = (x_min[y_local_min] - top_left_y_prev);
wire signed [10:0] x_thresh_TR_x = (x_min[x]           - top_right_x_prev);
wire signed [10:0] x_thresh_TR_y = (x_min[y_local_min] - top_right_y_prev);
wire signed [10:0] x_thresh_BL_x = (x_min[x]           - bot_left_x_prev);
wire signed [10:0] x_thresh_BL_y = (x_min[y_local_min] - bot_left_y_prev);
wire signed [10:0] x_thresh_BR_x = (x_min[x]           - bot_right_x_prev);
wire signed [10:0] x_thresh_BR_y = (x_min[y_local_min] - bot_right_y_prev);

wire unsigned [21:0] x_thresh_TL_x2, x_thresh_TL_y2, x_thresh_TR_x2, x_thresh_TR_y2, 
                     x_thresh_BL_x2, x_thresh_BL_y2, x_thresh_BR_x2, x_thresh_BR_y2;
wire unsigned [22:0] x_thresh_TL_sum = x_thresh_TL_x2 + x_thresh_TL_y2;
wire unsigned [22:0] x_thresh_TR_sum = x_thresh_TR_x2 + x_thresh_TR_y2;
wire unsigned [22:0] x_thresh_BL_sum = x_thresh_BL_x2 + x_thresh_BL_y2;
wire unsigned [22:0] x_thresh_BR_sum = x_thresh_BR_x2 + x_thresh_BR_y2;

squarer_s11 square_x_thresh_TL_x(x_thresh_TL_x, x_thresh_TL_x2);
squarer_s11 square_x_thresh_TL_y(x_thresh_TL_y, x_thresh_TL_y2);
squarer_s11 square_x_thresh_TR_x(x_thresh_TR_x, x_thresh_TR_x2);
squarer_s11 square_x_thresh_TR_y(x_thresh_TR_y, x_thresh_TR_y2);
squarer_s11 square_x_thresh_BL_x(x_thresh_BL_x, x_thresh_BL_x2);
squarer_s11 square_x_thresh_BL_y(x_thresh_BL_y, x_thresh_BL_y2);
squarer_s11 square_x_thresh_BR_x(x_thresh_BR_x, x_thresh_BR_x2);
squarer_s11 square_x_thresh_BR_y(x_thresh_BR_y, x_thresh_BR_y2);

wire x_thresh_TL = ((x_thresh_TL_sum < x_thresh_TR_sum)
                && (x_thresh_TL_sum < x_thresh_BL_sum) 
                && (x_thresh_TL_sum < x_thresh_BR_sum)); 
wire x_thresh_TR = ((x_thresh_TR_sum < x_thresh_TL_sum)
                && (x_thresh_TR_sum < x_thresh_BL_sum) 
                && (x_thresh_TR_sum < x_thresh_BR_sum)); 
wire x_thresh_BL = ((x_thresh_BL_sum < x_thresh_TL_sum)
                && (x_thresh_BL_sum < x_thresh_TR_sum) 
                && (x_thresh_BL_sum < x_thresh_BR_sum)); 
wire x_thresh_BR = ((x_thresh_BR_sum < x_thresh_TL_sum)
                && (x_thresh_BR_sum < x_thresh_TR_sum) 
                && (x_thresh_BR_sum < x_thresh_BL_sum)); 
// wire x_thresh_TL = (x_thresh_TL_sum < movement_threshold); 
// wire x_thresh_TR = (x_thresh_TR_sum < movement_threshold); 
// wire x_thresh_BL = (x_thresh_BL_sum < movement_threshold);
// wire x_thresh_BR = (x_thresh_BR_sum < movement_threshold);


//Distance calculations: y_thresh exceeded. So current TL = (y_min[x_local_min], y_min[y])
wire signed [10:0] y_thresh_TL_x = (y_min[x_local_min] - top_left_x_prev);
wire signed [10:0] y_thresh_TL_y = (y_min[y]           - top_left_y_prev);
wire signed [10:0] y_thresh_TR_x = (y_min[x_local_min] - top_right_x_prev);
wire signed [10:0] y_thresh_TR_y = (y_min[y]           - top_right_y_prev);
wire signed [10:0] y_thresh_BL_x = (y_min[x_local_min] - bot_left_x_prev);
wire signed [10:0] y_thresh_BL_y = (y_min[y]           - bot_left_y_prev);
wire signed [10:0] y_thresh_BR_x = (y_min[x_local_min] - bot_right_x_prev);
wire signed [10:0] y_thresh_BR_y = (y_min[y]           - bot_right_y_prev);

wire unsigned [21:0] y_thresh_TL_x2, y_thresh_TL_y2, y_thresh_TR_x2, y_thresh_TR_y2, 
                     y_thresh_BL_x2, y_thresh_BL_y2, y_thresh_BR_x2, y_thresh_BR_y2;
wire unsigned [22:0] y_thresh_TL_sum = y_thresh_TL_x2 + y_thresh_TL_y2;
wire unsigned [22:0] y_thresh_TR_sum = y_thresh_TR_x2 + y_thresh_TR_y2;
wire unsigned [22:0] y_thresh_BL_sum = y_thresh_BL_x2 + y_thresh_BL_y2;
wire unsigned [22:0] y_thresh_BR_sum = y_thresh_BR_x2 + y_thresh_BR_y2;

squarer_s11 square_y_thresh_TL_x(y_thresh_TL_x, y_thresh_TL_x2);
squarer_s11 square_y_thresh_TL_y(y_thresh_TL_y, y_thresh_TL_y2);
squarer_s11 square_y_thresh_TR_x(y_thresh_TR_x, y_thresh_TR_x2);
squarer_s11 square_y_thresh_TR_y(y_thresh_TR_y, y_thresh_TR_y2);
squarer_s11 square_y_thresh_BL_x(y_thresh_BL_x, y_thresh_BL_x2);
squarer_s11 square_y_thresh_BL_y(y_thresh_BL_y, y_thresh_BL_y2);
squarer_s11 square_y_thresh_BR_x(y_thresh_BR_x, y_thresh_BR_x2);
squarer_s11 square_y_thresh_BR_y(y_thresh_BR_y, y_thresh_BR_y2);

wire y_thresh_TL = ((y_thresh_TL_sum < y_thresh_TR_sum)
                && (y_thresh_TL_sum < y_thresh_BL_sum) 
                && (y_thresh_TL_sum < y_thresh_BR_sum)); 
wire y_thresh_TR = ((y_thresh_TR_sum < y_thresh_TL_sum)
                && (y_thresh_TR_sum < y_thresh_BL_sum) 
                && (y_thresh_TR_sum < y_thresh_BR_sum)); 
wire y_thresh_BL = ((y_thresh_BL_sum < y_thresh_TL_sum)
                && (y_thresh_BL_sum < y_thresh_TR_sum) 
                && (y_thresh_BL_sum < y_thresh_BR_sum)); 
wire y_thresh_BR = ((y_thresh_BR_sum < y_thresh_TL_sum)
                && (y_thresh_BR_sum < y_thresh_TR_sum) 
                && (y_thresh_BR_sum < y_thresh_BL_sum)); 
// wire y_thresh_TL = (y_thresh_TL_sum < movement_threshold); 
// wire y_thresh_TR = (y_thresh_TR_sum < movement_threshold); 
// wire y_thresh_BL = (y_thresh_BL_sum < movement_threshold);
// wire y_thresh_BR = (y_thresh_BR_sum < movement_threshold);


//Distance calculations: xy_threshold both exceeded. So current TL = (x_min[x], y_min[y])
wire signed [10:0] xy_thresh_TL_x = (x_min[x] - top_left_x_prev);
wire signed [10:0] xy_thresh_TL_y = (y_min[y] - top_left_y_prev);
wire signed [10:0] xy_thresh_TR_x = (x_min[x] - top_right_x_prev);
wire signed [10:0] xy_thresh_TR_y = (y_min[y] - top_right_y_prev);
wire signed [10:0] xy_thresh_BL_x = (x_min[x] - bot_left_x_prev);
wire signed [10:0] xy_thresh_BL_y = (y_min[y] - bot_left_y_prev);
wire signed [10:0] xy_thresh_BR_x = (x_min[x] - bot_right_x_prev);
wire signed [10:0] xy_thresh_BR_y = (y_min[y] - bot_right_y_prev);

wire unsigned [21:0] xy_thresh_TL_x2, xy_thresh_TL_y2, xy_thresh_TR_x2, xy_thresh_TR_y2, 
                     xy_thresh_BL_x2, xy_thresh_BL_y2, xy_thresh_BR_x2, xy_thresh_BR_y2;
wire unsigned [22:0] xy_thresh_TL_sum = xy_thresh_TL_x2 + xy_thresh_TL_y2;
wire unsigned [22:0] xy_thresh_TR_sum = xy_thresh_TR_x2 + xy_thresh_TR_y2;
wire unsigned [22:0] xy_thresh_BL_sum = xy_thresh_BL_x2 + xy_thresh_BL_y2;
wire unsigned [22:0] xy_thresh_BR_sum = xy_thresh_BR_x2 + xy_thresh_BR_y2;

squarer_s11 square_xy_thresh_TL_x(xy_thresh_TL_x, xy_thresh_TL_x2);
squarer_s11 square_xy_thresh_TL_y(xy_thresh_TL_y, xy_thresh_TL_y2);
squarer_s11 square_xy_thresh_TR_x(xy_thresh_TR_x, xy_thresh_TR_x2);
squarer_s11 square_xy_thresh_TR_y(xy_thresh_TR_y, xy_thresh_TR_y2);
squarer_s11 square_xy_thresh_BL_x(xy_thresh_BL_x, xy_thresh_BL_x2);
squarer_s11 square_xy_thresh_BL_y(xy_thresh_BL_y, xy_thresh_BL_y2);
squarer_s11 square_xy_thresh_BR_x(xy_thresh_BR_x, xy_thresh_BR_x2);
squarer_s11 square_xy_thresh_BR_y(xy_thresh_BR_y, xy_thresh_BR_y2);

wire xy_thresh_TL = ((xy_thresh_TL_sum < xy_thresh_TR_sum)
                && (xy_thresh_TL_sum < xy_thresh_BL_sum) 
                && (xy_thresh_TL_sum < xy_thresh_BR_sum)); 
wire xy_thresh_TR = ((xy_thresh_TR_sum < xy_thresh_TL_sum)
                && (xy_thresh_TR_sum < xy_thresh_BL_sum) 
                && (xy_thresh_TR_sum < xy_thresh_BR_sum)); 
wire xy_thresh_BL = ((xy_thresh_BL_sum < xy_thresh_TL_sum)
                && (xy_thresh_BL_sum < xy_thresh_TR_sum) 
                && (xy_thresh_BL_sum < xy_thresh_BR_sum)); 
wire xy_thresh_BR = ((xy_thresh_BR_sum < xy_thresh_TL_sum)
                && (xy_thresh_BR_sum < xy_thresh_TR_sum) 
                && (xy_thresh_BR_sum < xy_thresh_BL_sum)); 
// wire xy_thresh_TL = (xy_thresh_TL_sum < movement_threshold); 
// wire xy_thresh_TR = (xy_thresh_TR_sum < movement_threshold); 
// wire xy_thresh_BL = (xy_thresh_BL_sum < movement_threshold);
// wire xy_thresh_BR = (xy_thresh_BR_sum < movement_threshold);


//Distance calculations: no_threshold exceeded. so current TL = (x_min[x], x_min[y_local_min])
wire signed [10:0] no_thresh_TL_x = (x_min[x]           - top_left_x_prev);
wire signed [10:0] no_thresh_TL_y = (x_min[y_local_min] - top_left_y_prev);
wire signed [10:0] no_thresh_TR_x = (x_min[x]           - top_right_x_prev);
wire signed [10:0] no_thresh_TR_y = (x_min[y_local_min] - top_right_y_prev);
wire signed [10:0] no_thresh_BL_x = (x_min[x]           - bot_left_x_prev);
wire signed [10:0] no_thresh_BL_y = (x_min[y_local_min] - bot_left_y_prev);
wire signed [10:0] no_thresh_BR_x = (x_min[x]           - bot_right_x_prev);
wire signed [10:0] no_thresh_BR_y = (x_min[y_local_min] - bot_right_y_prev);

wire unsigned [21:0] no_thresh_TL_x2, no_thresh_TL_y2, no_thresh_TR_x2, no_thresh_TR_y2, 
                     no_thresh_BL_x2, no_thresh_BL_y2, no_thresh_BR_x2, no_thresh_BR_y2;
wire unsigned [22:0] no_thresh_TL_sum = no_thresh_TL_x2 + no_thresh_TL_y2;
wire unsigned [22:0] no_thresh_TR_sum = no_thresh_TR_x2 + no_thresh_TR_y2;
wire unsigned [22:0] no_thresh_BL_sum = no_thresh_BL_x2 + no_thresh_BL_y2;
wire unsigned [22:0] no_thresh_BR_sum = no_thresh_BR_x2 + no_thresh_BR_y2;

squarer_s11 square_no_thresh_TL_x(no_thresh_TL_x, no_thresh_TL_x2);
squarer_s11 square_no_thresh_TL_y(no_thresh_TL_y, no_thresh_TL_y2);
squarer_s11 square_no_thresh_TR_x(no_thresh_TR_x, no_thresh_TR_x2);
squarer_s11 square_no_thresh_TR_y(no_thresh_TR_y, no_thresh_TR_y2);
squarer_s11 square_no_thresh_BL_x(no_thresh_BL_x, no_thresh_BL_x2);
squarer_s11 square_no_thresh_BL_y(no_thresh_BL_y, no_thresh_BL_y2);
squarer_s11 square_no_thresh_BR_x(no_thresh_BR_x, no_thresh_BR_x2);
squarer_s11 square_no_thresh_BR_y(no_thresh_BR_y, no_thresh_BR_y2);

wire no_thresh_TL = ((no_thresh_TL_sum < no_thresh_TR_sum)
                && (no_thresh_TL_sum < no_thresh_BL_sum) 
                && (no_thresh_TL_sum < no_thresh_BR_sum)); 
wire no_thresh_TR = ((no_thresh_TR_sum < no_thresh_TL_sum)
                && (no_thresh_TR_sum < no_thresh_BL_sum) 
                && (no_thresh_TR_sum < no_thresh_BR_sum)); 
wire no_thresh_BL = ((no_thresh_BL_sum < no_thresh_TL_sum)
                && (no_thresh_BL_sum < no_thresh_TR_sum) 
                && (no_thresh_BL_sum < no_thresh_BR_sum)); 
wire no_thresh_BR = ((no_thresh_BR_sum < no_thresh_TL_sum)
                && (no_thresh_BR_sum < no_thresh_TR_sum) 
                && (no_thresh_BR_sum < no_thresh_BL_sum)); 
// wire no_thresh_TL = (no_thresh_TL_sum < movement_threshold); 
// wire no_thresh_TR = (no_thresh_TR_sum < movement_threshold); 
// wire no_thresh_BL = (no_thresh_BL_sum < movement_threshold);
// wire no_thresh_BR = (no_thresh_BR_sum < movement_threshold);



always @ (posedge clk) begin
    VGA_VS_prev <= VGA_VS;

    if (reset) begin
        state <= state_pre_init;
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
        y_min[x_local_min]      <= 11'd639;

        out_top_left_x  <= 11'd0;
        out_top_left_y  <= 11'd0;
        out_top_right_x <= 11'd0;
        out_top_right_y <= 11'd0;
        out_bot_left_x  <= 11'd0;
        out_bot_left_y  <= 11'd0;
        out_bot_right_x <= 11'd0;
        out_bot_right_y <= 11'd0;
        top_left_x_prev  <= 11'd0;
        top_left_y_prev  <= 11'd0;
        top_right_x_prev <= 11'd0;
        top_right_y_prev <= 11'd0;
        bot_left_x_prev  <= 11'd0;
        bot_left_y_prev  <= 11'd0;
        bot_right_x_prev <= 11'd0;
        bot_right_y_prev <= 11'd0;

        count_x_max     <= 11'd0;
        count_x_min     <= 11'd0;
        count_y_max     <= 11'd0;
        count_y_min     <= 11'd0;   

        test_x_max <= 10'd0; 
        test_x_min <= 10'd0; 
        test_y_max <= 10'd0; 
        test_y_min <= 10'd0;    
        test_y_max_xlocalmin <= 10'd0;
        test_y_max_xlocalmax <= 10'd0;

        x_max_prev[x]                <= 11'd0; 
        x_max_prev[y_local_max]      <= 11'd0;
        x_max_prev[y_local_min]      <= 11'd479;
        x_min_prev[x]                <= 11'd639;
        x_min_prev[y_local_max]      <= 11'd0;
        x_min_prev[y_local_min]      <= 11'd479;
        y_max_prev[y]                <= 11'd0;
        y_max_prev[x_local_max]      <= 11'd0;
        y_max_prev[x_local_min]      <= 11'd639;
        y_min_prev[y]                <= 11'd479;
        y_min_prev[x_local_max]      <= 11'd0;
        y_min_prev[x_local_min]      <= 11'd639;

        x_max_offset[x]                <= 11'd0; 
        x_max_offset[y_local_max]      <= 11'd0;
        x_max_offset[y_local_min]      <= 11'd479;
        x_min_offset[x]                <= 11'd639;
        x_min_offset[y_local_max]      <= 11'd0;
        x_min_offset[y_local_min]      <= 11'd479;
        y_max_offset[y]                <= 11'd0;
        y_max_offset[x_local_max]      <= 11'd0;
        y_max_offset[x_local_min]      <= 11'd639;
        y_min_offset[y]                <= 11'd479;
        y_min_offset[x_local_max]      <= 11'd0;
        y_min_offset[x_local_min]      <= 11'd639;
        count_x_max_offset           <= 11'd0;
        count_x_min_offset           <= 11'd0;
        count_y_max_offset           <= 11'd0;
        count_y_min_offset           <= 11'd0;  
    end

    else begin

        if (state == state_pre_init) begin
            if (falling_VGA_VS) state <= state_init;
            else state <= state_pre_init;
        end
        //Go through the VGA screen (only when VGA_VS high) and find the max and min
        else begin
            if (VGA_VS) begin
                //find the current max and min
                if (pixel_valid && (pixel_x > x_max[x])) begin
                    x_max[x]            <= pixel_x; 
                    x_max[y_local_max]  <= pixel_y;
                    x_max[y_local_min]  <= pixel_y;
                    count_x_max         <=  11'd1;
                end

                else if (pixel_valid && (pixel_x == x_max[x])) begin
                    if (pixel_y > x_max[y_local_max]) x_max[y_local_max] <= pixel_y;
                    if (pixel_y < x_max[y_local_min]) x_max[y_local_min] <= pixel_y;
                    count_x_max         <= count_x_max + 11'd1;
                end

                if (pixel_valid && pixel_x < x_min[x]) begin
                    x_min[x]            <= pixel_x; 
                    x_min[y_local_max]  <= pixel_y;
                    x_min[y_local_min]  <= pixel_y;
                    count_x_min         <= 11'd1;
                end
                else if (pixel_valid && (pixel_x == x_min[x])) begin
                    if (pixel_y > x_min[y_local_max]) x_min[y_local_max] <= pixel_y;
                    if (pixel_y < x_min[y_local_min]) x_min[y_local_min] <= pixel_y;
                    count_x_min         <= count_x_min + 11'd1;
                end

                if (pixel_valid && (pixel_y > y_max[y])) begin
                    y_max[y]            <= pixel_y; 
                    y_max[x_local_max]  <= pixel_x;
                    y_max[x_local_min]  <= pixel_x;
                    count_y_max         <= 11'd1;
                end
                else if (pixel_valid && (pixel_y == y_max[y])) begin
                    if (pixel_x > y_max[x_local_max]) y_max[x_local_max] <= pixel_x;
                    if (pixel_x < y_max[x_local_min]) y_max[x_local_min] <= pixel_x;
                    count_y_max     <= count_y_max + 11'd1;
                end

                if (pixel_valid && (pixel_y < y_min[y])) begin
                    y_min[y]            <= pixel_y; 
                    y_min[x_local_max]  <= pixel_x;
                    y_min[x_local_min]  <= pixel_x;
                    count_y_min         <= 11'd1;
                end
                else if (pixel_valid && (pixel_y == y_min[y])) begin
                    if (pixel_x > y_min[x_local_max]) y_min[x_local_max] <= pixel_x;
                    if (pixel_x < y_min[x_local_min]) y_min[x_local_min] <= pixel_x;
                    count_y_min     <= count_y_min + 11'd1;
                end

                //find the +-5 offset from previous
                if (pixel_valid && (pixel_x == x_max_prev[x] - 5)) begin
                    x_max_offset[x]            <= pixel_x; 
                    if (pixel_y > x_max_offset[y_local_max]) x_max_offset[y_local_max]  <= pixel_y;
                    if (pixel_y < x_max_offset[y_local_min]) x_max_offset[y_local_min]  <= pixel_y;
                    count_x_max_offset         <= count_x_max_offset + 11'd1;
                end
                if (pixel_valid && (pixel_x == x_min_prev[x] + 5)) begin
                    x_min_offset[x]            <= pixel_x; 
                    if (pixel_y > x_min_offset[y_local_max]) x_min_offset[y_local_max] <= pixel_y;
                    if (pixel_y < x_min_offset[y_local_min]) x_min_offset[y_local_min] <= pixel_y;
                    count_x_min_offset        <= count_x_min_offset + 11'd1;
                end
                if (pixel_valid && (pixel_y == y_max_prev[y] - 5)) begin
                    y_max_offset[y]            <= pixel_y; 
                    if (pixel_x > y_max_offset[x_local_max]) y_max_offset[x_local_max] <= pixel_x;
                    if (pixel_x < y_max_offset[x_local_min]) y_max_offset[x_local_min] <= pixel_x;
                    count_y_max_offset     <= count_y_max_offset + 11'd1;
                end
                if (pixel_valid && (pixel_y == y_min_prev[y] + 5)) begin
                    y_min_offset[y]            <= pixel_y; 
                    if (pixel_x > y_min_offset[x_local_max]) y_min_offset[x_local_max] <= pixel_x;
                    if (pixel_x < y_min_offset[x_local_min]) y_min_offset[x_local_min] <= pixel_x;
                    count_y_min_offset     <= count_y_min_offset + 11'd1;
                end

            end
            if (falling_VGA_VS) begin

                //Test outputs
                test_x_max <= x_max_offset[x][9:0];
                test_x_min <= x_min_offset[x][9:0];
                test_y_max <= y_max_offset[y][9:0];
                test_y_min <= y_min_offset[y][9:0];

                test_x_max_ylocalmin <= x_max_offset[y_local_min][9:0];
                test_x_max_ylocalmax <= x_max_offset[y_local_max][9:0];
                test_x_min_ylocalmin <= x_min_offset[y_local_min][9:0];
                test_x_min_ylocalmax <= x_min_offset[y_local_max][9:0];

                test_y_max_xlocalmin <= y_max_offset[x_local_min][9:0];
                test_y_max_xlocalmax <= y_max_offset[x_local_max][9:0];
                test_y_min_xlocalmin <= y_min_offset[x_local_min][9:0];
                test_y_min_xlocalmax <= y_min_offset[x_local_max][9:0];



                thresh_flags[15] <= x_thresh_TL;
                thresh_flags[14] <= x_thresh_TR;
                thresh_flags[13] <= x_thresh_BL;
                thresh_flags[12] <= x_thresh_BR;
                thresh_flags[11] <= y_thresh_TL;
                thresh_flags[10] <= y_thresh_TR;
                thresh_flags[9] <= y_thresh_BL;
                thresh_flags[8] <= y_thresh_BR;
                thresh_flags[7] <= xy_thresh_TL;
                thresh_flags[6] <= xy_thresh_TR;
                thresh_flags[5] <= xy_thresh_BL;
                thresh_flags[4] <= xy_thresh_BR;
                thresh_flags[3] <= no_thresh_TL;
                thresh_flags[2] <= no_thresh_TR;
                thresh_flags[1] <= no_thresh_BL;
                thresh_flags[0] <= no_thresh_BR;
                thresh_exceeded_flags[3] <= x_max_exceeded;
                thresh_exceeded_flags[2] <= x_min_exceeded;
                thresh_exceeded_flags[1] <= y_max_exceeded;
                thresh_exceeded_flags[0] <= y_min_exceeded;
                count <= count_y_max;

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
                y_min[x_local_min]      <= 11'd639;


                count_x_max             <= 11'd0;
                count_x_min             <= 11'd0;
                count_y_max             <= 11'd0;
                count_y_min             <= 11'd0;

                count_x_max_offset             <= 11'd0;
                count_x_min_offset             <= 11'd0;
                count_y_max_offset             <= 11'd0;
                count_y_min_offset             <= 11'd0;

                top_left_x_prev         <= out_top_left_x;
                top_left_y_prev         <= out_top_left_y;
                top_right_x_prev        <= out_top_right_x;
                top_right_y_prev        <= out_top_right_y;
                bot_left_x_prev         <= out_bot_left_x;
                bot_left_y_prev         <= out_bot_left_y;
                bot_right_x_prev        <= out_bot_right_x;
                bot_right_y_prev        <= out_bot_right_y;

                x_max_prev[x]           <= x_max[x]; 
                x_max_prev[y_local_max] <= x_max[y_local_max];
                x_max_prev[y_local_min] <= x_max[y_local_min];
                x_min_prev[x]           <= x_min[x];
                x_min_prev[y_local_max] <= x_min[y_local_max];
                x_min_prev[y_local_min] <= x_min[y_local_min];
                y_max_prev[y]           <= y_max[y];
                y_max_prev[x_local_max] <= y_max[x_local_max];
                y_max_prev[x_local_min] <= y_max[x_local_min];
                y_min_prev[y]           <= y_min[y];
                y_min_prev[x_local_max] <= y_min[x_local_max];
                y_min_prev[x_local_min] <= y_min[x_local_min];
                
                x_max_offset[x]                <= 11'd0; 
                x_max_offset[y_local_max]      <= 11'd0;
                x_max_offset[y_local_min]      <= 11'd479;
                x_min_offset[x]                <= 11'd639;
                x_min_offset[y_local_max]      <= 11'd0;
                x_min_offset[y_local_min]      <= 11'd479;
                y_max_offset[y]                <= 11'd0;
                y_max_offset[x_local_max]      <= 11'd0;
                y_max_offset[x_local_min]      <= 11'd639;
                y_min_offset[y]                <= 11'd479;
                y_min_offset[x_local_max]      <= 11'd0;
                y_min_offset[x_local_min]      <= 11'd639;

                //Depending on state, assign top/bottom left/right: 
                case (state) 
                    state_init: begin
                        //X thresh exceeded, y thresh not
                        if ((x_min_exceeded || x_max_exceeded) && !(y_min_exceeded || y_max_exceeded)) begin
                            out_top_left_x  <= x_min_offset[x];
                            out_top_left_y  <= x_min_offset[y_local_min];
                            out_bot_left_x  <= x_min_offset[x];
                            out_bot_left_y  <= x_min_offset[y_local_max];
                            out_top_right_x <= x_max_offset[x];
                            out_top_right_y <= x_max_offset[y_local_min];
                            out_bot_right_x <= x_max_offset[x];
                            out_bot_right_y <= x_max_offset[y_local_max];
                        end
                        // y thresh exceeded, x thresh not
                        else if ((y_min_exceeded || y_max_exceeded) && !(x_min_exceeded || x_max_exceeded)) begin
                            out_top_left_x  <= y_min_offset[x_local_min];
                            out_top_left_y  <= y_min_offset[y];
                            out_top_right_x <= y_min_offset[x_local_max];
                            out_top_right_y <= y_min_offset[y];
                            out_bot_left_x  <= y_max_offset[x_local_min];
                            out_bot_left_y  <= y_max_offset[y];
                            out_bot_right_x <= y_max_offset[x_local_max];
                            out_bot_right_y <= y_max_offset[y];
                        end
                        // x and y thresh exceeded
                        else if ((x_min_exceeded || x_max_exceeded) && (y_min_exceeded || y_max_exceeded)) begin
                            out_top_left_x  <= x_min_offset[x];
                            out_top_left_y  <= y_min_offset[y];
                            out_top_right_x <= x_max_offset[x];
                            out_top_right_y <= y_min_offset[y];
                            out_bot_left_x  <= x_min_offset[x];
                            out_bot_left_y  <= y_max_offset[y];
                            out_bot_right_x <= x_max_offset[x];
                            out_bot_right_y <= y_max_offset[y];
                        end
                        //no thresh exceeded
                        else begin
                            out_top_left_x  <= x_min_offset[x];
                            out_top_left_y  <= x_min_offset[y_local_min];
                            out_top_right_x <= y_min_offset[x_local_min];
                            out_top_right_y <= y_min_offset[y];
                            out_bot_left_x  <= y_max_offset[x_local_min];
                            out_bot_left_y  <= y_max_offset[y];
                            out_bot_right_x <= x_max_offset[x];
                            out_bot_right_y <= x_max_offset[y_local_max];
                        end
                        state <= state_rotating;
                    end

                    state_rotating: begin

                        //X thresh exceeded, y thresh not
                        if ((x_min_exceeded || x_max_exceeded) && !(y_min_exceeded || y_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            // if (x_thresh_TL) begin
                                out_top_left_x  <= x_min_offset[x];
                                out_top_left_y  <= x_min_offset[y_local_min];
                                out_top_right_x <= x_max_offset[x];
                                out_top_right_y <= x_max_offset[y_local_min];
                                out_bot_right_x <= x_max_offset[x];
                                out_bot_right_y <= x_max_offset[y_local_max];
                                out_bot_left_x  <= x_min_offset[x];
                                out_bot_left_y  <= x_min_offset[y_local_max];
                            // end

                            // //if the coordinates of xmin are closest to the old top right: 
                            // else if (x_thresh_TR) begin
                            //     out_top_right_x <= x_min[x];
                            //     out_top_right_y <= x_min[y_local_min];
                            //     out_bot_right_x <= x_max[x];
                            //     out_bot_right_y <= x_max[y_local_min];
                            //     out_bot_left_x  <= x_max[x];
                            //     out_bot_left_y  <= x_max[y_local_max];
                            //     out_top_left_x  <= x_min[x];
                            //     out_top_left_y  <= x_min[y_local_max];
                            // end
                            
                            // //if the coordinates of xmin are closest to the old bot left: 
                            // else if (x_thresh_BL) begin
                            //     out_bot_left_x  <= x_min[x];
                            //     out_bot_left_y  <= x_min[y_local_min];
                            //     out_top_left_x  <= x_max[x];
                            //     out_top_left_y  <= x_max[y_local_min];
                            //     out_top_right_x <= x_max[x];
                            //     out_top_right_y <= x_max[y_local_max];
                            //     out_bot_right_x <= x_min[x];
                            //     out_bot_right_y <= x_min[y_local_max];
                            // end

                            // //if the coordinates of xmin are closest to the old bot right:
                            // else if (x_thresh_BR) begin
                            //     out_bot_right_x <= x_min[x];
                            //     out_bot_right_y <= x_min[y_local_min];
                            //     out_bot_left_x  <= x_max[x];
                            //     out_bot_left_y  <= x_max[y_local_min];
                            //     out_top_left_x  <= x_max[x];
                            //     out_top_left_y  <= x_max[y_local_max];
                            //     out_top_right_x <= x_min[x];
                            //     out_top_right_y <= x_min[y_local_max];
                            // end
                            // else begin 
                            //     out_top_left_x  <= out_top_left_x; 
                            //     out_top_left_y  <= out_top_left_y; 
                            //     out_top_right_x <= out_top_right_x; 
                            //     out_top_right_y <= out_top_right_y; 
                            //     out_bot_right_x <= out_bot_right_x; 
                            //     out_bot_right_y <= out_bot_right_y; 
                            //     out_bot_left_x  <= out_bot_left_x; 
                            //     out_bot_left_y  <= out_bot_left_y; 
                            // end
                        end
                        // y thresh exceeded, x thresh not
                        else if ((y_min_exceeded || y_max_exceeded) && !(x_min_exceeded || x_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            // if (y_thresh_TL) begin
                                out_top_left_x  <= y_min_offset[x_local_min];
                                out_top_left_y  <= y_min_offset[y];
                                out_top_right_x <= y_min_offset[x_local_max];
                                out_top_right_y <= y_min_offset[y];
                                out_bot_right_x <= y_max_offset[x_local_max];
                                out_bot_right_y <= y_max_offset[y];
                                out_bot_left_x  <= y_max_offset[x_local_min];
                                out_bot_left_y  <= y_max_offset[y];
                            // end
                            // else if (y_thresh_TR) begin
                            //     out_top_right_x <= y_min[x_local_min];
                            //     out_top_right_y <= y_min[y];
                            //     out_bot_right_x <= y_min[x_local_max];
                            //     out_bot_right_y <= y_min[y];
                            //     out_bot_left_x  <= y_max[x_local_max];
                            //     out_bot_left_y  <= y_max[y];
                            //     out_top_left_x  <= y_max[x_local_min];
                            //     out_top_left_y  <= y_max[y];
                            // end
                            // else if (y_thresh_BL) begin
                            //     out_bot_left_x  <= y_min[x_local_min];
                            //     out_bot_left_y  <= y_min[y];
                            //     out_top_left_x  <= y_min[x_local_max];
                            //     out_top_left_y  <= y_min[y];
                            //     out_top_right_x <= y_max[x_local_max];
                            //     out_top_right_y <= y_max[y];
                            //     out_bot_right_x <= y_max[x_local_min];
                            //     out_bot_right_y <= y_max[y];
                            // end
                            // else if (y_thresh_BR) begin
                            //     out_bot_right_x <= y_min[x_local_min];
                            //     out_bot_right_y <= y_min[y];
                            //     out_bot_left_x  <= y_min[x_local_max];
                            //     out_bot_left_y  <= y_min[y];
                            //     out_top_left_x  <= y_max[x_local_max];
                            //     out_top_left_y  <= y_max[y];
                            //     out_top_right_x <= y_max[x_local_min];
                            //     out_top_right_y <= y_max[y];
                            // end
                            // else begin 
                            //     out_top_left_x  <= out_top_left_x; 
                            //     out_top_left_y  <= out_top_left_y; 
                            //     out_top_right_x <= out_top_right_x; 
                            //     out_top_right_y <= out_top_right_y; 
                            //     out_bot_right_x <= out_bot_right_x; 
                            //     out_bot_right_y <= out_bot_right_y; 
                            //     out_bot_left_x  <= out_bot_left_x; 
                            //     out_bot_left_y  <= out_bot_left_y; 
                            // end

                            
                        end
                        // x and y thresh exceeded
                        else if ((x_min_exceeded || x_max_exceeded) && (y_min_exceeded || y_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            // if (xy_thresh_TL) begin
                                out_top_left_x  <= x_min_offset[x];
                                out_top_left_y  <= y_min_offset[y];
                                out_top_right_x <= x_max_offset[x];
                                out_top_right_y <= y_min_offset[y];
                                out_bot_right_x <= x_max_offset[x];
                                out_bot_right_y <= y_max_offset[y];
                                out_bot_left_x  <= x_min_offset[x];
                                out_bot_left_y  <= y_max_offset[y];
                            // end
                            // else if (xy_thresh_TR) begin
                            //     out_top_right_x <= x_min[x];
                            //     out_top_right_y <= y_min[y];
                            //     out_bot_right_x <= x_max[x];
                            //     out_bot_right_y <= y_min[y];
                            //     out_bot_left_x  <= x_max[x];
                            //     out_bot_left_y  <= y_max[y];
                            //     out_top_left_x  <= x_min[x];
                            //     out_top_left_y  <= y_max[y];
                            // end
                            // else if (xy_thresh_BL) begin
                            //     out_bot_left_x  <= x_min[x];
                            //     out_bot_left_y  <= y_min[y];
                            //     out_top_left_x  <= x_max[x];
                            //     out_top_left_y  <= y_min[y];
                            //     out_top_right_x <= x_max[x];
                            //     out_top_right_y <= y_max[y];
                            //     out_bot_right_x <= x_min[x];
                            //     out_bot_right_y <= y_max[y];
                            // end
                            // else if (xy_thresh_BR) begin
                            //     out_bot_right_x <= x_min[x];
                            //     out_bot_right_y <= y_min[y];
                            //     out_bot_left_x  <= x_max[x];
                            //     out_bot_left_y  <= y_min[y];
                            //     out_top_left_x  <= x_max[x];
                            //     out_top_left_y  <= y_max[y];
                            //     out_top_right_x <= x_min[x];
                            //     out_top_right_y <= y_max[y];
                            // end
                            // else begin 
                            //     out_top_left_x  <= out_top_left_x; 
                            //     out_top_left_y  <= out_top_left_y; 
                            //     out_top_right_x <= out_top_right_x; 
                            //     out_top_right_y <= out_top_right_y; 
                            //     out_bot_right_x <= out_bot_right_x; 
                            //     out_bot_right_y <= out_bot_right_y; 
                            //     out_bot_left_x  <= out_bot_left_x; 
                            //     out_bot_left_y  <= out_bot_left_y; 
                            // end

                            
                        end
                        //no thresh exceeded
                        else begin
                            //if the coordinates of xmin are closest to the old top left: 
                            // if (no_thresh_TL) begin
                                out_top_left_x  <= x_min_offset[x];
                                out_top_left_y  <= x_min_offset[y_local_min];
                                out_top_right_x <= y_min_offset[x_local_min];
                                out_top_right_y <= y_min_offset[y];
                                out_bot_right_x <= x_max_offset[x];
                                out_bot_right_y <= x_max_offset[y_local_max];
                                out_bot_left_x  <= y_max_offset[x_local_min];
                                out_bot_left_y  <= y_max_offset[y];
                            // end
                            // else if (no_thresh_TR) begin
                            //     out_top_right_x <= x_min[x];
                            //     out_top_right_y <= x_min[y_local_min];
                            //     out_bot_right_x <= y_min[x_local_min];
                            //     out_bot_right_y <= y_min[y];
                            //     out_bot_left_x  <= x_max[x];
                            //     out_bot_left_y  <= x_max[y_local_max];
                            //     out_top_left_x  <= y_max[x_local_min];
                            //     out_top_left_y  <= y_max[y];
                            // end
                            // else if (no_thresh_BL) begin
                            //     out_bot_left_x  <= x_min[x];
                            //     out_bot_left_y  <= x_min[y_local_min];
                            //     out_top_left_x  <= y_min[x_local_min];
                            //     out_top_left_y  <= y_min[y];
                            //     out_top_right_x <= x_max[x];
                            //     out_top_right_y <= x_max[y_local_max];
                            //     out_bot_right_x <= y_max[x_local_min];
                            //     out_bot_right_y <= y_max[y];
                            // end
                            // else if (no_thresh_BR) begin
                            //     out_bot_right_x <= x_min[x];
                            //     out_bot_right_y <= x_min[y_local_min];
                            //     out_bot_left_x  <= y_min[x_local_min];
                            //     out_bot_left_y  <= y_min[y];
                            //     out_top_left_x  <= x_max[x];
                            //     out_top_left_y  <= x_max[y_local_max];
                            //     out_top_right_x <= y_max[x_local_min];
                            //     out_top_right_y <= y_max[y];
                            // end
                            // else begin 
                            //     out_top_left_x  <= out_top_left_x; 
                            //     out_top_left_y  <= out_top_left_y; 
                            //     out_top_right_x <= out_top_right_x; 
                            //     out_top_right_y <= out_top_right_y; 
                            //     out_bot_right_x <= out_bot_right_x; 
                            //     out_bot_right_y <= out_bot_right_y; 
                            //     out_bot_left_x  <= out_bot_left_x; 
                            //     out_bot_left_y  <= out_bot_left_y; 
                            // end
                            
                        end
                    end

                    state_bad: begin
                       state <= state_bad;
                    end

                    default: begin
                        
                    end

                endcase
            end
        end
    end
end
endmodule