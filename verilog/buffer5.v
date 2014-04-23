///////////////////////////////////////////////////////
// 5 Line Buffer with taps for use in edge detection //
// Code from Cartoonifier Project. 
// Modified for use by Julie Wang jsw267@cornell.edu
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
