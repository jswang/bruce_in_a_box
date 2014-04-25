///////////////////////////////////////////////////////
// 5 Line Buffer with taps for use in edge detection //
///////////////////////////////////////////////////////

module buffer5
#(
	parameter p_bit_width_in = 24
	)
(
	clk,
	ram_clr,
	clken,
	shiftin,
	shiftout,
	oGrid);
	
	input		wire			clk,clken, ram_clr;
	input		wire	[p_bit_width_in-1:0]	shiftin;
	
	integer i;
	
	//probably should store intensity value into "Grid," not RGB value, for use in edgedetect
	//RGB value will only be used in line buffer, and will be output to screen if not edge
	//if it is an edge, we will output black (or whatever color we choose for the line)
	output	wire	[p_bit_width_in*25-1:0]	oGrid;
	output	wire	[p_bit_width_in-1:0]	shiftout;

	wire [p_bit_width_in-1:0] tap5, tap4, tap3, tap2, tap1;
	reg  [p_bit_width_in-1:0] x00, x01, x02, x303, x04, 
			   				  x10, x11, x12, x13, x14, 
			   				  x20, x21, x22, x23, x24, 
			   				  x30, x31, x32, x33, x34, 
			   				  x40, x41, x42, x43, x44;

	ram_shift shift_buffer (
		.aclr(ram_clr), 
		.clken(clken), 
		.clock(clk), 
		.shiftin(shiftin), 
		.shiftout(shiftout), 
		.taps({tap5, tap4, tap3, tap2, tap1})
	);
	
	//assign oGrid = {grid_2d[8],grid_2d[7],grid_2d[6],grid_2d[5],grid_2d[4],grid_2d[3],grid_2d[2],grid_2d[1],grid_2d[0]};
	
	assign oGrid = {x00, x01, x02, x03, x04,
					x10, x11, x12, x13, x14,
					x20, x21, x22, x23, x24,			
					x30, x31, x32, x33, x34,
					x40, x41, x42, x43, x44};		

	
	always @ (posedge clk) begin
		if(clken) begin
			  x00 <= x01;
			  x01 <= x02;
			  x02 <= x03;
			  x03 <= x04;
			  x04 <= shiftin;
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

	end
endmodule
