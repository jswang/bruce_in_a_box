module harris_corner_detect_7 (
	input clk, 
	input reset, 
	input clk_en,
  input [7:0] VGA_R, 
  input [7:0] VGA_G, 
  input [7:0] VGA_B,
	input unsigned [7:0] scale,

	output signed [53:0] harris_feature
);

	//7x7 Buffering
	wire [23:0] x00, x01, x02, x03, x04, x05, x06, 
              x10, x11, x12, x13, x14, x15, x16, 
              x20, x21, x22, x23, x24, x25, x26, 
              x30, x31, x32, x33, x34, x35, x36, 
              x40, x41, x42, x43, x44, x45, x46, 
              x50, x51, x52, x53, x54, x55, x56, 
              x60, x61, x62, x63, x64, x65, x66;
	
	buffer7 #(.p_bit_width_in(24)) buffer (
		.clk(clk), 
		.clken(clk_en), 
		.shiftin({Cb, Cr}), 
		.oGrid({x00, x01, x02, x03, x04, x05, x06, 
            x10, x11, x12, x13, x14, x15, x16, 
            x20, x21, x22, x23, x24, x25, x26, 
            x30, x31, x32, x33, x34, x35, x36, 
            x40, x41, x42, x43, x44, x45, x46, 
            x50, x51, x52, x53, x54, x55, x56, 
            x60, x61, x62, x63, x64, x65, x66})
	);

	//Calculating Gradients using Sobel Filter
	wire signed [12:0] x11_Ix, x12_Ix, x13_Ix, x14_Ix, x15_Ix, 
					           x21_Ix, x22_Ix, x23_Ix, x24_Ix, x25_Ix,
					           x31_Ix, x32_Ix, x33_Ix, x34_Ix, x35_Ix, 
                     x41_Ix, x42_Ix, x43_Ix, x44_Ix, x45_Ix, 
                     x51_Ix, x52_Ix, x53_Ix, x54_Ix, x55_Ix;
	wire signed [12:0] x11_Iy, x12_Iy, x13_Iy, x14_Iy, x15_Iy, 
                     x21_Iy, x22_Iy, x23_Iy, x24_Iy, x25_Iy,
                     x31_Iy, x32_Iy, x33_Iy, x34_Iy, x35_Iy, 
                     x41_Iy, x42_Iy, x43_Iy, x44_Iy, x45_Iy, 
                     x51_Iy, x52_Iy, x53_Iy, x54_Iy, x55_Iy;
	sobel sobel_x11(
   		.clk(clk),
   		.x00(x00), .x01(x01), .x02(x02), 
		  .x10(x10), .x11(x11), .x12(x12), 
		  .x20(x20), .x21(x21), .x22(x22), 
		  .Ix(x11_Ix), 
		  .Iy(x11_Iy)
   	);

   	sobel sobel_x12(
   		.clk(clk),
   		.x00(x01), .x01(x02), .x02(x03), 
		  .x10(x11), .x11(x12), .x12(x13), 
		  .x20(x21), .x21(x22), .x22(x23), 
		  .Ix(x12_Ix), 
		  .Iy(x12_Iy)
   	);

   	sobel sobel_x13(
   		.clk(clk),
   		.x00(x02), .x01(x03), .x02(x04), 
		  .x10(x12), .x11(x13), .x12(x14), 
		  .x20(x22), .x21(x23), .x22(x24), 
		  .Ix(x13_Ix), 
		  .Iy(x13_Iy)
   	);

    sobel sobel_x14(
      .clk(clk),
      .x00(x03), .x01(x04), .x02(x05), 
      .x10(x13), .x11(x14), .x12(x15), 
      .x20(x23), .x21(x24), .x22(x25), 
      .Ix(x14_Ix), 
      .Iy(x14_Iy)
    );

    sobel sobel_x15(
      .clk(clk),
      .x00(x04), .x01(x05), .x02(x06), 
      .x10(x14), .x11(x15), .x12(x16), 
      .x20(x24), .x21(x25), .x22(x26), 
      .Ix(x15_Ix), 
      .Iy(x15_Iy)
    );

   	sobel sobel_x21(
   		.clk(clk),
   		.x00(x10), .x01(x11), .x02(x12), 
      .x10(x20), .x11(x21), .x12(x22), 
      .x20(x30), .x21(x31), .x22(x32), 
      .Ix(x21_Ix), 
      .Iy(x21_Iy)
   	);

   	sobel sobel_x22 (
		  .clk(clk), 
		  .x00(x11), .x01(x12), .x02(x13), 
		  .x10(x21), .x11(x22), .x12(x23), 
		  .x20(x31), .x21(x32), .x22(x33),
		  .Ix(x22_Ix), 
		  .Iy(x22_Iy)
	);

   	sobel sobel_x23(
   		.clk(clk),
   		.x00(x12), .x01(x13), .x02(x14), 
		  .x10(x22), .x11(x23), .x12(x24), 
		  .x20(x32), .x21(x33), .x22(x34), 
		  .Ix(x23_Ix), 
		  .Iy(x23_Iy)
   	);

    sobel sobel_x24(
      .clk(clk),
      .x00(x13), .x01(x14), .x02(x15), 
      .x10(x23), .x11(x24), .x12(x25), 
      .x20(x33), .x21(x34), .x22(x35), 
      .Ix(x24_Ix), 
      .Iy(x24_Iy)
    );

    sobel sobel_x25(
      .clk(clk),
      .x00(x14), .x01(x15), .x02(x16), 
      .x10(x24), .x11(x25), .x12(x26), 
      .x20(x34), .x21(x35), .x22(x36), 
      .Ix(x25_Ix), 
      .Iy(x25_Iy)
    );


   	sobel sobel_x31(
   		.clk(clk),
   		.x00(x20), .x01(x21), .x02(x22), 
		  .x10(x30), .x11(x31), .x12(x32), 
		  .x20(x40), .x21(x41), .x22(x42), 
		  .Ix(x31_Ix), 
		  .Iy(x31_Iy)
   	);

   	sobel sobel_x32 (
   		.clk(clk),
   		.x00(x21), .x01(x22), .x02(x23), 
		  .x10(x31), .x11(x32), .x12(x33), 
		  .x20(x41), .x21(x42), .x22(x43), 
		  .Ix(x32_Ix), 
		  .Iy(x32_Iy)
   	);

   	sobel sobel_x33 (
   		.clk(clk),
   		.x00(x22), .x01(x23), .x02(x24), 
		  .x10(x32), .x11(x33), .x12(x34), 
		  .x20(x42), .x21(x43), .x22(x44), 
		  .Ix(x33_Ix), 
		  .Iy(x33_Iy)
   	);

    sobel sobel_x34(
      .clk(clk),
      .x00(x23), .x01(x24), .x02(x25), 
      .x10(x33), .x11(x34), .x12(x35), 
      .x20(x43), .x21(x44), .x22(x45), 
      .Ix(x34_Ix), 
      .Iy(x34_Iy)
    );

    sobel sobel_x35(
      .clk(clk),
      .x00(x24), .x01(x25), .x02(x26), 
      .x10(x34), .x11(x35), .x12(x36), 
      .x20(x44), .x21(x45), .x22(x46), 
      .Ix(x35_Ix), 
      .Iy(x35_Iy)
    );

    sobel sobel_x41(
      .clk(clk),
      .x00(x30), .x01(x31), .x02(x32), 
      .x10(x40), .x11(x41), .x12(x42), 
      .x20(x50), .x21(x51), .x22(x52), 
      .Ix(x41_Ix), 
      .Iy(x41_Iy)
    );

    sobel sobel_x42 (
      .clk(clk),
      .x00(x31), .x01(x32), .x02(x33), 
      .x10(x41), .x11(x42), .x12(x43), 
      .x20(x51), .x21(x52), .x22(x53), 
      .Ix(x42_Ix), 
      .Iy(x42_Iy)
    );

    sobel sobel_x43 (
      .clk(clk),
      .x00(x32), .x01(x33), .x02(x34), 
      .x10(x42), .x11(x43), .x12(x44), 
      .x20(x52), .x21(x53), .x22(x54), 
      .Ix(x43_Ix), 
      .Iy(x43_Iy)
    );

    sobel sobel_x44(
      .clk(clk),
      .x00(x33), .x01(x34), .x02(x35), 
      .x10(x43), .x11(x44), .x12(x45), 
      .x20(x53), .x21(x54), .x22(x55), 
      .Ix(x44_Ix), 
      .Iy(x44_Iy)
    );

    sobel sobel_x45(
      .clk(clk),
      .x00(x34), .x01(x35), .x02(x36), 
      .x10(x44), .x11(x45), .x12(x46), 
      .x20(x54), .x21(x55), .x22(x56), 
      .Ix(x45_Ix), 
      .Iy(x45_Iy)
    );

    sobel sobel_x51(
      .clk(clk),
      .x00(x40), .x01(x41), .x02(x42), 
      .x10(x50), .x11(x51), .x12(x52), 
      .x20(x60), .x21(x61), .x22(x62), 
      .Ix(x51_Ix), 
      .Iy(x51_Iy)
    );

    sobel sobel_x52 (
      .clk(clk),
      .x00(x41), .x01(x42), .x02(x43), 
      .x10(x51), .x11(x52), .x12(x53), 
      .x20(x61), .x21(x62), .x22(x63), 
      .Ix(x52_Ix), 
      .Iy(x52_Iy)
    );

    sobel sobel_x53 (
      .clk(clk),
      .x00(x42), .x01(x43), .x02(x44), 
      .x10(x52), .x11(x53), .x12(x54), 
      .x20(x62), .x21(x63), .x22(x64), 
      .Ix(x53_Ix), 
      .Iy(x53_Iy)
    );

    sobel sobel_x54(
      .clk(clk),
      .x00(x43), .x01(x44), .x02(x45), 
      .x10(x53), .x11(x54), .x12(x55), 
      .x20(x63), .x21(x64), .x22(x65), 
      .Ix(x54_Ix), 
      .Iy(x54_Iy)
    );

    sobel sobel_x65(
      .clk(clk),
      .x00(x44), .x01(x45), .x02(x46), 
      .x10(x54), .x11(x55), .x12(x56), 
      .x20(x64), .x21(x65), .x22(x66), 
      .Ix(x65_Ix), 
      .Iy(x65_Iy)
    );


   	//Perform Harris Operations
    //max value of RorGorB: 255
    //Max value of addition: 255*3 = 765
    //Max value of Ix or Iy: 765*4 = 3060 (12b + sign = [12:0])
    //Max value of Ix^2: 3060^2 =  9363600 (24b + sign bit = [24:0])
    //Max value of A: 16/4*9363600 + 8/2*9363600 + 9363600 = 84272400 (27b = [26:0])
    //Max value of determinant: A*A = (53b + sign = [53:0])
    //Max value of trace: 2*A = (28b + sign = [28:0])
    //Max value of harris_feature: A*A = (53b + sign = [53:0])
    wire signed [24:0] x11_Ix_2, x12_Ix_2, x13_Ix_2, x14_Ix_2, x15_Ix_2, 
                       x21_Ix_2, x22_Ix_2, x23_Ix_2, x24_Ix_2, x25_Ix_2,
                       x31_Ix_2, x32_Ix_2, x33_Ix_2, x34_Ix_2, x35_Ix_2, 
                       x41_Ix_2, x42_Ix_2, x43_Ix_2, x44_Ix_2, x45_Ix_2, 
                       x51_Ix_2, x52_Ix_2, x53_Ix_2, x54_Ix_2, x55_Ix_2;

    
    wire signed [24:0] x11_Iy_2, x12_Iy_2, x13_Iy_2, x14_Iy_2, x15_Iy_2, 
                       x21_Iy_2, x22_Iy_2, x23_Iy_2, x24_Iy_2, x25_Iy_2,
                       x31_Iy_2, x32_Iy_2, x33_Iy_2, x34_Iy_2, x35_Iy_2, 
                       x41_Iy_2, x42_Iy_2, x43_Iy_2, x44_Iy_2, x45_Iy_2, 
                       x51_Iy_2, x52_Iy_2, x53_Iy_2, x54_Iy_2, x55_Iy_2;

    
    wire signed [24:0] x11_Ix_Iy, x12_Ix_Iy, x13_Ix_Iy, x14_Ix_Iy, x15_Ix_Iy, 
                       x21_Ix_Iy, x22_Ix_Iy, x23_Ix_Iy, x24_Ix_Iy, x25_Ix_Iy,
                       x31_Ix_Iy, x32_Ix_Iy, x33_Ix_Iy, x34_Ix_Iy, x35_Ix_Iy, 
                       x41_Ix_Iy, x42_Ix_Iy, x43_Ix_Iy, x44_Ix_Iy, x45_Ix_Iy, 
                       x51_Ix_Iy, x52_Ix_Iy, x53_Ix_Iy, x54_Ix_Iy, x55_Ix_Iy;
    wire unsigned [26:0] A, B, C;
    wire signed [53:0] determinant, trace;

    assign x11_Ix_2 = x11_Ix * x11_Ix;
    assign x12_Ix_2 = x12_Ix * x12_Ix;
    assign x13_Ix_2 = x13_Ix * x13_Ix;
    assign x14_Ix_2 = x14_Ix * x14_Ix;
    assign x15_Ix_2 = x15_Ix * x15_Ix;
    assign x21_Ix_2 = x21_Ix * x21_Ix;
    assign x22_Ix_2 = x22_Ix * x22_Ix;
    assign x23_Ix_2 = x23_Ix * x23_Ix;
    assign x24_Ix_2 = x24_Ix * x24_Ix;
    assign x25_Ix_2 = x25_Ix * x25_Ix;
    assign x31_Ix_2 = x31_Ix * x31_Ix;
    assign x32_Ix_2 = x32_Ix * x32_Ix;
    assign x33_Ix_2 = x33_Ix * x33_Ix;
    assign x34_Ix_2 = x34_Ix * x34_Ix;
    assign x35_Ix_2 = x35_Ix * x35_Ix;
    assign x41_Ix_2 = x41_Ix * x41_Ix;
    assign x42_Ix_2 = x42_Ix * x42_Ix;
    assign x43_Ix_2 = x43_Ix * x43_Ix;
    assign x44_Ix_2 = x44_Ix * x44_Ix;
    assign x45_Ix_2 = x45_Ix * x45_Ix;
    assign x51_Ix_2 = x51_Ix * x51_Ix;
    assign x52_Ix_2 = x52_Ix * x52_Ix;
    assign x53_Ix_2 = x53_Ix * x53_Ix;
    assign x54_Ix_2 = x54_Ix * x54_Ix;
    assign x55_Ix_2 = x55_Ix * x55_Ix;

    assign x11_Iy_2 = x11_Iy * x11_Iy;
    assign x12_Iy_2 = x12_Iy * x12_Iy;
    assign x13_Iy_2 = x13_Iy * x13_Iy;
    assign x14_Iy_2 = x14_Iy * x14_Iy;
    assign x15_Iy_2 = x15_Iy * x15_Iy;
    assign x21_Iy_2 = x21_Iy * x21_Iy;
    assign x22_Iy_2 = x22_Iy * x22_Iy;
    assign x23_Iy_2 = x23_Iy * x23_Iy;
    assign x24_Iy_2 = x24_Iy * x24_Iy;
    assign x25_Iy_2 = x25_Iy * x25_Iy;
    assign x31_Iy_2 = x31_Iy * x31_Iy;
    assign x32_Iy_2 = x32_Iy * x32_Iy;
    assign x33_Iy_2 = x33_Iy * x33_Iy;
    assign x34_Iy_2 = x34_Iy * x34_Iy;
    assign x35_Iy_2 = x35_Iy * x35_Iy;
    assign x41_Iy_2 = x41_Iy * x41_Iy;
    assign x42_Iy_2 = x42_Iy * x42_Iy;
    assign x43_Iy_2 = x43_Iy * x43_Iy;
    assign x44_Iy_2 = x44_Iy * x44_Iy;
    assign x45_Iy_2 = x45_Iy * x45_Iy;
    assign x51_Iy_2 = x51_Iy * x51_Iy;
    assign x52_Iy_2 = x52_Iy * x52_Iy;
    assign x53_Iy_2 = x53_Iy * x53_Iy;
    assign x54_Iy_2 = x54_Iy * x54_Iy;
    assign x55_Iy_2 = x55_Iy * x55_Iy;

    assign x11_Ix_Iy = x11_Ix * x11_Iy;
    assign x12_Ix_Iy = x12_Ix * x12_Iy;
    assign x13_Ix_Iy = x13_Ix * x13_Iy;
    assign x14_Ix_Iy = x14_Ix * x14_Ix;
    assign x15_Ix_Iy = x15_Ix * x15_Ix;
    assign x21_Ix_Iy = x21_Ix * x21_Iy;
    assign x22_Ix_Iy = x22_Ix * x22_Iy;
    assign x23_Ix_Iy = x23_Ix * x23_Iy;
    assign x24_Ix_Iy = x24_Ix * x24_Ix;
    assign x25_Ix_Iy = x25_Ix * x25_Ix;
    assign x31_Ix_Iy = x31_Ix * x31_Iy;
    assign x32_Ix_Iy = x32_Ix * x32_Iy;
    assign x33_Ix_Iy = x33_Ix * x33_Iy;
    assign x34_Ix_Iy = x34_Ix * x34_Ix;
    assign x35_Ix_Iy = x35_Ix * x35_Ix;
    assign x41_Ix_Iy = x41_Ix * x41_Ix;
    assign x42_Ix_Iy = x42_Ix * x42_Ix;
    assign x43_Ix_Iy = x43_Ix * x43_Ix;
    assign x44_Ix_Iy = x44_Ix * x44_Ix;
    assign x45_Ix_Iy = x45_Ix * x45_Ix;
    assign x51_Ix_Iy = x51_Ix * x51_Ix;
    assign x52_Ix_Iy = x52_Ix * x52_Ix;
    assign x53_Ix_Iy = x53_Ix * x53_Ix;
    assign x54_Ix_Iy = x54_Ix * x54_Ix;
    assign x55_Ix_Iy = x55_Ix * x55_Ix;

    assign A = x11_Ix_2>>2 + x12_Ix_2>>2 + x13_Ix_2>>2 + x14_Ix_2>>2 + x15_Ix_2>>2
             + x21_Ix_2>>2 + x22_Ix_2>>1 + x23_Ix_2>>1 + x24_Ix_2>>1 + x25_Ix_2>>2
             + x31_Ix_2>>2 + x32_Ix_2>>1 + x33_Ix_2    + x34_Ix_2>>1 + x35_Ix_2>>2
             + x41_Ix_2>>2 + x42_Ix_2>>1 + x43_Ix_2>>1 + x44_Ix_2>>1 + x45_Ix_2>>2
             + x51_Ix_2>>2 + x52_Ix_2>>2 + x53_Ix_2>>2 + x54_Ix_2>>2 + x55_Ix_2>>2; 

    assign B = x11_Ix_Iy>>2 + x12_Ix_Iy>>2 + x13_Ix_Iy>>2 + x14_Ix_Iy>>2 + x15_Ix_Iy>>2
             + x21_Ix_Iy>>2 + x22_Ix_Iy>>1 + x23_Ix_Iy>>1 + x24_Ix_Iy>>1 + x25_Ix_Iy>>2
             + x31_Ix_Iy>>2 + x32_Ix_Iy>>1 + x33_Ix_Iy    + x34_Ix_Iy>>1 + x35_Ix_Iy>>2
             + x41_Ix_Iy>>2 + x42_Ix_Iy>>1 + x43_Ix_Iy>>1 + x44_Ix_Iy>>1 + x45_Ix_Iy>>2
             + x51_Ix_Iy>>2 + x52_Ix_Iy>>2 + x53_Ix_Iy>>2 + x54_Ix_Iy>>2 + x55_Ix_Iy>>2; 

    assign C = x11_Iy_2>>2 + x12_Iy_2>>2 + x13_Iy_2>>2 + x14_Iy_2>>2 + x15_Iy_2>>2
             + x21_Iy_2>>2 + x22_Iy_2>>1 + x23_Iy_2>>1 + x24_Iy_2>>1 + x25_Iy_2>>2
             + x31_Iy_2>>2 + x32_Iy_2>>1 + x33_Iy_2    + x34_Iy_2>>1 + x35_Iy_2>>2
             + x41_Iy_2>>2 + x42_Iy_2>>1 + x43_Iy_2>>1 + x44_Iy_2>>1 + x45_Iy_2>>2
             + x51_Iy_2>>2 + x52_Iy_2>>2 + x53_Iy_2>>2 + x54_Iy_2>>2 + x55_Iy_2>>2; 

    assign determinant = A*C - B*B; 
    assign trace = (A + C) >>> scale;
    assign harris_feature = (trace == 0) ? 0 : determinant/trace;

endmodule