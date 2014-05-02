module boundary_select 
#(
    parameter p_image_width = 80,
    parameter p_image_heigth = 480
    )
(
    input clk,
    input reset, 
    input [17:0] SW,
    input  unsigned [10:0] VGA_X, 
    input  unsigned [10:0] VGA_Y,
    input  unsigned [10:0] top_left_x,
    input  unsigned [10:0] top_left_y,
    input  unsigned [10:0] top_right_x,
    input  unsigned [10:0] top_right_y,
    input  unsigned [10:0] bot_left_x,
    input  unsigned [10:0] bot_left_y,
    input  unsigned [10:0] bot_right_x,
    input  unsigned [10:0] bot_right_y, 

    output reg draw_image, 
    output [7:0] image_R, 
    output [7:0] image_G, 
    output [7:0] image_B, 
    output unsigned [7 :0] scale

);
//----------Read from the ROM------------//
localparam x = 0;
localparam y = 1;
wire unsigned [10:0] draw_start [0:1];
wire unsigned [10:0] draw_end   [0:1];
assign draw_start[x] = SW[17:7]; 
assign draw_start[y] = {SW[6:2], 6'd0};

//Use draw_start to find the offset
wire signed [11:0] offset [0:1];
wire signed [11:0] draw_start_offset[0:1];
wire signed [11:0] draw_end_offset[0:1];
assign offset[x] = draw_start[x];
assign offset[y] = draw_start[y]; 
assign draw_start_offset[x] = draw_start[x] - offset[x]; 
assign draw_start_offset[y] = draw_start[y] - offset[y];
assign draw_end_offset[x] = draw_end[x] - offset[x]; 
assign draw_end_offset[y] = draw_end[y] - offset[y];

wire signed [11:0] quotient, remainder;
div_s12 div_arctan(
    .numer(draw_end_offset[y]), 
    .denom(draw_end_offset[x]), 
    .quotient(quotient), 
    .remainder(remainder)
)

wire signed [11:0] abs_quotient = (quotient < 0) ? 12'd0 - quotient : quotient;
wire signed [9:0] theta;
arctan_LUT arctan(
    .quotient(abs_quotient), 
    .remainder(remainder), 
    .sign_x(draw_end_offset[x][11]), 
    .sign_y(draw_end_offset[y][11]), 
    .theta(theta)
);

//1b sign, 11bit integer, 8 bit precision
wire signed [19:0] cos_theta, sine_theta;
cosine_LUT cos_x(
    .theta(theta), 
    .cos_theta(cos_theta)
);
sine_LUT sine_y(
    .theta(theta), 
    .sine_theta(sine_theta)
);
wire signed [19:0] cos_times_x, sine_times_y;
fp_s20 fp_mult_cos_x(
    .a(cos_theta), 
    .b({1'b0, VGA_X, 8'd0}), 
    .out(cos_times_x)
);
fp_s20 fp_mult_sine_y(
    .a(sine_theta), 
    .b({1'b0, VGA_Y, 8'd0}), 
    .out(sine_times_y)
);

wire signed [11:0] txfm_VGA_XY [0:1];
assign txfm_VGA_XY[x] = cos_times_x[19:8] - sine_times_y[19:8];
assign txfm_VGA_XY[y] = sine_times_y[19:8] + sine_times_y[19:8];

//generate addresses to read from rom
wire unsigned [15:0] rom_addr_d18 = txfm_VGA_XY[x] + p_image_width * txfm_VGA_XY[y];
draw_image = ((txfm_VGA_XY[x] >= 0) && (txfm_VGA_XY < p_image_width)
                && (txfm_VGA_XY[y] >= 0) && (txfm_VGA_XY[y] < p_image_height);
rom_clocktower clocktower_full (
    .clock(VGA_CLK), 
    .address_a(rom_addr_d18), 
    .address_b(), 
    .q_a({image_R, image_G, image_B}), 
    .q_b()
);


endmodule
