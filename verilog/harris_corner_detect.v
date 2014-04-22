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
   	sobel #(.p_num_bits(1))point_x11 
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

  //  	sobel point_x12 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x13 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x21 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x22 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x23 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x31 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x32 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);

  //  	sobel point_x33 #(.p_num_bits(1))(
  //  		.x00(), 
		// .x01(), 
		// .x02(), 
		// .x10(), 
		// .x11(), 
		// .x12(), 
		// .x20(), 
		// .x21(), 
		// .x22(), 
		// .Ix(), 
		// .Iy()
  //  	);


endmodule