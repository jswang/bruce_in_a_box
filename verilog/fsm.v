module fsm (
    input clk,
    input reset,
    input VGA_VS, 
    input               pixel_valid, 
    input signed [10:0] pixel_x, 
    input signed [10:0] pixel_y,
    input signed [10:0] threshold,
    input unsigned [5:0] offset,

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
    output reg [9:0] test_y_min_xlocalmax, 
    output corner_flip
    );

// assign test_x_max = x_max[x][9:0]; 
// assign test_x_min = x_min[x][9:0]; 
// assign test_y_max = y_max[y][9:0]; 
// assign test_y_min = y_min[y][9:0]; 

// wire signed [10:0] threshold = 11'd80;

//Signal wires
wire falling_VGA_VS = (VGA_VS_prev && ~VGA_VS);
wire x_max_exceeded         = (count_x_max_offset > threshold);
wire x_min_exceeded         = (count_x_min_offset > threshold);
wire y_max_exceeded         = (count_y_max_offset > threshold);
wire y_min_exceeded         = (count_y_min_offset > threshold);
wire x_max_exceeded_init    = (count_x_max > threshold);
wire x_min_exceeded_init    = (count_x_min > threshold);
wire y_max_exceeded_init    = (count_y_max > threshold);
wire y_min_exceeded_init    = (count_y_min > threshold);

//Parameters
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

//------------I/o of top_left_x_PREV, should be using OUT_top_left_x
//because current is x_min, past is the out's

//sort the distances
localparam top_left  = 2'd0;
localparam top_right = 2'd1;
localparam bot_left  = 2'd2;
localparam bot_right = 2'd3;

//Distance calculations: xthreshold exceeded. So:
// TL = (x_min_prev[x], x_min_offsets[y_local_min])
always @ (x_min_prev[x], x_min_offset[y_local_min]) begin
calculate_distance ( x_min_prev[x], x_min_offset[y_local_min], 
                     x_thresh_TL_sum, x_thresh_TR_sum, x_thresh_BL_sum, x_thresh_BR_sum);
end
// wire signed [10:0] x_thresh_TL_x = (x_min_prev[x]             - out_top_left_x);
// wire signed [10:0] x_thresh_TL_y = (x_min_offset[y_local_min] - out_top_left_y);
// wire signed [10:0] x_thresh_TR_x = (x_min_prev[x]             - out_top_right_x);
// wire signed [10:0] x_thresh_TR_y = (x_min_offset[y_local_min] - out_top_right_y);
// wire signed [10:0] x_thresh_BL_x = (x_min_prev[x]             - out_bot_left_x);
// wire signed [10:0] x_thresh_BL_y = (x_min_offset[y_local_min] - out_bot_left_y);
// wire signed [10:0] x_thresh_BR_x = (x_min_prev[x]             - out_bot_right_x);
// wire signed [10:0] x_thresh_BR_y = (x_min_offset[y_local_min] - out_bot_right_y);

// wire unsigned [21:0] x_thresh_TL_xsqrd, x_thresh_TL_y2, x_thresh_TR_xsqrd, x_thresh_TR_y2, 
//                      x_thresh_BL_xsqrd, x_thresh_BL_y2, x_thresh_BR_xsqrd, x_thresh_BR_y2;
wire unsigned [22:0] x_thresh_TL_sum; // = x_thresh_TL_xsqrd + x_thresh_TL_y2;
wire unsigned [22:0] x_thresh_TR_sum; // = x_thresh_TR_xsqrd + x_thresh_TR_y2;
wire unsigned [22:0] x_thresh_BL_sum; // = x_thresh_BL_xsqrd + x_thresh_BL_y2;
wire unsigned [22:0] x_thresh_BR_sum; // = x_thresh_BR_xsqrd + x_thresh_BR_y2;

// squarer_s11 square_x_thresh_TL_x(x_thresh_TL_x, x_thresh_TL_xsqrd);
// squarer_s11 square_x_thresh_TL_y(x_thresh_TL_y, x_thresh_TL_y2);
// squarer_s11 square_x_thresh_TR_x(x_thresh_TR_x, x_thresh_TR_xsqrd);
// squarer_s11 square_x_thresh_TR_y(x_thresh_TR_y, x_thresh_TR_y2);
// squarer_s11 square_x_thresh_BL_x(x_thresh_BL_x, x_thresh_BL_xsqrd);
// squarer_s11 square_x_thresh_BL_y(x_thresh_BL_y, x_thresh_BL_y2);
// squarer_s11 square_x_thresh_BR_x(x_thresh_BR_x, x_thresh_BR_xsqrd);
// squarer_s11 square_x_thresh_BR_y(x_thresh_BR_y, x_thresh_BR_y2);

wire [1:0] x_thresh_nc [0:3]; //nc = nearest corner
always @ (x_thresh_TL_sum, x_thresh_TR_sum, x_thresh_BL_sum, x_thresh_BR_sum) begin
    sort (x_thresh_TL_sum, x_thresh_TR_sum, x_thresh_BL_sum, x_thresh_BR_sum, 
          top_left, top_right, bot_left, bot_right, 
          x_thresh_nc[0], x_thresh_nc[1], x_thresh_nc[2], x_thresh_nc[3]);
