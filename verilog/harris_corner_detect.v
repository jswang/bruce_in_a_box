module harris_corner_detect (
	input clk, 
	input reset, 
	input VGA_VS,
	input clk_en,
	input [7:0] VGA_R, 
	input [7:0] VGA_G, 
	input [7:0] VGA_B, 

	input [9:0] addr_in_x, //used to determine buffer shift enable
	input [9:0] addr_in_y, 

	output edge_detected
	// output reg corner_detected, 
	// output reg unsigned [9:0] addr_corner_x, 
	// output reg unsigned [9:0] addr_corner_y
);

	assign edge_detected = x22_p;
	reg 		buf_shift_en;

	always @ (posedge clk) begin
		if (reset) begin
			buf_shift_en <= 1'b0;
		end
		else if (clk_en) begin
			buf_shift_en <= 1'b1;
		end
		else begin
			buf_shift_en <= 1'b0;
		end
	end

	wire [23:0] tap5, tap4, tap3, tap2, tap1;
	wire [23:0] RGB_color_in = {VGA_R, VGA_G, VGA_B};
	ram_shift buffer(
		.aclr(!VGA_VS), 
		.clock(clk && buf_shift_en), 
		.shiftin(RGB_color_in), 
		.shiftout(), 
		.taps({tap5, tap4, tap3, tap2, tap1})
	);
   reg[23:0]    x00, x01, x02, x03, x04,
           x10, x11, x12, x13, x14,
           x20, x21, x22, x23, x24,
           x30, x31, x32, x33, x34,
           x40, x41, x42, x43, x44;

    always @ (posedge clk) begin
    	  x00 <= x01;
		  x01 <= x02;
		  x02 <= x03;
		  x03 <= x04;
		  x04 <= RGB_color_in;
		  x10 <= x11;
		  x11 <= x12;
		  x12 <= x13;
		  x13 <= x14;
		  x14 <= tap1;
		  x20 <= x21;
		  x21 <= x22;
		  x22 <= x23;
		  x23 <= x24;
		  x24 <= tap2;
		  x30 <= x31;
		  x31 <= x32;
		  x32 <= x33;
		  x33 <= x34;
		  x34 <= tap3;
		  x40 <= x41;
		  x41 <= x42;
		  x42 <= x43;
		  x43 <= x44;
		  x44 <= tap4;

    end
    localparam x = 0;
    localparam y = 1;

    wire x11_p, x12_p, x13_p,
    	 x21_p, x22_p, x23_p,
    	 x31_p, x32_p, x33_p;

   	sobel point_x11 
   	(
   		.clk(clk),
   		.x00(x00), 
		.x01(x01), 
		.x02(x02), 
		.x10(x10), 
		.x11(x11), 
		.x12(x12), 
		.x20(x20), 
		.x21(x21), 
		.x22(x22), 
		.p(x11_p)
   	);
           
   	sobel point_x12(
   		.clk(clk),
   		.x00(x01), 
		.x01(x02), 
		.x02(x03), 
		.x10(x11), 
		.x11(x12), 
		.x12(x13), 
		.x20(x21), 
		.x21(x22), 
		.x22(x23), 
		.p(x12_p)
   	);

   	sobel point_x13(
   		.clk(clk),
   		.x00(x02), 
		.x01(x03), 
		.x02(x04), 
		.x10(x12), 
		.x11(x13), 
		.x12(x14), 
		.x20(x22), 
		.x21(x23), 
		.x22(x24), 
		.p(x13_p)
   	);

   	sobel point_x21(
   		.clk(clk),
   		.x00(x10), 
		.x01(x11), 
		.x02(x12), 
		.x10(x20), 
		.x11(x21), 
		.x12(x22), 
		.x20(x30), 
		.x21(x31), 
		.x22(x32), 
		.p(x21_p)
   	);

   	sobel point_x22(
   		.clk(clk),
   		.x00(x11), 
		.x01(x12), 
		.x02(x13), 
		.x10(x21), 
		.x11(x22), 
		.x12(x23), 
		.x20(x31), 
		.x21(x32), 
		.x22(x33), 
		.p(x22_p)
   	);

   	sobel point_x23(
   		.clk(clk),
   		.x00(x12), 
		.x01(x13), 
		.x02(x14), 
		.x10(x22), 
		.x11(x23), 
		.x12(x24), 
		.x20(x32), 
		.x21(x33), 
		.x22(x34), 
		.p(x23_p)
   	);

   	sobel point_x31(
   		.clk(clk),
   		.x00(x20), 
		.x01(x21), 
		.x02(x22), 
		.x10(x30), 
		.x11(x31), 
		.x12(x32), 
		.x20(x40), 
		.x21(x41), 
		.x22(x42), 
		.p(x31_p)
   	);

   	sobel point_x32 (
   		.clk(clk),
   		.x00(x21), 
		.x01(x22), 
		.x02(x23), 
		.x10(x31), 
		.x11(x32), 
		.x12(x33), 
		.x20(x41), 
		.x21(x42), 
		.x22(x43), 
		.p(x32_p)
   	);

   	sobel point_x33 (
   		.clk(clk),
   		.x00(x22), 
		.x01(x23), 
		.x02(x24), 
		.x10(x32), 
		.x11(x33), 
		.x12(x34), 
		.x20(x42), 
		.x21(x43), 
		.x22(x44), 
		.p(x33_p)
   	);


    // wire signed [15:0] harris_feature;
    // harris_operator #(.p_num_bits_in(4)) harris_x22 
    // (
    //     .x00_Ix(x11_Ix), 
    //     .x01_Ix(x12_Ix), 
    //     .x02_Ix(x13_Ix), 
    //     .x10_Ix(x21_Ix), 
    //     .x11_Ix(x22_Ix), 
    //     .x12_Ix(x23_Ix), 
    //     .x20_Ix(x31_Ix), 
    //     .x21_Ix(x32_Ix), 
    //     .x22_Ix(x33_Ix), 
    //     .x00_Iy(x11_Iy), 
    //     .x01_Iy(x12_Iy), 
    //     .x02_Iy(x13_Iy), 
    //     .x10_Iy(x21_Iy), 
    //     .x11_Iy(x22_Iy), 
    //     .x12_Iy(x23_Iy), 
    //     .x20_Iy(x31_Iy), 
    //     .x21_Iy(x32_Iy), 
    //     .x22_Iy(x33_Iy), 
    //     .out(harris_feature)
    // );

    // always @(posedge clk) begin
    //     if (harris_feature >= threshold) begin
    //         corner_detected = 1'b1;
    //         addr_corner_x = x22_full[20:11]; //todo not sure if this is correct place to get x value
    //         addr_corner_y = x22_full[10:1];
    //     end
    // end
endmodule