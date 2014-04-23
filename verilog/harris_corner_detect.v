module harris_corner_detect (
	input clk, 
	input reset, 
	input clk_en,
	input [7:0] VGA_R, 
	input [7:0] VGA_G, 
	input [7:0] VGA_B, 
	input [17:0] threshold,
	input [3:0] scale,
	output signed [17:0] harris_feature
);

    localparam x = 0;
    localparam y = 1;

	//5x5 Buffering
	wire [23:0] x00, x01, x02, x03, x04,
				x10, x11, x12, x13, x14, 
				x20, x21, x22, x23, x24,
				x30, x31, x32, x33, x34,
				x40, x41, x42, x43, x44;
	
	buffer5 #(.p_bit_width_in(24)) buffer (
		.clk(clk), 
		.clken(clk_en), 
		.shiftin({VGA_R,VGA_G,VGA_B}), 
		.oGrid({x00, x01, x02, x03, x04,
				x10, x11, x12, x13, x14,
				x20, x21, x22, x23, x24,			
				x30, x31, x32, x33, x34,
				x40, x41, x42, x43, x44})
	);
	//Retrieving gradients
	wire signed [12:0] Ix_x11, Ix_x12, Ix_x13, 
					   Ix_x21, Ix_x22, Ix_x23, 
					   Ix_x31, Ix_x32, Ix_x33;
	wire signed [12:0] Iy_x11, Iy_x12, Iy_x13, 
					   Iy_x21, Iy_x22, Iy_x23, 
					   Iy_x31, Iy_x32, Iy_x33;
	
	sobel sobel_x11(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x00), .x01(x01), .x02(x02), 
		.x10(x10), .x11(x11), .x12(x12), 
		.x20(x20), .x21(x21), .x22(x22), 
		.p(), 
		.Ix(Ix_x11), 
		.Iy(Iy_x11)
   	);

   	sobel sobel_x12(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x01), .x01(x02), .x02(x03), 
		.x10(x11), .x11(x12), .x12(x13), 
		.x20(x21), .x21(x22), .x22(x23), 
		.p(),
		.Ix(Ix_x12), 
		.Iy(Iy_x12)
   	);

   	sobel sobel_x13(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x02), .x01(x03), .x02(x04), 
		.x10(x12), .x11(x13), .x12(x14), 
		.x20(x22), .x21(x23), .x22(x24), 
		.p(),
		.Ix(Ix_x13), 
		.Iy(Iy_x13)
   	);

   	sobel sobel_x21(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x10), .x01(x11), .x02(x12), 
		.x10(x20), .x11(x21), .x12(x22), 
		.x20(x30), .x21(x31), .x22(x32), 
		.p(),
		.Ix(Ix_x21), 
		.Iy(Iy_x21)
   	);

   	sobel sobel_x22 (
		.clk(clk), 
		.threshold(threshold),
		.x00(x11), .x01(x12), .x02(x13), 
		.x10(x21), .x11(x22), .x12(x23), 
		.x20(x31), .x21(x32), .x22(x33),
		.p(), 
		.Ix(Ix_x22), 
		.Iy(Iy_x22)
	);

   	sobel sobel_x23(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x12), .x01(x13), .x02(x14), 
		.x10(x22), .x11(x23), .x12(x24), 
		.x20(x32), .x21(x33), .x22(x34), 
		.p(),
		.Ix(Ix_x23), 
		.Iy(Iy_x23)
   	);

   	sobel sobel_x31(
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x20), .x01(x21), .x02(x22), 
		.x10(x30), .x11(x31), .x12(x32), 
		.x20(x40), .x21(x41), .x22(x42), 
		.p(), 
		.Ix(Ix_x31), 
		.Iy(Iy_x31)
   	);

   	sobel sobel_x32 (
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x21), .x01(x22), .x02(x23), 
		.x10(x31), .x11(x32), .x12(x33), 
		.x20(x41), .x21(x42), .x22(x43), 
		.p(), 
		.Ix(Ix_x32), 
		.Iy(Iy_x32)
   	);

   	sobel sobel_x33 (
   		.clk(clk),
   		.threshold(threshold),
   		.x00(x22), .x01(x23), .x02(x24), 
		.x10(x32), .x11(x33), .x12(x34), 
		.x20(x42), .x21(x43), .x22(x44), 
		.p(),
		.Ix(Ix_x33), 
		.Iy(Iy_x33)
   	);
   	//Max value of Ix and Iy are 4*(255*3) = 3060
   	//Using 18 bits b/c multipliers are 9x9, should utilize fully
    harris_operator #(.p_num_bits_in(13)) harris_x22 
    (
    	.scale(scale),
        .x00_Ix(Ix_x11), .x01_Ix(Ix_x12), .x02_Ix(Ix_x13), 
        .x10_Ix(Ix_x21), .x11_Ix(Ix_x22), .x12_Ix(Ix_x23), 
        .x20_Ix(Ix_x31), .x21_Ix(Ix_x32), .x22_Ix(Ix_x33), 

        .x00_Iy(Iy_x11), .x01_Iy(Iy_x12), .x02_Iy(Iy_x13), 
        .x10_Iy(Iy_x21), .x11_Iy(Iy_x22), .x12_Iy(Iy_x23), 
        .x20_Iy(Iy_x31), .x21_Iy(Iy_x32), .x22_Iy(Iy_x33), 

        .out(harris_feature)
    );

endmodule