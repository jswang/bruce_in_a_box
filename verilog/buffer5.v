///////////////////////////////////////////////////////
// 5 Line Buffer with taps for use in edge detection //
///////////////////////////////////////////////////////

module buffer5
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

	wire [p_bit_width_in-1:0] tap5, tap4, tap3, tap2, tap1;
	reg  [p_bit_width_in-1:0] x00, x01, x02, x03, x04, 
			   				  x10, x11, x12, x13, x14, 
			   				  x20, x21, x22, x23, x24, 
			   				  x30, x31, x32, x33, x34, 
			   				  x40, x41, x42, x43, x44;

	ram_shift shift_buffer (
		.aclr(1'b0), 
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
			x00 <= tap1;
			x01 <= x00;
			x02 <= x01;
			x03 <= x02;
			x04 <= x03;

			x10 <= tap2;
			x11 <= x10;
			x12 <= x11;
			x13 <= x12;
			x14 <= x13;

			x20 <= tap3;
			x21 <= x20;
			x22 <= x21;
			x23 <= x22;
			x24 <= x23;

			x30 <= tap4;
			x31 <= x30;
			x32 <= x31;
			x33 <= x32;
			x34 <= x33;

			x40 <= tap5;
			x41 <= x40;
			x42 <= x41;
			x43 <= x42;
			x44 <= x43;
		end

	end


endmodule




module buffer5_orig
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
	output	reg		[p_bit_width_in-1:0]	shiftout;
	
	reg	[p_bit_width_in-1:0]	line1 	[639:0];
	reg	[p_bit_width_in-1:0]	line2	[639:0];
	reg	[p_bit_width_in-1:0]	line3	[639:0];
	reg	[p_bit_width_in-1:0]	line4	[639:0];
	reg	[p_bit_width_in-1:0]	line5	[639:0];
	//reg	[p_bit_width_in-1:0]	grid_2d	[8:0];
	
	//assign oGrid = {grid_2d[8],grid_2d[7],grid_2d[6],grid_2d[5],grid_2d[4],grid_2d[3],grid_2d[2],grid_2d[1],grid_2d[0]};
	
	assign oGrid = {line1[639],line1[638],line1[637], line1[636], line1[635],		
					line2[639],line2[638],line2[637], line2[636], line2[635],		
					line3[639],line3[638],line3[637], line3[636], line3[635],
					line4[639],line4[638],line4[637], line4[636], line4[635],
					line5[639],line5[638],line5[637], line5[636], line5[635]
				};		

	
	always @ (posedge clk) begin
		if(clken) begin
			line1[0] <= shiftin;
			line2[0] <= line1[639];
			line3[0] <= line2[639];
			line4[0] <= line3[639];
			line5[0] <= line4[639];
			for(i=1;i<640;i=i+1)begin
				line1[i] <= line1[i-1];
				line2[i] <= line2[i-1];
				line3[i] <= line3[i-1];
				line4[i] <= line4[i-1];
				line5[i] <= line5[i-1];
			end
			shiftout <= line5[638];
			//grid_2d[8:0] <= {line3[639:637],line2[639:637],line1[639:637]};
		end
		else begin
			for(i=0;i<640;i=i+1)begin
				line1[i] <= line1[i];
				line2[i] <= line2[i];
				line3[i] <= line3[i];
				line4[i] <= line4[i];
				line5[i] <= line5[i];
			end
			shiftout <= shiftout;
		end
	end


endmodule
