module sobel
#(
	parameter p_num_bits = 1, 

	//Do not change outside of module
	// max value based on value in * 4 + sign bit
	parameter c_out_num_bits = $clog2((2**p_num_bits - 1) * 4) + 1 + 1
	)
(
	input [p_num_bits-1:0] x00, 
	input [p_num_bits-1:0] x01, 
	input [p_num_bits-1:0] x02, 
	input [p_num_bits-1:0] x10, 
	input [p_num_bits-1:0] x11, 
	input [p_num_bits-1:0] x12, 
	input [p_num_bits-1:0] x20, 
	input [p_num_bits-1:0] x21, 
	input [p_num_bits-1:0] x22, 
	output signed [c_out_num_bits-1:0] Ix, 
	output signed [c_out_num_bits-1:0] Iy

	);
	//sobel operator: 
	/**	   S_x   -> flipepd
		-1 0 1 	     1 0 -1
		-2 0 2 		 2 0 -2
		-1 0 1       1 0 -1
			S_y   -> flipped
		 1  2  1     -1 -2 -1
		 0  0  0      0  0  0 
		-1 -2 -1      1  2  1

	*/

	wire signed [p_num_bits+1:0] x00_signed = {2'b0, x00};
	wire signed [p_num_bits+1:0] x01_signed = {2'b0, x01};
	wire signed [p_num_bits+1:0] x02_signed = {2'b0, x02};

	wire signed [p_num_bits+1:0] x10_signed = {2'b0, x10};
	wire signed [p_num_bits+1:0] x12_signed = {2'b0, x12};
	
	wire signed [p_num_bits+1:0] x20_signed = {2'b0, x20};
	wire signed [p_num_bits+1:0] x21_signed = {2'b0, x21};
	wire signed [p_num_bits+1:0] x22_signed = {2'b0, x22};


	assign Ix = x00_signed - x02_signed 
				+ (x10_signed <<< 1) - (x12_signed<<<1)
				+ x20_signed - x22_signed;
	assign Iy = -x00_signed - (x01_signed<<<1) - x02_signed
				+x20_signed + (x21_signed<<<1) + x22_signed;
	


endmodule