end

//Distance calculations: y_thresh exceeded. So current TL = (y_min[x_local_min], y_min[y])
wire signed [10:0] y_thresh_TL_x = (y_min_offset[x_local_min] - out_top_left_x);
wire signed [10:0] y_thresh_TL_y = (y_min_prev[y]             - out_top_left_y);
wire signed [10:0] y_thresh_TR_x = (y_min_offset[x_local_min] - out_top_right_x);
wire signed [10:0] y_thresh_TR_y = (y_min_prev[y]             - out_top_right_y);
wire signed [10:0] y_thresh_BL_x = (y_min_offset[x_local_min] - out_bot_left_x);
wire signed [10:0] y_thresh_BL_y = (y_min_prev[y]             - out_bot_left_y);
wire signed [10:0] y_thresh_BR_x = (y_min_offset[x_local_min] - out_bot_right_x);
wire signed [10:0] y_thresh_BR_y = (y_min_prev[y]             - out_bot_right_y);

wire unsigned [21:0] y_thresh_TL_xsqrd, y_thresh_TL_y2, y_thresh_TR_xsqrd, y_thresh_TR_y2, 
                     y_thresh_BL_xsqrd, y_thresh_BL_y2, y_thresh_BR_xsqrd, y_thresh_BR_y2;
wire unsigned [22:0] y_thresh_TL_sum = y_thresh_TL_xsqrd + y_thresh_TL_y2;
wire unsigned [22:0] y_thresh_TR_sum = y_thresh_TR_xsqrd + y_thresh_TR_y2;
wire unsigned [22:0] y_thresh_BL_sum = y_thresh_BL_xsqrd + y_thresh_BL_y2;
wire unsigned [22:0] y_thresh_BR_sum = y_thresh_BR_xsqrd + y_thresh_BR_y2;

squarer_s11 square_y_thresh_TL_x(y_thresh_TL_x, y_thresh_TL_xsqrd);
squarer_s11 square_y_thresh_TL_y(y_thresh_TL_y, y_thresh_TL_y2);
squarer_s11 square_y_thresh_TR_x(y_thresh_TR_x, y_thresh_TR_xsqrd);
squarer_s11 square_y_thresh_TR_y(y_thresh_TR_y, y_thresh_TR_y2);
squarer_s11 square_y_thresh_BL_x(y_thresh_BL_x, y_thresh_BL_xsqrd);
squarer_s11 square_y_thresh_BL_y(y_thresh_BL_y, y_thresh_BL_y2);
squarer_s11 square_y_thresh_BR_x(y_thresh_BR_x, y_thresh_BR_xsqrd);
squarer_s11 square_y_thresh_BR_y(y_thresh_BR_y, y_thresh_BR_y2);

wire [1:0] y_thresh_nc [0:3]; //nc = nearest corner
always @ (y_thresh_TL_sum, y_thresh_TR_sum, y_thresh_BL_sum, y_thresh_BR_sum) begin
    sort (y_thresh_TL_sum, y_thresh_TR_sum, y_thresh_BL_sum, y_thresh_BR_sum, 
          top_left, top_right, bot_left, bot_right, 
          y_thresh_nc[0], y_thresh_nc[1], y_thresh_nc[2], y_thresh_nc[3]);
end


//Distance calculations: xy_threshold both exceeded. So current TL = (x_min[x], y_min[y])
wire signed [10:0] xy_thresh_TL_x = (x_min_prev[x] - out_top_left_x);
wire signed [10:0] xy_thresh_TL_y = (y_min_prev[y] - out_top_left_y);
wire signed [10:0] xy_thresh_TR_x = (x_min_prev[x] - out_top_right_x);
wire signed [10:0] xy_thresh_TR_y = (y_min_prev[y] - out_top_right_y);
wire signed [10:0] xy_thresh_BL_x = (x_min_prev[x] - out_bot_left_x);
wire signed [10:0] xy_thresh_BL_y = (y_min_prev[y] - out_bot_left_y);
wire signed [10:0] xy_thresh_BR_x = (x_min_prev[x] - out_bot_right_x);
wire signed [10:0] xy_thresh_BR_y = (y_min_prev[y] - out_bot_right_y);

wire unsigned [21:0] xy_thresh_TL_xsqrd, xy_thresh_TL_y2, xy_thresh_TR_xsqrd, xy_thresh_TR_y2, 
                     xy_thresh_BL_xsqrd, xy_thresh_BL_y2, xy_thresh_BR_xsqrd, xy_thresh_BR_y2;
wire unsigned [22:0] xy_thresh_TL_sum = xy_thresh_TL_xsqrd + xy_thresh_TL_y2;
wire unsigned [22:0] xy_thresh_TR_sum = xy_thresh_TR_xsqrd + xy_thresh_TR_y2;
wire unsigned [22:0] xy_thresh_BL_sum = xy_thresh_BL_xsqrd + xy_thresh_BL_y2;
wire unsigned [22:0] xy_thresh_BR_sum = xy_thresh_BR_xsqrd + xy_thresh_BR_y2;

