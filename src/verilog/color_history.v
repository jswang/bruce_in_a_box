module color_history (
	input clk, 
	input reset, 
	input [18:0] 		read_addr,  
	input [18:0] 		write_addr, 
	input [3:0] 		write_data, 
	input 				write_en, 

	output reg [3:0] 	read_data, 
	output reg		 	data_valid, 
	output [18:0] 		just_read_addr,

	input [9:0] 		read_x, 
	input [9:0] 		read_y, 
	output [9:0] 		just_read_x, 
	output [9:0] 		just_read_y
);
	//Shift buffer for read address
	reg [18:0] shift_buffer_read_addr [0:2];
	reg [9:0] shift_buffer_read_x [0:2];
	reg [9:0] shift_buffer_read_y [0:2];

	assign just_read_addr = shift_buffer_read_addr[2];
	assign just_read_x = shift_buffer_read_x[2];
	assign just_read_y = shift_buffer_read_y[2];

    reg [18:0] addr_a, addr_b;
    reg [3:0]  data_in_a, data_in_b;
    reg        we_a, we_b;
    wire [3:0] data_out_a, data_out_b;  
    
    dual_SRAM color_history_buffer (
        .clock(clk), 
        .address_a(addr_a), 
        .data_a(data_in_a), 
        .wren_a(we_a), 
        .q_a(data_out_a), 

        .address_b(addr_b), 
        .data_b(data_in_b), 
        .wren_b(we_b), 
        .q_b(data_out_b)
    );


reg [3:0] state; 
reg 	  clear_mem;
reg [18:0] addr;

always @ (posedge clk) begin
	if (reset) begin
		addr_a          <= 19'd0;
        addr_b          <= 19'd1;
        addr            <= 19'd0;
        data_in_a       <= 4'd0;
        data_in_b       <= 4'd0;
        we_a            <= 1'b1;
        we_b            <= 1'b1;

        shift_buffer_read_addr[0] 	= 19'd0;
        shift_buffer_read_addr[1] 	= 19'd0;
        shift_buffer_read_addr[2] 	= 19'd0;
        shift_buffer_read_x[0] 		= 10'd0;
        shift_buffer_read_x[1] 		= 10'd0;
        shift_buffer_read_x[2] 		= 10'd0;
        shift_buffer_read_y[0] 		= 10'd0;
        shift_buffer_read_y[1] 		= 10'd0;
        shift_buffer_read_y[2] 		= 10'd0;


        data_valid 		<= 1'b0;
		state     		<= 4'd0;
		clear_mem 		<= 1'b1;
	end
	//clear memory upon reset
	else if (clear_mem) begin
		//Not done with array
        if (addr < 19'd307198) begin
            addr_a      <= addr_a + 19'd2;
            addr_b      <= addr_b + 19'd2;
            addr 		<= addr + 19'd2;
            data_in_a   <= 4'd0;
            data_in_b   <= 4'd0;
            we_a        <= 1'b1;
            we_b        <= 1'b1;
            clear_mem   <= 1'b1;
        end
        else begin
            clear_mem   <= 1'b0;
            we_a        <= 1'b0;
            we_b        <= 1'b0;
        end
	end

	else begin
		//Write if commanded to
		we_b 			<= write_en;
		addr_b 			<= write_addr;
		data_in_b 		<= write_data;

		//Continuosly read out data
		case (state)
			4'd0: begin
				addr_a <= read_addr;
				
				shift_buffer_read_addr[2] <= shift_buffer_read_addr[1];
				shift_buffer_read_addr[1] <= shift_buffer_read_addr[0];
				shift_buffer_read_addr[0] <= read_addr;
				shift_buffer_read_x[2] <= shift_buffer_read_x[1];
				shift_buffer_read_x[1] <= shift_buffer_read_x[0];
				shift_buffer_read_x[0] <= read_x;
				shift_buffer_read_y[2] <= shift_buffer_read_y[1];
				shift_buffer_read_y[1] <= shift_buffer_read_y[0];
				shift_buffer_read_y[0] <= read_y;

				we_a   <= 1'b0;
				state  <= state + 4'd1;
			end
			4'd1: begin
				addr_a <= read_addr;

				shift_buffer_read_addr[2] <= shift_buffer_read_addr[1];
				shift_buffer_read_addr[1] <= shift_buffer_read_addr[0];
				shift_buffer_read_addr[0] <= read_addr;
				shift_buffer_read_x[2] <= shift_buffer_read_x[1];
				shift_buffer_read_x[1] <= shift_buffer_read_x[0];
				shift_buffer_read_x[0] <= read_x;
				shift_buffer_read_y[2] <= shift_buffer_read_y[1];
				shift_buffer_read_y[1] <= shift_buffer_read_y[0];
				shift_buffer_read_y[0] <= read_y;

				state  <= state + 4'd1;
			end
			//Steady state
			4'd2: begin
				//output data from two cycles ago
				data_valid <= 1'b1;
				read_data  <= data_out_a;

				shift_buffer_read_addr[2] <= shift_buffer_read_addr[1];
				shift_buffer_read_addr[1] <= shift_buffer_read_addr[0];
				shift_buffer_read_addr[0] <= read_addr;
				shift_buffer_read_x[2] <= shift_buffer_read_x[1];
				shift_buffer_read_x[1] <= shift_buffer_read_x[0];
				shift_buffer_read_x[0] <= read_x;
				shift_buffer_read_y[2] <= shift_buffer_read_y[1];
				shift_buffer_read_y[1] <= shift_buffer_read_y[0];
				shift_buffer_read_y[0] <= read_y;

				//Pipeline for next read
				addr_a 	   <= read_addr;
				state 	   <= state;
			end
			
		endcase
	end
end

endmodule