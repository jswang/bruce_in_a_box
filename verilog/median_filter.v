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

module median_filter_corner #(
	parameter p_num_coordinates = 8,
	parameter p_filter_length = 5,  
	parameter p_bit_width_in = 11, 

	//local
	parameter c_shift_reg_length = p_filter_length * p_bit_width_in

)
(
	input clk, 
	input reset, 
	input VGA_VS, 
	input [p_num_coordinates*p_bit_width_in-1:0] data_in, 
	output [p_num_coordinates*p_bit_width_in-1:0] data_out
);

	reg [p_bit_width_in-1:0] shift_reg0 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg1 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg2 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg3 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg4 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg5 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg6 [0: p_filter_length-1];
	reg [p_bit_width_in-1:0] shift_reg7 [0: p_filter_length-1];

	reg VGA_VS_prev;
	wire falling_edge_VGA_VS = (VGA_VS_prev && ~VGA_VS);
	integer i;
	always @ (posedge clk) begin
		VGA_VS_prev <= VGA_VS;
		sort(shift_reg0[0], shift_reg0[1], shift_reg0[2], shift_reg0[3], shift_reg0[4], 
				data_out[p_bit_width_in-1:0]);
		sort(shift_reg1[0], shift_reg1[1], shift_reg1[2], shift_reg1[3], shift_reg1[4], 
				data_out[p_bit_width_in*2-1:p_bit_width_in]);
		sort(shift_reg2[0], shift_reg2[1], shift_reg2[2], shift_reg2[3], shift_reg2[4], 
				data_out[p_bit_width_in*3-1:p_bit_width_in*2]);
		sort(shift_reg3[0], shift_reg3[1], shift_reg3[2], shift_reg3[3], shift_reg3[4], 
				data_out[p_bit_width_in*4-1:p_bit_width_in*3]);
		sort(shift_reg4[0], shift_reg4[1], shift_reg4[2], shift_reg4[3], shift_reg4[4], 
				data_out[p_bit_width_in*5-1:p_bit_width_in*4]);
		sort(shift_reg5[0], shift_reg5[1], shift_reg5[2], shift_reg5[3], shift_reg5[4], 
				data_out[p_bit_width_in*6-1:p_bit_width_in*5]);
		sort(shift_reg6[0], shift_reg6[1], shift_reg6[2], shift_reg6[3], shift_reg6[4], 
				data_out[p_bit_width_in*7-1:p_bit_width_in*6]);
		sort(shift_reg7[0], shift_reg7[1], shift_reg7[2], shift_reg7[3], shift_reg7[4], 
				data_out[p_bit_width_in*8-1:p_bit_width_in*7]);
		


		if (reset) begin
			for (i=0; i < p_filter_length; i = i+ 1) begin
				shift_reg0[i] <= {p_bit_width_in{1'b0}};
				shift_reg1[i] <= {p_bit_width_in{1'b0}};
				shift_reg2[i] <= {p_bit_width_in{1'b0}};
				shift_reg3[i] <= {p_bit_width_in{1'b0}};
				shift_reg4[i] <= {p_bit_width_in{1'b0}};
				shift_reg5[i] <= {p_bit_width_in{1'b0}};
				shift_reg6[i] <= {p_bit_width_in{1'b0}};
				shift_reg7[i] <= {p_bit_width_in{1'b0}};
			end
		end
		else if (falling_edge_VGA_VS) begin
			for (i = 1; i < p_filter_length; i = i+1) begin
				shift_reg0[i] <= shift_reg0[i-1];
				shift_reg1[i] <= shift_reg1[i-1];
				shift_reg2[i] <= shift_reg2[i-1];
				shift_reg3[i] <= shift_reg3[i-1];
				shift_reg4[i] <= shift_reg4[i-1];
				shift_reg5[i] <= shift_reg5[i-1];
				shift_reg6[i] <= shift_reg6[i-1];
				shift_reg7[i] <= shift_reg7[i-1];
			end
			shift_reg0[0] <= data_in[p_bit_width_in-1:0];
			shift_reg1[0] <= data_in[p_bit_width_in*2 -1: p_bit_width_in];
			shift_reg2[0] <= data_in[p_bit_width_in*3 -1: p_bit_width_in*2];
			shift_reg3[0] <= data_in[p_bit_width_in*4 -1: p_bit_width_in*3];
			shift_reg4[0] <= data_in[p_bit_width_in*5 -1: p_bit_width_in*4];
			shift_reg5[0] <= data_in[p_bit_width_in*6 -1: p_bit_width_in*5];
			shift_reg6[0] <= data_in[p_bit_width_in*7 -1: p_bit_width_in*6];
			shift_reg7[0] <= data_in[p_bit_width_in*8 -1: p_bit_width_in*7];
		end
		
	end

	task sort; 
		input [p_bit_width_in-1:0] unsorted_array_0; 
		input [p_bit_width_in-1:0] unsorted_array_1; 
		input [p_bit_width_in-1:0] unsorted_array_2; 
		input [p_bit_width_in-1:0] unsorted_array_3; 
		input [p_bit_width_in-1:0] unsorted_array_4;

		output [p_bit_width_in-1:0] median_value;

		reg [p_bit_width_in-1:0] unsorted_array[0:4];
		reg [p_bit_width_in-1:0] temp;
		integer i; 
		integer n; 
		begin
			unsorted_array[0] = unsorted_array_0; 
			unsorted_array[1] = unsorted_array_1; 
			unsorted_array[2] = unsorted_array_2; 
			unsorted_array[3] = unsorted_array_3; 
			unsorted_array[4] = unsorted_array_4;
			for (n = 0; n < p_filter_length+1; n = n + 1) begin
	        	for (i = 1; i < p_filter_length; i = i + 1) begin
		            if (unsorted_array[i-1] > unsorted_array[i]) begin
		                //swap actual values
		                temp = unsorted_array[i]; 
		                unsorted_array[i] = unsorted_array[i-1];
		                unsorted_array[i-1] = temp;
		            end
		        end
        	end
        	median_value = unsorted_array[2];
    	end
	endtask
endmodule