squarer_s11 square_xy_thresh_TL_x(xy_thresh_TL_x, xy_thresh_TL_xsqrd);
squarer_s11 square_xy_thresh_TL_y(xy_thresh_TL_y, xy_thresh_TL_y2);
squarer_s11 square_xy_thresh_TR_x(xy_thresh_TR_x, xy_thresh_TR_xsqrd);
squarer_s11 square_xy_thresh_TR_y(xy_thresh_TR_y, xy_thresh_TR_y2);
squarer_s11 square_xy_thresh_BL_x(xy_thresh_BL_x, xy_thresh_BL_xsqrd);
squarer_s11 square_xy_thresh_BL_y(xy_thresh_BL_y, xy_thresh_BL_y2);
squarer_s11 square_xy_thresh_BR_x(xy_thresh_BR_x, xy_thresh_BR_xsqrd);
squarer_s11 square_xy_thresh_BR_y(xy_thresh_BR_y, xy_thresh_BR_y2);

wire [1:0] xy_thresh_nc [0:3]; //nc = nearest corner
always @ (xy_thresh_TL_sum, xy_thresh_TR_sum, xy_thresh_BL_sum, xy_thresh_BR_sum) begin
    sort (xy_thresh_TL_sum, xy_thresh_TR_sum, xy_thresh_BL_sum, xy_thresh_BR_sum, 
                top_left, top_right, bot_left, bot_right, 
                xy_thresh_nc[0], xy_thresh_nc[1], xy_thresh_nc[2], xy_thresh_nc[3]);
end
//Distance calculations: no_threshold exceeded. so current TL = (x_min[x], x_min[y_local_min])
wire signed [10:0] no_thresh_TL_x = (x_min_prev[x]             - out_top_left_x);
wire signed [10:0] no_thresh_TL_y = (x_min_offset[y_local_min] - out_top_left_y);
wire signed [10:0] no_thresh_TR_x = (x_min_prev[x]             - out_top_right_x);
wire signed [10:0] no_thresh_TR_y = (x_min_offset[y_local_min] - out_top_right_y);
wire signed [10:0] no_thresh_BL_x = (x_min_prev[x]             - out_bot_left_x);
wire signed [10:0] no_thresh_BL_y = (x_min_offset[y_local_min] - out_bot_left_y);
wire signed [10:0] no_thresh_BR_x = (x_min_prev[x]             - out_bot_right_x);
wire signed [10:0] no_thresh_BR_y = (x_min_offset[y_local_min] - out_bot_right_y);

wire unsigned [21:0] no_thresh_TL_xsqrd, no_thresh_TL_y2, no_thresh_TR_xsqrd, no_thresh_TR_y2, 
                     no_thresh_BL_xsqrd, no_thresh_BL_y2, no_thresh_BR_xsqrd, no_thresh_BR_y2;
wire unsigned [22:0] no_thresh_TL_sum = no_thresh_TL_xsqrd + no_thresh_TL_y2;
wire unsigned [22:0] no_thresh_TR_sum = no_thresh_TR_xsqrd + no_thresh_TR_y2;
wire unsigned [22:0] no_thresh_BL_sum = no_thresh_BL_xsqrd + no_thresh_BL_y2;
wire unsigned [22:0] no_thresh_BR_sum = no_thresh_BR_xsqrd + no_thresh_BR_y2;

squarer_s11 square_no_thresh_TL_x(no_thresh_TL_x, no_thresh_TL_xsqrd);
squarer_s11 square_no_thresh_TL_y(no_thresh_TL_y, no_thresh_TL_y2);
squarer_s11 square_no_thresh_TR_x(no_thresh_TR_x, no_thresh_TR_xsqrd);
squarer_s11 square_no_thresh_TR_y(no_thresh_TR_y, no_thresh_TR_y2);
squarer_s11 square_no_thresh_BL_x(no_thresh_BL_x, no_thresh_BL_xsqrd);
squarer_s11 square_no_thresh_BL_y(no_thresh_BL_y, no_thresh_BL_y2);
squarer_s11 square_no_thresh_BR_x(no_thresh_BR_x, no_thresh_BR_xsqrd);
squarer_s11 square_no_thresh_BR_y(no_thresh_BR_y, no_thresh_BR_y2);

wire [1:0] no_thresh_nc [0:3]; //nc = nearest corner
always @ (no_thresh_TL_sum, no_thresh_TR_sum, no_thresh_BL_sum, no_thresh_BR_sum) begin
    sort (no_thresh_TL_sum, no_thresh_TR_sum, no_thresh_BL_sum, no_thresh_BR_sum, 
            top_left, top_right, bot_left, bot_right, 
            no_thresh_nc[0], no_thresh_nc[1], no_thresh_nc[2], no_thresh_nc[3]);
end




wire unsigned [21:0] threshold_2;
squarer_s11 square_threshold(threshold,threshold_2);
//Distance Calculation: previous corners to current corners. shouldn't flip more than threshold
wire signed [10:0] TL_TLprev_x = (out_top_left_x - top_left_x_prev);
wire signed [10:0] TL_TLprev_y = (out_top_left_y - top_left_y_prev);
wire signed [10:0] TR_TRprev_x = (out_top_right_x - top_right_x_prev);
wire signed [10:0] TR_TRprev_y = (out_top_right_y - top_right_y_prev);
wire signed [10:0] BL_BLprev_x = (out_bot_left_x - bot_left_x_prev);
wire signed [10:0] BL_BLprev_y = (out_bot_left_y - bot_left_y_prev);
wire signed [10:0] BR_BRprev_x = (out_bot_right_x - bot_right_x_prev);
wire signed [10:0] BR_BRprev_y = (out_bot_right_y - bot_right_y_prev);

