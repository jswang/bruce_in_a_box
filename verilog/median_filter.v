module median_filter (
	input clk,
	input reset, 
	input ram_clr, 
	input VGA_BLANK_N,
	input data_in, 

	output reg data_out
);
	reg buf_shift_en;
    reg [9:0] pixel_count;
   	always @ (posedge clk)
  	begin
	    //VGA_BLANK_N is high when there is no valid horizonatl or
	    //vertical pixels being submitted. So you should count up 
	    if (!reset && VGA_BLANK_N)
	    begin
	      if (pixel_count > 639)
	        buf_shift_en <= 1'b0;
	      else
	        buf_shift_en <= 1'b1;
	      pixel_count  <= pixel_count + 10'd1;
	    end
	    else
	    begin
	      buf_shift_en <= 1'b0;
	      pixel_count  <= 10'd0;
	    end
  	end

  	//5x5 buffering
  	wire [24:0] buffer_out;
	buffer5_1bit #(.p_bit_width_in(1)) buffer (
		.clk(clk), 
		.ram_clr(ram_clr), 
		.clken(buf_shift_en), 
		.shiftin(data_in), 
		.oGrid(buffer_out)
	);

	always @ (posedge clk ) begin
		if (COUNT(buffer_out) > 12) data_out <= 1'b1;
		else 						data_out <= 1'b0;
	end
	

	function integer COUNT;
	input [24:0] in; 
	integer i;
	begin
		COUNT = 0;
		for (i = 0; i < 25; i = i + 1) begin
			if (in[i])
				COUNT = COUNT + 1;
		end
	end
	endfunction
endmodule

