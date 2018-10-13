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
    
    reg [9:0] mRed, mGreen, mBlue;
    reg [10:0] VGA_X, VGA_Y;
    wire [9:0] vga_r10, vga_g10, vga_b10;
    wire [21:0] VGA_Addr_full; 
    wire VGA_Read, VGA_HS_, VGA_VS_, VGA_SYNC_N_, VGA_BLANK_N_, VGA_CLK;


    always @ (posedge clk_50) begin
        if (reset) begin
          index <= 32'd0;
          mRed  <= 10'd0;
          mGreen  <= 10'd0;
          mBlue  <= 10'd0;
          VGA_X  <= 11'd0;
          VGA_Y  <= 11'd0;
        end
       
        else begin
            index <= index + 32'd1;
            if (VGA_Y < 480) begin
                if (VGA_X < 640)
                    VGA_X <= VGA_X + 11'd1;
                else begin
                    VGA_X <= 11'd0;
                    VGA_Y <= VGA_Y + 11'd1;
                end
            end
            else begin
                VGA_X <= 11'd0;
                VGA_Y <= 11'd0;
            end
        end
    end
    wire [7:0] image_R, image_G, image_B;
    boundary_select #(.p_image_width(80), .p_image_height(480))
    DUT
    (
        .clk(clk_50), 
        .reset(reset), 
        .VGA_X(VGA_X),
        .VGA_Y(VGA_Y), 
        .draw_image(draw_image), 
        .image_R(image_R), 
        .image_G(image_G), 
        .image_B(image_B)
    );

endmodule
