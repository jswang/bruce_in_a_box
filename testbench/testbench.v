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
    wire [9:0] VGA_X, VGA_Y;
    wire [9:0] vga_r10, vga_g10, vga_b10;
    wire [21:0] VGA_Addr_full; 
    wire VGA_Read, VGA_HS_, VGA_VS_, VGA_SYNC_N_, VGA_BLANK_N_, VGA_CLK;


    always @ (posedge clk_50) begin
        if (reset) begin
          index <= 32'd0;
          mRed  <= 10'd0;
          mGreen  <= 10'd0;
          mBlue  <= 10'd0;

        end
        /**
            0 0 0 0 0 ... [0, 639]
            0 0 1 1 1 ... [640, 1279]
            0 0 1 1 1 ... [1280, 1919]
            0 0 1 1 1 ... [1920, 2559]
            0 0 0 0 0 ... [2560, 3199]
            . . . . .
            . . . . .
            . . . . . 
        */
        else begin
            index <= index + 32'd1;
            if (index < 642) begin
                mRed <= 10'd0;
                mGreen <= 10'd0;
                mBlue <= 10'd0;
            end
            else if (index >= 642 && index <1280) begin
                mRed <= {8'd255, 2'd0}; 
                mGreen <= {8'd255, 2'd0};
                mBlue <= {8'd255, 2'd0};
            end
            else if (index >=1280 && index < 1282) begin
                mRed <= 10'd0;
                mGreen <= 10'd0;
                mBlue <= 10'd0;
            end
            else if (index >= 1282 && index <1920) begin
                mRed <= {8'd255, 2'd0}; 
                mGreen <= {8'd255, 2'd0};
                mBlue <= {8'd255, 2'd0};
            end

            else if (index >=1920 && index < 1922) begin
                mRed <= 10'd0;
                mGreen <= 10'd0;
                mBlue <= 10'd0;
            end
            else if (index >= 1922 && index <2560) begin
                mRed <= {8'd255, 2'd0}; 
                mGreen <= {8'd255, 2'd0};
                mBlue <= {8'd255, 2'd0};
            end
            else begin
                mRed <= 10'd0;
                mGreen <= 10'd0;
                mBlue <= 10'd0;
            end
        end
    end

    VGA_Ctrl         u9  (   //  Host Side
                            .iRed(mRed),
                            .iGreen(mGreen),
                            .iBlue(mBlue),
                            .oCurrent_X(VGA_X),
                            .oCurrent_Y(VGA_Y),
                            .oAddress(VGA_Addr_full), 
                            .oRequest(VGA_Read),
                            //  VGA Side
                            .oVGA_R(vga_r10 ),
                            .oVGA_G(vga_g10 ),
                            .oVGA_B(vga_b10 ),
                            .oVGA_HS(VGA_HS_),
                            .oVGA_VS(VGA_VS_),
                            .oVGA_SYNC(VGA_SYNC_N_),
                            .oVGA_BLANK(VGA_BLANK_N_),
                            .oVGA_CLOCK(VGA_CLK),
                            //  Control Signal
                            .iCLK(clk_VGA),
                            .iRST_N(!reset)   );

    wire signed [17:0] harris_feature;
    //Corner detection based on RGB values
    harris_corner_detect find_corners(
        .clk(clk_VGA), 
        .reset(reset), 
        .clk_en(VGA_BLANK_N_), 
        .VGA_R(vga_r10[9:2]),
        .VGA_G(vga_g10[9:2]),
        .VGA_B(vga_b10[9:2]),
        .threshold({2'b11, 16'd0}),  //not used except for edge dectection
        .harris_feature(harris_feature)
    );
endmodule
