module boundary_select 
#(
    parameter p_image_width = 200, //80
    parameter p_image_height = 140 //480
    )
(
    input clk,
    input reset, 
    input [17:0] SW,
    input                  clocktower, //1 if should display clocktowers
    input  unsigned [10:0] VGA_X, //delayed by 16 
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
    output unsigned [10:0] draw_start_x,
    output unsigned [10:0] draw_start_y, 
    output unsigned [10:0] draw_end_x, 
    output unsigned [10:0] draw_end_y, 
    output signed [9:0]    theta, 

    output reg [3:0] scale

);
//determine scale. 
wire unsigned [22:0] scale_dist;
always @ (top_left_x, top_left_y, top_right_x, top_right_y) begin
    calculate_distance(top_left_x, top_left_y, top_right_x, top_right_y, scale_dist);
    
    if      (scale_dist >= 23'd230400)  scale = 4'd4; //x4
    else if (scale_dist >= 23'd102400)  scale = 4'd3; //x2
    else if (scale_dist >= 23'd36864)   scale = 4'd2; //x1
    else if (scale_dist >= 23'd100)     scale = 4'd1; //x.5
    else                                scale = 4'd0; //x.25
end

//Select correct image to output on RGB
wire [7:0] R_clocktower, G_clocktower, B_clocktower;
wire [7:0] R_bruce, G_bruce, B_bruce;
assign image_R = clocktower ? R_clocktower : R_bruce;
assign image_G = clocktower ? G_clocktower : G_bruce;
assign image_B = clocktower ? B_clocktower : B_bruce;


//----------Read from the ROM------------//
localparam x = 0;
localparam y = 1;
wire unsigned [10:0] draw_start [0:1];
wire unsigned [10:0] draw_end   [0:1];
// assign draw_start[x] = 11'd300; 
// assign draw_start[y] = 11'd200;
// assign draw_end[x]   = 11'd380; 
// assign draw_end[y]   = 11'd200;
// assign draw_end[x] = (SW[17]) ? 11'd300 - {4'd0, SW[16:10]} : 11'd300 + {4'd0, SW[16:10]};
// assign draw_end[y] = (SW[9]) ? 11'd200 - {4'd0, SW[8:2]} : 11'd200 + {4'd0, SW[16:10]};

assign draw_start[x] = top_left_x;
assign draw_start[y] = (top_left_y + bot_left_y)>>1;
assign draw_end[x]   = top_right_x;
assign draw_end[y]   = (top_right_y + bot_right_y)>>1;

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

reg unsigned [14:0] rom_addr_d18;
//generate addresses to read from rom
always @ (*) begin
    case (scale) 
        4'd7: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>5) + p_image_width * (VGA_XY_txfm[y]>>>5);
            draw_image   = ((VGA_XY_txfm[x]>>>5) >= 0) && ((VGA_XY_txfm[x]>>>5) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>5) >= 0) && ((VGA_XY_txfm[y]>>>5) < p_image_height);
        end
        4'd6: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>4) + p_image_width * (VGA_XY_txfm[y]>>>4);
            draw_image   = ((VGA_XY_txfm[x]>>>4) >= 0) && ((VGA_XY_txfm[x]>>>4) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>4) >= 0) && ((VGA_XY_txfm[y]>>>4) < p_image_height);
        end
        4'd5: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>3) + p_image_width * (VGA_XY_txfm[y]>>>3);
            draw_image   = ((VGA_XY_txfm[x]>>>3) >= 0) && ((VGA_XY_txfm[x]>>>3) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>3) >= 0) && ((VGA_XY_txfm[y]>>>3) < p_image_height);
        end
        4'd4: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>2) + p_image_width * (VGA_XY_txfm[y]>>>2);
            draw_image   = ((VGA_XY_txfm[x]>>>2) >= 0) && ((VGA_XY_txfm[x]>>>2) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>2) >= 0) && ((VGA_XY_txfm[y]>>>2) < p_image_height);
        end
        4'd3: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>1) + p_image_width * (VGA_XY_txfm[y]>>>1);
            draw_image   = ((VGA_XY_txfm[x]>>>1) >= 0) && ((VGA_XY_txfm[x]>>>1) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>5) >= 0) && ((VGA_XY_txfm[y]>>>5) < p_image_height);
        end
        4'd2: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>0) + p_image_width * (VGA_XY_txfm[y]>>>0);
            draw_image   = ((VGA_XY_txfm[x]>>>0) >= 0) && ((VGA_XY_txfm[x]>>>0) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>0) >= 0) && ((VGA_XY_txfm[y]>>>0) < p_image_height);
        end
        4'd1: begin
            rom_addr_d18 = (VGA_XY_txfm[x]<<<1) + p_image_width * (VGA_XY_txfm[y]<<<1);
            draw_image   = ((VGA_XY_txfm[x]<<<1) >= 0) && ((VGA_XY_txfm[x]<<<1) < p_image_width)
                        && ((VGA_XY_txfm[y]<<<1) >= 0) && ((VGA_XY_txfm[y]<<<1) < p_image_height);
        end
        4'd0: begin
            rom_addr_d18 = (VGA_XY_txfm[x]<<<2) + p_image_width * (VGA_XY_txfm[y]<<<2);
            draw_image   = ((VGA_XY_txfm[x]<<<2) >= 0) && ((VGA_XY_txfm[x]<<<2) < p_image_width)
                        && ((VGA_XY_txfm[y]<<<2) >= 0) && ((VGA_XY_txfm[y]<<<2) < p_image_height);
        end
        default: begin
            rom_addr_d18 = (VGA_XY_txfm[x]>>>0) + p_image_width * (VGA_XY_txfm[y]>>>0);
            draw_image   = ((VGA_XY_txfm[x]>>>0) >= 0) && ((VGA_XY_txfm[x]>>>0) < p_image_width)
                        && ((VGA_XY_txfm[y]>>>0) >= 0) && ((VGA_XY_txfm[y]>>>0) < p_image_height);
        end

    endcase
end

// rom_clocktower clocktower_full (
//     .clock      (clk), 
//     .address_a  (rom_addr_d18[15:0]), 
//     .address_b  (), 
//     .q_a        ({R_clocktower, G_clocktower, B_clocktower}), 
//     .q_b        ()
// );
assign R_clocktower = 8'd0;
assign G_clocktower = 8'd0;
assign B_clocktower = 8'd0;

rom_bruce bruce (
    .clock      (clk), 
    .address    (rom_addr_d18), 
    .q({R_bruce, G_bruce, B_bruce}), 
);


task calculate_distance;
input unsigned [10:0] point1_x;
input unsigned [10:0] point1_y;
input unsigned [10:0] point2_x;
input unsigned [10:0] point2_y;
output unsigned [22:0] dist_pt1_pt2;

reg signed [10:0] diff_x;
reg signed [10:0] diff_y;
reg unsigned [21:0] xsqrd, ysqrd;
begin
    diff_x = (point1_x - point2_x); 
    diff_y = (point1_y - point2_y);
    
    xsqrd  = diff_x * diff_x; 
    ysqrd  = diff_y * diff_y; 
    dist_pt1_pt2 = xsqrd + ysqrd;
end

endtask

endmodule
