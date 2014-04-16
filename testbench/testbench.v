`timescale 1ns/1ns
module testbench ();
    reg reset, clk_50, start, clk_VGA;
    reg [31:0] index;
    initial begin
        clk_50 = 0;
        clk_VGA = 0;
        reset = 0;
    end

    initial begin
        #10
        reset = 1;
        #20
        reset = 0;
    end
    always begin
        #10 clk_50 = !clk_50;
    end

    always begin
        #19 clk_VGA = !clk_VGA;
    end
    reg [9:0] VGA_X, VGA_Y;

    always @ (posedge clk_50) begin
        if (reset) begin
          index <= 32'd0;
        end
        else begin
            index <= index + 32'd1;
            case (index) 
                32'd0: begin
                    VGA_X <= 10'd0;
                    VGA_Y <= 10'd0;
                end
                32'd160000: begin
                    VGA_X <= 10'd10; 
                    VGA_Y <= 10'd20;
                end
                32'd160001: begin
                    VGA_X <= 10'd30; 
                    VGA_Y <= 10'd40;
                end
                32'd160002: begin
                    VGA_X <= 10'd50; 
                    VGA_Y <= 10'd60;
                end
                32'd160003: begin
                    VGA_X <= 10'd70; 
                    VGA_Y <= 10'd80;
                end
                32'd160004: begin
                    VGA_X <= 10'd90; 
                    VGA_Y <= 10'd100;
                end

                default: begin

                end
            endcase  
        end
    end

    wire [9:0] VGA_X_d2, VGA_Y_d2;
    //Delay the VGA_X and VGA_Y so that it syncs with history reading
    delay #( .DATA_WIDTH(10), .DELAY(2) ) vga_x_delay
    (
        .clk        (clk_50), 
        .data_in    (VGA_X), 
        .data_out   (VGA_X_d2)
    );
    delay #( .DATA_WIDTH(10), .DELAY(2) ) vga_y_delay
    (
        .clk        (clk_50), 
        .data_in    (VGA_Y), 
        .data_out   (VGA_Y_d2)
    );

    //Read the history of this (x,y) pixel
    reg [9:0]   color_write_x, color_write_y;
    reg [3:0]   color_write_data;
    wire [3:0]  color_read_data;
    reg         color_we;
    wire        color_data_valid;
    wire [9:0]  just_read_x, just_read_y;
    color_history color_hist (
        .clk(clk_50), 
        .reset(reset), 
        .read_x(VGA_X), 
        .read_y(VGA_Y), 
        .write_x(color_write_x), 
        .write_y(color_write_y), 
        .write_data(color_write_data), 
        .write_en(color_we), 

        .read_data(color_read_data), 
        .data_valid(color_data_valid), 
        .just_read_x(just_read_x), 
        .just_read_y(just_read_y)
    );


endmodule
