module color_detect
(   
    input                       clk,
    input                       reset, 
    input                       VGA_VS,
    input                       median_color,

    input [3:0]                 color_history, 
    input [18:0]                read_addr, 
    input unsigned [9:0]        read_x, 
    input unsigned [9:0]        read_y,
    input [1:0]                 threshold_history,

    output reg                  color_detected,
    output reg unsigned [18:0]  color_count,
    output reg unsigned [9:0]   color_x, 
    output reg unsigned [9:0]   color_y,

    output reg [3:0]            updated_color_history, 
    output reg                  we, 
    output reg [18:0]           write_addr
);

    reg [2:0] num_history;
    reg unsigned [9:0] x_max, x_min, y_max, y_min;
    reg VGA_VS_prev;

    //encode # 1's in color_histor
    always @(color_history) begin
        case (color_history)
            4'b0000: num_history <= 3'd0; 
            4'b0001: num_history <= 3'd1; 
            4'b0010: num_history <= 3'd1;
            4'b0011: num_history <= 3'd2;
            4'b0100: num_history <= 3'd1;
            4'b0101: num_history <= 3'd2; 
            4'b0110: num_history <= 3'd2; 
            4'b0111: num_history <= 3'd3; 
            4'b1000: num_history <= 3'd1; 
            4'b1001: num_history <= 3'd2; 
            4'b1010: num_history <= 3'd2;
            4'b1011: num_history <= 3'd3;
            4'b1100: num_history <= 3'd2;
            4'b1101: num_history <= 3'd3; 
            4'b1110: num_history <= 3'd3; 
            4'b1111: num_history <= 3'd4;  
        endcase
    end
    //Update History and current color_detected
    always @ (posedge clk) begin
        VGA_VS_prev <= VGA_VS;
        if (reset) begin
            x_max           <= 10'd0; 
            x_min           <= 10'd639;
            y_max           <= 10'd0;
            y_min           <= 10'd479;
            color_count     <= 19'd0;
            color_x         <= 10'd0;
            color_y         <= 10'd0;
        end
        else begin
            //Falling edge of VS
            if (VGA_VS_prev && ~VGA_VS) begin
                //Reset for next frame of VGA screen
                color_count     <= 19'd0;
                x_max           <= 10'd0; 
                x_min           <= 10'd639;
                y_max           <= 10'd0;
                y_min           <= 10'd479;
            end
            //otherwise keep updating
            else begin
                if (median_color && num_history > threshold_history) begin
                    color_detected              <= 1'b1;
                    color_count                 <= color_count + 19'd1;
                    color_x                     <= read_x;
                    color_y                     <= read_y;
                    updated_color_history[3:1]  <= color_history[2:0];
                    updated_color_history[0]    <= (median_color);
                    write_addr                  <= read_addr;
                    we                          <= 1'b1;

                    //Most right
                    if (read_x >= x_max && read_x < 10'd640) x_max <= read_x;
                    //Most left
                    if (read_x <= x_min && read_x < 10'd640) x_min <= read_x;
                    // lowest
                    if (read_y >= y_max && read_y < 10'd480) y_max <= read_y;
                    //highest
                    if (read_y <= y_min && read_y < 10'd480) y_min <= read_y;
                end

                else begin
                    color_detected              <= 1'b0;
                    color_x                     <= read_x;
                    color_y                     <= read_y;
                    updated_color_history[3:1]  <= color_history[2:0];
                    updated_color_history[0]    <= (median_color);
                    write_addr                  <= read_addr;
                    we                          <= 1'b1;
                end
            end
            
        end
    end

endmodule 