wire unsigned [21:0] TL_TLprev_xsqrd, TL_TLprev_y2, TR_TRprev_xsqrd, TR_TRprev_y2, 
                     BL_BLprev_xsqrd, BL_BLprev_y2, BR_BRprev_xsqrd, BR_BRprev_y2;
wire unsigned [22:0] TL_TLprev_sum = TL_TLprev_xsqrd + TL_TLprev_y2;
wire unsigned [22:0] TR_TRprev_sum = TR_TRprev_xsqrd + TR_TRprev_y2;
wire unsigned [22:0] BL_BLprev_sum = BL_BLprev_xsqrd + BL_BLprev_y2;
wire unsigned [22:0] BR_BRprev_sum = BR_BRprev_xsqrd + BR_BRprev_y2;

squarer_s11 square_TL_TLprev_x(TL_TLprev_x, TL_TLprev_xsqrd);
squarer_s11 square_TL_TLprev_y(TL_TLprev_y, TL_TLprev_y2);
squarer_s11 square_TR_TRprev_x(TR_TRprev_x, TR_TRprev_xsqrd);
squarer_s11 square_TR_TRprev_y(TR_TRprev_y, TR_TRprev_y2);
squarer_s11 square_BL_BLprev_x(BL_BLprev_x, BL_BLprev_xsqrd);
squarer_s11 square_BL_BLprev_y(BL_BLprev_y, BL_BLprev_y2);
squarer_s11 square_BR_BRprev_x(BR_BRprev_x, BR_BRprev_xsqrd);
squarer_s11 square_BR_BRprev_y(BR_BRprev_y, BR_BRprev_y2);

assign corner_flip = (TL_TLprev_sum > threshold_2) || (TR_TRprev_sum > threshold_2)
                || (BL_BLprev_sum > threshold_2) || (BR_BRprev_sum > threshold_2);

