module delay 
#(	
    parameter DATA_WIDTH = 1, 
	parameter DELAY = 20, 

    //internal
    parameter SHIFT_REG_WIDTH = DATA_WIDTH*DELAY
)
(
	input 						    clk, 
	input      [DATA_WIDTH-1:0] data_in, 
	output     [DATA_WIDTH-1:0] data_out
); 

reg [SHIFT_REG_WIDTH-1:0] shift_reg;
assign data_out = shift_reg[SHIFT_REG_WIDTH-1:SHIFT_REG_WIDTH-DATA_WIDTH];

always @ (posedge clk) begin
        shift_reg[SHIFT_REG_WIDTH-1:DATA_WIDTH] <= shift_reg[SHIFT_REG_WIDTH-1-DATA_WIDTH:0];
        shift_reg[DATA_WIDTH-1:0] <= data_in;
end
    
endmodule