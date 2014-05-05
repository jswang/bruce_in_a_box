module boundary_select 
#(
    parameter p_image_width = 80,
    parameter p_image_height = 480
    )
(
    input clk,
    input reset, 
    input [17:0] SW,
    input  unsigned [10:0] VGA_X, //delayed by 16 
    input  unsigned [10:0] VGA_Y,
    // input  unsigned [10:0] top_left_x,
    // input  unsigned [10:0] top_left_y,
    // input  unsigned [10:0] top_right_x,
    // input  unsigned [10:0] top_right_y,
    // input  unsigned [10:0] bot_left_x,
    // input  unsigned [10:0] bot_left_y,
    // input  unsigned [10:0] bot_right_x,
    // input  unsigned [10:0] bot_right_y, 

    output draw_image, 
    output [7:0] image_R, 
    output [7:0] image_G, 
    output [7:0] image_B, 
    output unsigned [10:0] draw_start_x,
    output unsigned [10:0] draw_start_y, 
    output unsigned [10:0] draw_end_x, 
    output unsigned [10:0] draw_end_y, 
    output signed [9:0]    theta

);
//----------Read from the ROM------------//
localparam x = 0;
localparam y = 1;
wire unsigned [10:0] draw_start [0:1];
wire unsigned [10:0] draw_end   [0:1];
assign draw_start[x] = 11'd300; 
assign draw_start[y] = 11'd200;
assign draw_end[x] = 11'd300 + {3'd0, SW[17:10]};
assign draw_end[y] = 11'd200 + {3'd0, SW[9:2]};
assign draw_start_x = draw_start[x];
assign draw_start_y = draw_start[y];
assign draw_end_x   = draw_end[x];
assign draw_end_y   = draw_end[y];

//Use draw_start to find the offset
wire signed [11:0] offset [0:1];
wire signed [11:0] draw_end_offset[0:1];
assign offset[x] = draw_start[x];
assign offset[y] = draw_start[y]; 
assign draw_end_offset[x] = draw_end[x] - offset[x]; 
assign draw_end_offset[y] = draw_end[y] - offset[y];


//reads from rom to do division so output delayed by 2 cycles
//Forward rotation = theta
arctan_LUT #(
    .p_image_width(p_image_width), 
    .p_image_height(p_image_height)
)
arctan(
    .clk(clk),
    .numer(draw_end_offset[y]), 
    .denom(draw_end_offset[x]), 
    .theta(theta) // [0, 359]
);

wire signed [9:0] theta_inverse = 10'd360 -theta;
//1b sign, 11bit integer, 8 bit precision
wire signed [19:0] cos_theta, sine_theta;
cosine_LUT cos_x(
    .theta(theta_inverse), 
    .cos_theta_out(cos_theta)
);
sine_LUT sine_y(
    .theta(theta_inverse), 
    .sine_theta_out(sine_theta)
);

wire unsigned [10:0] VGA_X_d2, VGA_Y_d2;
delay #(.DATA_WIDTH(22), .DELAY(2)) delay_vgaxy(
    .clk(clk), 
    .data_in({VGA_X, VGA_Y}), 
    .data_out({VGA_X_d2, VGA_Y_d2})
);

//Undo the translation for current VGA XY
wire signed [11:0] VGA_XY_offset [0:1]; 
assign VGA_XY_offset[x] = {1'b0, VGA_X_d2} - offset[x]; 
assign VGA_XY_offset[y] = {1'b0, VGA_Y_d2} - offset[y];

//Using {1b sign, 11b integer, 8 bit float} fixed point
wire signed [19:0] cos_times_x, sine_times_y, cos_times_y, sine_times_x;
fp_s20 fp_mult_cos_x(
    .a(cos_theta), 
    .b({VGA_XY_offset[x], 8'd0}), 
    .out(cos_times_x)
);
fp_s20 fp_mult_sine_y(
    .a(sine_theta), 
    .b({VGA_XY_offset[y], 8'd0}), 
    .out(sine_times_y)
);
fp_s20 fp_mult_cos_y(
    .a(cos_theta), 
    .b({VGA_XY_offset[y], 8'd0}), 
    .out(cos_times_y)
);
fp_s20 fp_mult_sine_x(
    .a(sine_theta), 
    .b({VGA_XY_offset[x], 8'd0}), 
    .out(sine_times_x)
);

wire signed [11:0] VGA_XY_txfm [0:1];
assign VGA_XY_txfm[x] = cos_times_x[19:8] - sine_times_y[19:8];
assign VGA_XY_txfm[y] = sine_times_x[19:8] + cos_times_y[19:8];

//generate addresses to read from rom
wire unsigned [15:0] rom_addr_d18 = VGA_XY_txfm[x] + p_image_width * VGA_XY_txfm[y];
assign draw_image = ((VGA_XY_txfm[x] >= 0) && (VGA_XY_txfm[x] < p_image_width)
                && (VGA_XY_txfm[y] >= 0) && (VGA_XY_txfm[y] < p_image_height));

rom_clocktower clocktower_full (
    .clock(clk), 
    .address_a(rom_addr_d18), 
    .address_b(), 
    .q_a({image_R, image_G, image_B}), 
    .q_b()
);

endmodule