//Distance calculations: prev xy maxmin and corners
                // x_max_prev[x]           <= x_max[x]; 
                // x_max_prev[y_local_max] <= x_max[y_local_max];
                // x_max_prev[y_local_min] <= x_max[y_local_min];
                // x_min_prev[x]           <= x_min[x];
                // x_min_prev[y_local_max] <= x_min[y_local_max];
                // x_min_prev[y_local_min] <= x_min[y_local_min];
                // y_max_prev[y]           <= y_max[y];
                // y_max_prev[x_local_max] <= y_max[x_local_max];
                // y_max_prev[x_local_min] <= y_max[x_local_min];
                // y_min_prev[y]           <= y_min[y];
                // y_min_prev[x_local_max] <= y_min[x_local_max];
                // y_min_prev[x_local_min] <= y_min[x_local_min];

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

                //find the +-offset from previous
                if (pixel_valid && (pixel_x == x_max_prev[x] - offset)) begin
                    x_max_offset[x]            <= pixel_x; 
                    if (pixel_y > x_max_offset[y_local_max]) x_max_offset[y_local_max]  <= pixel_y;
                    if (pixel_y < x_max_offset[y_local_min]) x_max_offset[y_local_min]  <= pixel_y;
                    count_x_max_offset         <= count_x_max_offset + 11'd1;
                end
                if (pixel_valid && (pixel_x == x_min_prev[x] + offset)) begin
                    x_min_offset[x]            <= pixel_x; 
                    if (pixel_y > x_min_offset[y_local_max]) x_min_offset[y_local_max] <= pixel_y;
                    if (pixel_y < x_min_offset[y_local_min]) x_min_offset[y_local_min] <= pixel_y;
                    count_x_min_offset        <= count_x_min_offset + 11'd1;
                end
                if (pixel_valid && (pixel_y == y_max_prev[y] - offset)) begin
                    y_max_offset[y]            <= pixel_y; 
                    if (pixel_x > y_max_offset[x_local_max]) y_max_offset[x_local_max] <= pixel_x;
                    if (pixel_x < y_max_offset[x_local_min]) y_max_offset[x_local_min] <= pixel_x;
                    count_y_max_offset     <= count_y_max_offset + 11'd1;
                end
                if (pixel_valid && (pixel_y == y_min_prev[y] + offset)) begin
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



                thresh_flags[15] <= x_thresh_nc[3] == top_left;
                thresh_flags[14] <= x_thresh_nc[3] == top_right;
                thresh_flags[13] <= x_thresh_nc[3] == bot_left;
                thresh_flags[12] <= x_thresh_nc[3] == bot_right;
                thresh_flags[11] <= y_thresh_nc[3] == top_left;
                thresh_flags[10] <= y_thresh_nc[3] == top_right;
                thresh_flags[9] <= y_thresh_nc[3] == bot_left;
                thresh_flags[8] <= y_thresh_nc[3] == bot_right;
                thresh_flags[7] <= xy_thresh_nc[3] == top_left;
                thresh_flags[6] <= xy_thresh_nc[3] == top_right;
                thresh_flags[5] <= xy_thresh_nc[3] == bot_left;
                thresh_flags[4] <= xy_thresh_nc[3] == bot_right;
                thresh_flags[3] <= no_thresh_nc[3] == top_left;
                thresh_flags[2] <= no_thresh_nc[3] == top_right;
                thresh_flags[1] <= no_thresh_nc[3] == bot_left;
                thresh_flags[0] <= no_thresh_nc[3] == bot_right;
                thresh_exceeded_flags[3] <= x_max_exceeded;
                thresh_exceeded_flags[2] <= x_min_exceeded;
                thresh_exceeded_flags[1] <= y_max_exceeded;
                thresh_exceeded_flags[0] <= y_min_exceeded;
                count <= count_y_max;
                //--------------end test outputs


                //Reset for next frame
                x_max[x]                       <= 11'd0; 
                x_max[y_local_max]             <= 11'd0;
                x_max[y_local_min]             <= 11'd479;
                x_min[x]                       <= 11'd639;
                x_min[y_local_max]             <= 11'd0;
                x_min[y_local_min]             <= 11'd479;
                y_max[y]                       <= 11'd0;
                y_max[x_local_max]             <= 11'd0;
                y_max[x_local_min]             <= 11'd639;
                y_min[y]                       <= 11'd479;
                y_min[x_local_max]             <= 11'd0;
                y_min[x_local_min]             <= 11'd639;
                count_x_max                    <= 11'd0;
                count_x_min                    <= 11'd0;
                count_y_max                    <= 11'd0;
                count_y_min                    <= 11'd0;
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
                count_x_max_offset             <= 11'd0;
                count_x_min_offset             <= 11'd0;
                count_y_max_offset             <= 11'd0;
                count_y_min_offset             <= 11'd0;

                //If I am in init or pre-init
                //or if iam in rotating and have not totally flipped
                //then use this new data point
                // if ((state == state_pre_init) || (state == state_init) 
                //  || (state == state_rotating && !corner_flip) ) begin
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
                // end
                
                

                //Depending on state, assign top/bottom left/right: 
                case (state) 

                    //In init state use the current things because the pipeline hasn't filled yet
                    state_init: begin
                        //X thresh exceeded, y thresh not
                        if ((x_min_exceeded_init || x_max_exceeded_init) && !(y_min_exceeded_init || y_max_exceeded_init)) begin
                            out_top_left_x  <= x_min[x];
                            out_top_left_y  <= x_min[y_local_min];
                            out_bot_left_x  <= x_min[x];
                            out_bot_left_y  <= x_min[y_local_max];
                            out_top_right_x <= x_max[x];
                            out_top_right_y <= x_max[y_local_min];
                            out_bot_right_x <= x_max[x];
                            out_bot_right_y <= x_max[y_local_max];
                        end
                        // y thresh exceeded_init, x thresh not
                        else if ((y_min_exceeded_init || y_max_exceeded_init) && !(x_min_exceeded_init || x_max_exceeded_init)) begin
                            out_top_left_x  <= y_min[x_local_min];
                            out_top_left_y  <= y_min[y];
                            out_top_right_x <= y_min[x_local_max];
                            out_top_right_y <= y_min[y];
                            out_bot_left_x  <= y_max[x_local_min];
                            out_bot_left_y  <= y_max[y];
                            out_bot_right_x <= y_max[x_local_max];
                            out_bot_right_y <= y_max[y];
                        end
                        // x and y thresh exceeded_init
                        else if ((x_min_exceeded_init || x_max_exceeded_init) && (y_min_exceeded_init || y_max_exceeded_init)) begin
                            out_top_left_x  <= x_min[x];
                            out_top_left_y  <= y_min[y];
                            out_top_right_x <= x_max[x];
                            out_top_right_y <= y_min[y];
                            out_bot_left_x  <= x_min[x];
                            out_bot_left_y  <= y_max[y];
                            out_bot_right_x <= x_max[x];
                            out_bot_right_y <= y_max[y];
                        end
                        //no thresh exceeded
                        else begin
                            out_top_left_x  <= x_min[x];
                            out_top_left_y  <= x_min[y_local_min];
                            out_top_right_x <= y_min[x_local_min];
                            out_top_right_y <= y_min[y];
                            out_bot_left_x  <= y_max[x_local_min];
                            out_bot_left_y  <= y_max[y];
                            out_bot_right_x <= x_max[x];
                            out_bot_right_y <= x_max[y_local_max];
                        end
                        state <= state_rotating;
                    end

                    state_rotating: begin

                        //X thresh exceeded, y thresh not
                        if ((x_min_exceeded || x_max_exceeded) && !(y_min_exceeded || y_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            if ( x_thresh_nc[3] == top_left) begin
                                out_top_left_x  <= x_min_prev[x];
                                out_top_left_y  <= x_min_offset[y_local_min];
                                out_top_right_x <= x_max_prev[x];
                                out_top_right_y <= x_max_offset[y_local_min];
                                out_bot_right_x <= x_max_prev[x];
                                out_bot_right_y <= x_max_offset[y_local_max];
                                out_bot_left_x  <= x_min_prev[x];
                                out_bot_left_y  <= x_min_offset[y_local_max];
                            end

                            //if the coordinates of xmin are closest to the old top right: 
                            else if (x_thresh_nc[3] == top_right) begin
                                out_top_right_x <= x_min_prev[x];
                                out_top_right_y <= x_min_offset[y_local_min];
                                out_bot_right_x <= x_max_prev[x];
                                out_bot_right_y <= x_max_offset[y_local_min];
                                out_bot_left_x  <= x_max_prev[x];
                                out_bot_left_y  <= x_max_offset[y_local_max];
                                out_top_left_x  <= x_min_prev[x];
                                out_top_left_y  <= x_min_offset[y_local_max];
                            end
                            
                            //if the coordinates of xmin are closest to the old bot left: 
                            else if (x_thresh_nc[3] == bot_left) begin
                                out_bot_left_x  <= x_min_prev[x];
                                out_bot_left_y  <= x_min_offset[y_local_min];
                                out_top_left_x  <= x_max_prev[x];
                                out_top_left_y  <= x_max_offset[y_local_min];
                                out_top_right_x <= x_max_prev[x];
                                out_top_right_y <= x_max_offset[y_local_max];
                                out_bot_right_x <= x_min_prev[x];
                                out_bot_right_y <= x_min_offset[y_local_max];
                            end

                            //if the coordinates of xmin are closest to the old bot right:
                            else if (x_thresh_nc[3] == bot_right) begin
                                out_bot_right_x <= x_min_prev[x];
                                out_bot_right_y <= x_min_offset[y_local_min];
                                out_bot_left_x  <= x_max_prev[x];
                                out_bot_left_y  <= x_max_offset[y_local_min];
                                out_top_left_x  <= x_max_prev[x];
                                out_top_left_y  <= x_max_offset[y_local_max];
                                out_top_right_x <= x_min_prev[x];
                                out_top_right_y <= x_min_offset[y_local_max];
                            end
                            else begin 
                                out_top_left_x  <= out_top_left_x; 
                                out_top_left_y  <= out_top_left_y; 
                                out_top_right_x <= out_top_right_x; 
                                out_top_right_y <= out_top_right_y; 
                                out_bot_right_x <= out_bot_right_x; 
                                out_bot_right_y <= out_bot_right_y; 
                                out_bot_left_x  <= out_bot_left_x; 
                                out_bot_left_y  <= out_bot_left_y; 
                            end
                        end
                        // y thresh exceeded, x thresh not
                        else if ((y_min_exceeded || y_max_exceeded) && !(x_min_exceeded || x_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            if (y_thresh_nc[3] == top_left) begin
                                out_top_left_x  <= y_min_offset[x_local_min];
                                out_top_left_y  <= y_min_prev[y];
                                out_top_right_x <= y_min_offset[x_local_max];
                                out_top_right_y <= y_min_prev[y];
                                out_bot_right_x <= y_max_offset[x_local_max];
                                out_bot_right_y <= y_max_prev[y];
                                out_bot_left_x  <= y_max_offset[x_local_min];
                                out_bot_left_y  <= y_max_prev[y];
                            end
                            else if (y_thresh_nc[3] == top_right) begin
                                out_top_right_x <= y_min_offset[x_local_min];
                                out_top_right_y <= y_min_prev[y];
                                out_bot_right_x <= y_min_offset[x_local_max];
                                out_bot_right_y <= y_min_prev[y];
                                out_bot_left_x  <= y_max_offset[x_local_max];
                                out_bot_left_y  <= y_max_prev[y];
                                out_top_left_x  <= y_max_offset[x_local_min];
                                out_top_left_y  <= y_max_prev[y];
                            end
                            else if (y_thresh_nc[3] == bot_left) begin
                                out_bot_left_x  <= y_min_offset[x_local_min];
                                out_bot_left_y  <= y_min_prev[y];
                                out_top_left_x  <= y_min_offset[x_local_max];
                                out_top_left_y  <= y_min_prev[y];
                                out_top_right_x <= y_max_offset[x_local_max];
                                out_top_right_y <= y_max_prev[y];
                                out_bot_right_x <= y_max_offset[x_local_min];
                                out_bot_right_y <= y_max_prev[y];
                            end
                            else if (y_thresh_nc[3] == bot_right) begin
                                out_bot_right_x <= y_min_offset[x_local_min];
                                out_bot_right_y <= y_min_prev[y];
                                out_bot_left_x  <= y_min_offset[x_local_max];
                                out_bot_left_y  <= y_min_prev[y];
                                out_top_left_x  <= y_max_offset[x_local_max];
                                out_top_left_y  <= y_max_prev[y];
                                out_top_right_x <= y_max_offset[x_local_min];
                                out_top_right_y <= y_max_prev[y];
                            end
                            else begin 
                                out_top_left_x  <= out_top_left_x; 
                                out_top_left_y  <= out_top_left_y; 
                                out_top_right_x <= out_top_right_x; 
                                out_top_right_y <= out_top_right_y; 
                                out_bot_right_x <= out_bot_right_x; 
                                out_bot_right_y <= out_bot_right_y; 
                                out_bot_left_x  <= out_bot_left_x; 
                                out_bot_left_y  <= out_bot_left_y;  
                            end

                            
                        end
                        // x and y thresh exceeded
                        else if ((x_min_exceeded || x_max_exceeded) && (y_min_exceeded || y_max_exceeded)) begin
                            //if the coordinates of xmin are closest to the old top left: 
                            if (xy_thresh_nc[3] == top_left) begin
                                out_top_left_x  <= x_min_prev[x];
                                out_top_left_y  <= y_min_prev[y];
                                out_top_right_x <= x_max_prev[x];
                                out_top_right_y <= y_min_prev[y];
                                out_bot_right_x <= x_max_prev[x];
                                out_bot_right_y <= y_max_prev[y];
                                out_bot_left_x  <= x_min_prev[x];
                                out_bot_left_y  <= y_max_prev[y];
                            end
                            else if (xy_thresh_nc[3] == top_right) begin
                                out_top_right_x <= x_min_prev[x];
                                out_top_right_y <= y_min_prev[y];
                                out_bot_right_x <= x_max_prev[x];
                                out_bot_right_y <= y_min_prev[y];
                                out_bot_left_x  <= x_max_prev[x];
                                out_bot_left_y  <= y_max_prev[y];
                                out_top_left_x  <= x_min_prev[x];
                                out_top_left_y  <= y_max_prev[y];
                            end
                            else if (xy_thresh_nc[3] == bot_left) begin
                                out_bot_left_x  <= x_min_prev[x];
                                out_bot_left_y  <= y_min_prev[y];
                                out_top_left_x  <= x_max_prev[x];
                                out_top_left_y  <= y_min_prev[y];
                                out_top_right_x <= x_max_prev[x];
                                out_top_right_y <= y_max_prev[y];
                                out_bot_right_x <= x_min_prev[x];
                                out_bot_right_y <= y_max_prev[y];
                            end
                            else if (xy_thresh_nc[3] == bot_right) begin
                                out_bot_right_x <= x_min_prev[x];
                                out_bot_right_y <= y_min_prev[y];
                                out_bot_left_x  <= x_max_prev[x];
                                out_bot_left_y  <= y_min_prev[y];
                                out_top_left_x  <= x_max_prev[x];
                                out_top_left_y  <= y_max_prev[y];
                                out_top_right_x <= x_min_prev[x];
                                out_top_right_y <= y_max_prev[y];
                            end
                            else begin 
                                out_top_left_x  <= out_top_left_x; 
                                out_top_left_y  <= out_top_left_y; 
                                out_top_right_x <= out_top_right_x; 
                                out_top_right_y <= out_top_right_y; 
                                out_bot_right_x <= out_bot_right_x; 
                                out_bot_right_y <= out_bot_right_y; 
                                out_bot_left_x  <= out_bot_left_x; 
                                out_bot_left_y  <= out_bot_left_y; 
                            end

                            
                        end
                        //no thresh exceeded
                        else begin
                            //if the coordinates of xmin are closest to the old top left: 
                            if (no_thresh_nc[3] == top_left) begin
                                out_top_left_x  <= x_min_prev[x];
                                out_top_left_y  <= x_min_prev[y_local_min];
                                out_top_right_x <= y_min_prev[x_local_min];
                                out_top_right_y <= y_min_prev[y];
                                out_bot_right_x <= x_max_prev[x];
                                out_bot_right_y <= x_max_prev[y_local_max];
                                out_bot_left_x  <= y_max_prev[x_local_min];
                                out_bot_left_y  <= y_max_prev[y];
                            end
                            else if (no_thresh_nc[3] == top_right) begin
                                out_top_right_x <= x_min_prev[x];
                                out_top_right_y <= x_min_prev[y_local_min];
                                out_bot_right_x <= y_min_prev[x_local_min];
                                out_bot_right_y <= y_min_prev[y];
                                out_bot_left_x  <= x_max_prev[x];
                                out_bot_left_y  <= x_max_prev[y_local_max];
                                out_top_left_x  <= y_max_prev[x_local_min];
                                out_top_left_y  <= y_max_prev[y];
                            end
                            else if (no_thresh_nc[3] == bot_left) begin
                                out_bot_left_x  <= x_min_prev[x];
                                out_bot_left_y  <= x_min_prev[y_local_min];
                                out_top_left_x  <= y_min_prev[x_local_min];
                                out_top_left_y  <= y_min_prev[y];
                                out_top_right_x <= x_max_prev[x];
                                out_top_right_y <= x_max_prev[y_local_max];
                                out_bot_right_x <= y_max_prev[x_local_min];
                                out_bot_right_y <= y_max_prev[y];
                            end
                            else if (no_thresh_nc[3] == bot_right) begin
                                out_bot_right_x <= x_min_prev[x];
                                out_bot_right_y <= x_min_prev[y_local_min];
                                out_bot_left_x  <= y_min_prev[x_local_min];
                                out_bot_left_y  <= y_min_prev[y];
                                out_top_left_x  <= x_max_prev[x];
                                out_top_left_y  <= x_max_prev[y_local_max];
                                out_top_right_x <= y_max_prev[x_local_min];
                                out_top_right_y <= y_max_prev[y];
                            end
                            else begin 
                                out_top_left_x  <= out_top_left_x; 
                                out_top_left_y  <= out_top_left_y; 
                                out_top_right_x <= out_top_right_x; 
                                out_top_right_y <= out_top_right_y; 
                                out_bot_right_x <= out_bot_right_x; 
                                out_bot_right_y <= out_bot_right_y; 
                                out_bot_left_x  <= out_bot_left_x; 
                                out_bot_left_y  <= out_bot_left_y; 
                            end
                            
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

//=================TASKS===========================//

//sort an array of 3 eleemnts. sorted[3] = biggest, sorted[0] = smallest
task sort;
input unsigned [22:0] in_unsorted_array_0;
input unsigned [22:0] in_unsorted_array_1;
input unsigned [22:0] in_unsorted_array_2;
input unsigned [22:0] in_unsorted_array_3;

input [1:0]           in_unsorted_array_name_0;
input [1:0]           in_unsorted_array_name_1;
input [1:0]           in_unsorted_array_name_2;
input [1:0]           in_unsorted_array_name_3;

output [1:0]          sorted_array_name_0;
output [1:0]          sorted_array_name_1;
output [1:0]          sorted_array_name_2;
output [1:0]          sorted_array_name_3;

reg [22:0] temp;
reg [1:0] temp_name;

reg unsigned [22:0] unsorted_array[0:3];
reg unsigned [1:0] unsorted_array_name[0:3];
begin
    integer i;
    integer n;
    integer newn;
    unsorted_array[0] = in_unsorted_array_0;
    unsorted_array[1] = in_unsorted_array_1;
    unsorted_array[2] = in_unsorted_array_2;
    unsorted_array[3] = in_unsorted_array_3;
    unsorted_array_name[0] = in_unsorted_array_name_0;
    unsorted_array_name[1] = in_unsorted_array_name_1;
    unsorted_array_name[2] = in_unsorted_array_name_2;
    unsorted_array_name[3] = in_unsorted_array_name_3;

    newn = 0;
    for (n = 0; n < 4; n = n + 1) begin
        for (i = 1; i < 3; i = i + 1) begin
            if (unsorted_array[i-1] > unsorted_array[i]) begin
                //swap actual values
                temp = unsorted_array[i]; 
                unsorted_array[i] = unsorted_array[i-1];
                unsorted_array[i-1] = temp;
                newn = i;

                //swap the names of the values
                temp_name = unsorted_array_name[i]; 
                unsorted_array_name[i] = unsorted_array_name[i-1];
                unsorted_array_name[i-1] = temp_name;
            end
        end
    end
    sorted_array_name_3 = unsorted_array_name[3];
    sorted_array_name_2 = unsorted_array_name[2];
    sorted_array_name_1 = unsorted_array_name[1];
    sorted_array_name_0 = unsorted_array_name[0];
end
endtask

task calculate_distance;
input signed [10:0] current_x;
input signed [10:0] current_y;
// input signed [10:0] TL_x_prev;
// input signed [10:0] TL_y_prev;
// input signed [10:0] TR_x_prev;
// input signed [10:0] TR_y_prev;
// input signed [10:0] BL_x_prev;
// input signed [10:0] BL_y_prev;
// input signed [10:0] BR_x_prev;
// input signed [10:0] BR_y_prev;

output unsigned [22:0] dist_to_TL;
output unsigned [22:0] dist_to_TR;
output unsigned [22:0] dist_to_BL;
output unsigned [22:0] dist_to_BR;

reg signed [10:0] diff_TL_x;
reg signed [10:0] diff_TL_y;
reg signed [10:0] diff_TR_x;
reg signed [10:0] diff_TR_y;
reg signed [10:0] diff_BL_x;
reg signed [10:0] diff_BL_y;
reg signed [10:0] diff_BR_x;
reg signed [10:0] diff_BR_y;
reg unsigned [21:0] TL_xsqrd, TL_ysqrd, TR_xsqrd, TR_ysqrd, 
                    BL_xsqrd, BL_ysqrd, BR_xsqrd, BR_ysqrd;
begin
    diff_TL_x = (current_x - out_top_left_x); 
    diff_TL_y = (current_y - out_top_left_y);
    diff_TR_x = (current_x - out_top_right_x);
    diff_TR_y = (current_y - out_top_right_y);
    diff_BL_x = (current_x - out_bot_left_x);
    diff_BL_y = (current_y - out_bot_left_y);
    diff_BR_x = (current_x - out_bot_right_x);
    diff_BR_y = (current_y - out_bot_right_y);
    TL_xsqrd  = diff_TL_x * diff_TL_x; 
    TL_ysqrd  = diff_TL_y * diff_TL_y; 
    TR_xsqrd  = diff_TR_x * diff_TR_x; 
    TR_ysqrd  = diff_TR_y * diff_TR_y; 
    BL_xsqrd  = diff_BL_x * diff_BL_x; 
    BL_ysqrd  = diff_BL_y * diff_BL_y; 
    BR_xsqrd  = diff_BR_x * diff_BR_x; 
    BR_ysqrd  = diff_BR_y * diff_BR_y;
    dist_to_TL = TL_xsqrd + TL_ysqrd;
    dist_to_TR = TR_xsqrd + TR_ysqrd;
    dist_to_BL = BL_xsqrd + BL_ysqrd;
    dist_to_BR = BR_xsqrd + BR_ysqrd;
end

endtask

endmodule