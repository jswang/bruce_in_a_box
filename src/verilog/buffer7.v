///////////////////////////////////////////////////////
// 7 Line Buffer with taps for use in edge detection //
///////////////////////////////////////////////////////

module buffer7
#(
	parameter p_bit_width_in = 24
	)
(
	clk,
	clken,
	shiftin,
	shiftout,
	oGrid);
	
	input		wire			clk,clken;
	input		wire	[p_bit_width_in-1:0]	shiftin;
	
	integer i;
	
	//probably should store intensity value into "Grid," not RGB value, for use in edgedetect
	//RGB value will only be used in line buffer, and will be output to screen if not edge
	//if it is an edge, we will output black (or whatever color we choose for the line)
	output	wire	[p_bit_width_in*25-1:0]	oGrid;
	output	wire	[p_bit_width_in-1:0]	shiftout;

	wire [p_bit_width_in-1:0] tap7, tap6, tap5, tap4, tap3, tap2, tap1;
	reg  [p_bit_width_in-1:0] x00, x01, x02, x03, x04, x05, x06, 
			   				  x10, x11, x12, x13, x14, x15, x16, 
			   				  x20, x21, x22, x23, x24, x25, x26, 
			   				  x30, x31, x32, x33, x34, x35, x36, 
			   				  x40, x41, x42, x43, x44, x45, x46, 
			   				  x50, x51, x52, x53, x54, x55, x56, 
			   				  x60, x61, x62, x63, x64, x65, x66;

	ram_shift7 shift_buffer (
		.clken(clken), 
		.clock(clk), 
		.shiftin(shiftin), 
		.shiftout(shiftout), 
		.taps({tap7, tap6, tap5, tap4, tap3, tap2, tap1})
	);
	
	//assign oGrid = {grid_2d[8],grid_2d[7],grid_2d[6],grid_2d[5],grid_2d[4],grid_2d[3],grid_2d[2],grid_2d[1],grid_2d[0]};
	
	assign oGrid = {x00, x01, x02, x03, x04, x05, x06, 
			   		x10, x11, x12, x13, x14, x15, x16, 
			   		x20, x21, x22, x23, x24, x25, x26, 
			   		x30, x31, x32, x33, x34, x35, x36, 
			   		x40, x41, x42, x43, x44, x45, x46, 
			   		x50, x51, x52, x53, x54, x55, x56, 
			   		x60, x61, x62, x63, x64, x65, x66};		

	
	always @ (posedge clk) begin
		if(clken) begin
			  x00 <= x01;
			  x01 <= x02;
			  x02 <= x03;
			  x03 <= x04;
			  x04 <= x05; 
			  x05 <= x06; 
			  x06 <= shiftin;
			  x10 <= x11;
			  x11 <= x12;
			  x12 <= x13;
			  x13 <= x14;
			  x14 <= x15; 
			  x15 <= x16; 
			  x16 <= tap1;
			  x20 <= x21;
			  x21 <= x22;
			  x22 <= x23;
			  x23 <= x24;
			  x24 <= x25; 
			  x25 <= x26; 
			  x26 <= tap2;
			  x30 <= x31;
			  x31 <= x32;
			  x32 <= x33;
			  x33 <= x34;
			  x34 <= x35; 
			  x35 <= x36; 
			  x36 <= tap3;
			  x40 <= x41;
			  x41 <= x42;
			  x42 <= x43;
			  x43 <= x44;
			  x44 <= x45; 
			  x45 <= x46; 
			  x46 <= tap4;
			  x50 <= x51;
			  x51 <= x52;
			  x52 <= x53;
			  x53 <= x54;
			  x54 <= x55; 
			  x55 <= x56; 
			  x56 <= tap5;
			  x60 <= x61;
			  x61 <= x62;
			  x62 <= x63;
			  x63 <= x64;
			  x64 <= x65; 
			  x65 <= x66; 
			  x66 <= tap6;

			//My way
			// x00 <= tap1;
			// x01 <= x00;
			// x02 <= x01;
			// x03 <= x02;
			// x04 <= x03;

			// x10 <= tap2;
			// x11 <= x10;
			// x12 <= x11;
			// x13 <= x12;
			// x14 <= x13;

			// x20 <= tap3;
			// x21 <= x20;
			// x22 <= x21;
			// x23 <= x22;
			// x24 <= x23;

			// x30 <= tap4;
			// x31 <= x30;
			// x32 <= x31;
			// x33 <= x32;
			// x34 <= x33;

			// x40 <= tap5;
			// x41 <= x40;
			// x42 <= x41;
			// x43 <= x42;
			// x44 <= x43;
		end

	end


endmodule


