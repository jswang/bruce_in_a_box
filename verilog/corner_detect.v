//Detects a predetermined color. 
//Using the least squares formula

//Detects green
module corner_detect
(   
    input clk,
    input reset, 
    input [7:0] Cb, 
    input [7:0] Cr,
    input [9:0] x, 
    input [9:0] y, 
    input [7:0] threshold_Cb,
    input [7:0] threshold_Cr, 
    output reg corner_detected, 
    output reg clear_mem

);
    reg [18:0] addr_a, addr_b;
    reg [3:0]  data_in_a, data_in_b;
    reg        we_a, we_b;
    wire [3:0] data_out_a, data_out_b;  
    dual_SRAM color_history (
        .clock(clk), 
        .address_a(addr_a), 
        .address_b(addr_b), 
        .data_a(data_in_a), 
        .data_b(data_in_b), 
        .wren_a(we_a), 
        .wren_b(we_b), 
        .q_a(data_out_a), 
        .q_b(data_out_b)
    );

    //19 bits of M9K address = {10bit x, 9bit y}
    reg [3:0] state; 
    // reg clear_mem;
    reg [9:0] addr_x;
    reg [9:0] addr_y; 
    always @ (posedge clk) begin
        if (reset) begin
            addr_a          <= {10'd0, 9'd0};
            addr_b          <= {10'd0, 9'd1};
            addr_x          <= 10'd0;
            addr_y          <= 10'd0;
            data_in_a       <= 4'd0;
            data_in_b       <= 4'd0;
            we_a            <= 1'b1;
            we_b            <= 1'b1;

            corner_detected <= 1'b0;
            state           <= 4'd0;
            clear_mem       <= 1'b1;
        end
        //Clear the memory upon reset
        else if (clear_mem) begin
            //Not done with row
            if (addr_y < 10'd478) begin
                addr_a      <= {addr_x, addr_y[8:0] + 9'd2};
                addr_b      <= {addr_x, addr_y[8:0] + 9'd3};
                addr_y      <= addr_y + 10'd2;
                data_in_a   <= 4'd0;
                data_in_b   <= 4'd0;
                we_a        <= 1'b1;
                we_b        <= 1'b1;
                clear_mem   <= 1'b1;
            end
            //Done with row, but not all rows
            else if (addr_x < 10'd639) begin
                addr_a      <= {addr_x + 10'd1, 9'd0}; 
                addr_b      <= {addr_x + 10'd1, 9'd1}; 
                addr_x      <= addr_x + 10'd1;
                addr_y      <= 10'd0;
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
            if (Cb < threshold_Cb && Cr < threshold_Cr) begin
                corner_detected <= 1'b1;
            end
            else begin
                corner_detected <= 1'b0;
            end
                
        end
    end


endmodule 
    //Corners: 
    /**
        edge case: perfectly aligned square
            1: topmost and leftmost

        otherwise: 
            1: topmost
            2: rightmost
            3: bottomost
            4: leftmost
    
    Find the left most, right most, up, down coordinates
    If this pixel is green:
        read from sram and write back the current value
        if it has been green for the past 4 frames: 
            consider for min/maxing

    Determine where corners are
    if (area around ideal corners > threshold * #green_pixels) {
        use perfect case: (left, up), (left, down), (right, up), (right, down)
    }
    else {
        use original edge coordinates: (left, ), (right, ), ( , up), ( , down)
    }

    must keep track of all of the pixels marked as green. see if portion is ok

    */