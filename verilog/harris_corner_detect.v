module harris_corner_detect (
	input clk, 
	input reset, 
	input clk_en,
	input [7:0] VGA_R, 
	input [7:0] VGA_G, 
	input [7:0] VGA_B, 
	input signed [17:0] threshold,
	input [7:0] scale,
	output signed [17:0] harris_feature, 
	output reg   		 corner_detected
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
	wire signed [12:0] x11_Ix, x12_Ix, x13_Ix, 
					   x21_Ix, x22_Ix, x23_Ix, 
					   x31_Ix, x32_Ix, x33_Ix;
	wire signed [12:0] x11_Iy, x12_Iy, x13_Iy, 
					   x21_Iy, x22_Iy, x23_Iy, 
					   x31_Iy, x32_Iy, x33_Iy;
	
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

   	//Perform Harris Operations
   	//Max value of Ix and Iy are 4*(255*3) = 3060
   	//Using 18 bits b/c multipliers are 9x9, should utilize fully
   	
    wire signed [25:0] x11_Ix_2, x12_Ix_2, x13_Ix_2, 
                       x21_Ix_2, x22_Ix_2, x23_Ix_2,
                       x31_Ix_2, x32_Ix_2, x33_Ix_2;

    
    wire signed [25:0] x11_Iy_2, x12_Iy_2, x13_Iy_2, 
                       x21_Iy_2, x22_Iy_2, x23_Iy_2, 
                       x31_Iy_2, x32_Iy_2, x33_Iy_2;

    
    wire signed [25:0] x11_Ix_Iy, x12_Ix_Iy, x13_Ix_Iy, 
                       x21_Ix_Iy, x22_Ix_Iy, x23_Ix_Iy, 
                       x31_Ix_Iy, x32_Ix_Iy, x33_Ix_Iy;

    assign x11_Ix_2 = x11_Ix * x11_Ix;
    assign x12_Ix_2 = x12_Ix * x12_Ix;
    assign x13_Ix_2 = x13_Ix * x13_Ix;
    assign x21_Ix_2 = x21_Ix * x21_Ix;
    assign x22_Ix_2 = x22_Ix * x22_Ix;
    assign x23_Ix_2 = x23_Ix * x23_Ix;
    assign x31_Ix_2 = x31_Ix * x31_Ix;
    assign x32_Ix_2 = x32_Ix * x32_Ix;
    assign x33_Ix_2 = x33_Ix * x33_Ix;

    assign x11_Iy_2 = x11_Iy * x11_Iy;
    assign x12_Iy_2 = x12_Iy * x12_Iy;
    assign x13_Iy_2 = x13_Iy * x13_Iy;
    assign x21_Iy_2 = x21_Iy * x21_Iy;
    assign x22_Iy_2 = x22_Iy * x22_Iy;
    assign x23_Iy_2 = x23_Iy * x23_Iy;
    assign x31_Iy_2 = x31_Iy * x31_Iy;
    assign x32_Iy_2 = x32_Iy * x32_Iy;
    assign x33_Iy_2 = x33_Iy * x33_Iy;

    assign x11_Ix_Iy = x11_Ix * x11_Iy;
    assign x12_Ix_Iy = x12_Ix * x12_Iy;
    assign x13_Ix_Iy = x13_Ix * x13_Iy;
    assign x21_Ix_Iy = x21_Ix * x21_Iy;
    assign x22_Ix_Iy = x22_Ix * x22_Iy;
    assign x23_Ix_Iy = x23_Ix * x23_Iy;
    assign x31_Ix_Iy = x31_Ix * x31_Iy;
    assign x32_Ix_Iy = x32_Ix * x32_Iy;
    assign x33_Ix_Iy = x33_Ix * x33_Iy;

    wire signed [27:0] A, B, C;
    wire signed [55:0] determinant, trace, harris_operator;
    assign A = x11_Ix_2 + x12_Ix_2 + x13_Ix_2
             + x21_Ix_2 + x22_Ix_2 + x23_Ix_2
             + x31_Ix_2 + x32_Ix_2 + x33_Ix_2; 

    assign B = x11_Ix_Iy + x12_Ix_Iy + x13_Ix_Iy
             + x21_Ix_Iy + x22_Ix_Iy + x23_Ix_Iy
             + x31_Ix_Iy + x32_Ix_Iy + x33_Ix_Iy; 

    assign C = x11_Iy_2 + x12_Iy_2 + x13_Iy_2
             + x21_Iy_2 + x22_Iy_2 + x23_Iy_2
             + x31_Iy_2 + x32_Iy_2 + x33_Iy_2; 

    assign determinant = A*C - B*B; 
    assign trace = (A + C) >>> scale;
    assign harris_feature = (trace == 0) ? 0 : determinant/trace;

    always @ (posedge clk) begin
    	if (harris_feature > threshold) begin
    		corner_detected <= 1'b1;
    	end
    	else begin
    		corner_detected <= 1'b0;
    	end
    end

    // harris_operator #(.p_num_bits_in(13)) harris_x22 
    // (
    // 	.scale(scale),
    //     .x00_Ix(Ix_x11), .x01_Ix(Ix_x12), .x02_Ix(Ix_x13), 
    //     .x10_Ix(Ix_x21), .x11_Ix(Ix_x22), .x12_Ix(Ix_x23), 
    //     .x20_Ix(Ix_x31), .x21_Ix(Ix_x32), .x22_Ix(Ix_x33), 

    //     .x00_Iy(Iy_x11), .x01_Iy(Iy_x12), .x02_Iy(Iy_x13), 
    //     .x10_Iy(Iy_x21), .x11_Iy(Iy_x22), .x12_Iy(Iy_x23), 
    //     .x20_Iy(Iy_x31), .x21_Iy(Iy_x32), .x22_Iy(Iy_x33), 

    //     .out(harris_feature)
    // );

endmodule