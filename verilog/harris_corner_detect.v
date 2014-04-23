module harris_corner_detect (
	input clk, 
	input reset, 
	input VGA_BLANK,
	input VGA_VS, 
	input color_detected,
	input [9:0] addr_in_x, 
	input [9:0] addr_in_y,  
	output corner_detected, 
	output reg unsigned [9:0] addr_corner_x, 
	output reg unsigned [9:0] addr_corner_y
);

	reg [9:0] 	pixel_count;
	reg 		buf_shift_en;
	always @ (posedge clk) begin
		if (reset && VGA_BLANK) begin
			if (pixel_count > 639)
				buf_shift_en <= 1'b0;
			else 
				buf_shift_en <= 1'b1;
			pixel_count <= pixel_count + 10'd1;
		end
		else begin
			buf_shift_en <= 1'b0;
			pixel_count <= 10'd0;
		end
	end

	wire [20:0] tap5, tap4, tap3, tap2, tap1;
	ram_shift buffer(
		.aclr(!VGA_VS), 
		.clock(clk && buf_shift_en), 
		.shiftin({addr_in_x, addr_in_y, color_detected}), 
		.shiftout(), 
		.taps({tap5, tap4, tap3, tap2, tap1})
	);
	reg    x00, x01, x02, x03, x04,
           x10, x11, x12, x13, x14,
           x20, x21, x22, x23, x24,
           x30, x31, x32, x33, x34,
           x40, x41, x42, x43, x44;

    always @ (posedge clk) begin
    	  x00 <= x01;
		  x01 <= x02;
		  x02 <= x03;
		  x03 <= x04;
		  x04 <= color_detected;
		  x10 <= x11;
		  x11 <= x12;
		  x12 <= x13;
		  x13 <= x14;
		  x14 <= tap1[0];
		  x20 <= x21;
		  x21 <= x22;
		  x22 <= x23;
		  x23 <= x24;
		  x24 <= tap2[0];
		  x30 <= x31;
		  x31 <= x32;
		  x32 <= x33;
		  x33 <= x34;
		  x34 <= tap3[0];
		  x40 <= x41;
		  x41 <= x42;
		  x42 <= x43;
		  x43 <= x44;
		  x44 <= tap4[0];

    end
    localparam x = 0;
    localparam y = 1;

    wire signed [3:0] x11_Ix, x12_Ix, x13_Ix,
    				  x21_Ix, x22_Ix, x23_Ix,
    			      x31_Ix, x32_Ix, x33_Ix;
    wire signed [3:0] x11_Iy, x12_Iy, x13_Iy,
    				  x21_Iy, x22_Iy, x23_Iy,
    			      x31_Iy, x32_Iy, x33_Iy;
   	sobel #(.p_num_bits(1)) point_x11 
   	(
   		.x00(x00), 
		.x01(x01), 
		.x02(x02), 
		.x10(x10), 
		.x11(x11), 
		.x12(x12), 
		.x20(x20), 
		.x21(x21), 
		.x22(x22), 
		.Ix(x11_Ix), 
		.Iy(x11_Iy)
   	);
           
   	sobel #(.p_num_bits(1)) point_x12(
   		.x00(x01), 
		.x01(x02), 
		.x02(x03), 
		.x10(x11), 
		.x11(x12), 
		.x12(x13), 
		.x20(x21), 
		.x21(x22), 
		.x22(x23), 
		.Ix(x12_Ix), 
		.Iy(x12_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x13(
   		.x00(x02), 
		.x01(x03), 
		.x02(x04), 
		.x10(x12), 
		.x11(x13), 
		.x12(x14), 
		.x20(x22), 
		.x21(x23), 
		.x22(x24), 
		.Ix(x13_Ix), 
		.Iy(x13_Iy)
   	);

   	sobel #(.p_num_bits(1))  point_x21(
   		.x00(x10), 
		.x01(x11), 
		.x02(x12), 
		.x10(x20), 
		.x11(x21), 
		.x12(x22), 
		.x20(x30), 
		.x21(x31), 
		.x22(x32), 
		.Ix(x21_Ix), 
		.Iy(x21_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x22(
   		.x00(x11), 
		.x01(x12), 
		.x02(x13), 
		.x10(x21), 
		.x11(x22), 
		.x12(x23), 
		.x20(x31), 
		.x21(x32), 
		.x22(x33), 
		.Ix(x22_Ix), 
		.Iy(x22_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x23(
   		.x00(x12), 
		.x01(x13), 
		.x02(x14), 
		.x10(x22), 
		.x11(x23), 
		.x12(x24), 
		.x20(x32), 
		.x21(x33), 
		.x22(x34), 
		.Ix(x23_Ix), 
		.Iy(x23_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x31(
   		.x00(x20), 
		.x01(x21), 
		.x02(x22), 
		.x10(x30), 
		.x11(x31), 
		.x12(x32), 
		.x20(x40), 
		.x21(x41), 
		.x22(x42), 
		.Ix(x31_Ix), 
		.Iy(x31_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x32 (
   		.x00(x21), 
		.x01(x22), 
		.x02(x23), 
		.x10(x31), 
		.x11(x32), 
		.x12(x33), 
		.x20(x41), 
		.x21(x42), 
		.x22(x43), 
		.Ix(x32_Ix), 
		.Iy(x32_Iy)
   	);

   	sobel #(.p_num_bits(1)) point_x33 (
   		.x00(x22), 
		.x01(x23), 
		.x02(x24), 
		.x10(x32), 
		.x11(x33), 
		.x12(x34), 
		.x20(x42), 
		.x21(x43), 
		.x22(x44), 
		.Ix(x33_Ix), 
		.Iy(x33_Iy)
   	);

    harris_operator #(.p_num_bits_in(4)) harris_x22 (
        .x00_Ix(x11_Ix), 
        .x01_Ix(x12_Ix), 
        .x02_Ix(x13_Ix), 
        .x10_Ix(x21_Ix), 
        .x11_Ix(x22_Ix), 
        .x12_Ix(x23_Ix), 
        .x20_Ix(x31_Ix), 
        .x21_Ix(x32_Ix), 
        .x22_Ix(x33_Ix), 
        .x00_Iy(x11_Iy), 
        .x01_Iy(x12_Iy), 
        .x02_Iy(x13_Iy), 
        .x10_Iy(x21_Iy), 
        .x11_Iy(x22_Iy), 
        .x12_Iy(x23_Iy), 
        .x20_Iy(x31_Iy), 
        .x21_Iy(x32_Iy), 
        .x22_Iy(x33_Iy), 
    );

endmodule