`timescale 1ns/1ns
module testbench ();
    reg reset, clk_50, start, clk_VGA;
    reg [9:0] index;
    initial begin
        clk_50 = 0;
        clk_VGA = 0;
        reset = 0;
        start = 0;
    end

    initial begin
        #10
        reset = 1;
        #20
        reset = 0;
        start = 1;
        #20 
        start = 0;
    end
    always begin
        #10 clk_50 = !clk_50;
    end

    always begin
        #19 clk_VGA = !clk_VGA;
    end

    reg [7:0] r, g, b;
    wire corner;
    always @ (posedge clk_50) begin
        if (reset) begin
          r <= 8'd0;
          g <= 8'd0;
          b <= 8'd0;
          index <= 10'd0;
        end
        else begin
            index <= index + 10'd1;
            case (index) 
                10'd1: begin
                    r <= 8'd0; 
                    g <= 8'd255;
                    b <= 8'd0;
                end

                10'd2: begin
                    r <= 8'd125; 
                    g <= 8'd255;
                    b <= 8'd0;
                end
                10'd3: begin
                    r <= 8'd0; 
                    g <= 8'd255;
                    b <= 8'd125;
                end
                10'd4: begin
                    r <= 8'd0;
                    g <= 8'd200; 
                    b <= 8'd0;
                end
                default: begin
                    r <= 8'd0; 
                    g <= 8'd0;
                    b <= 8'd0;
                end
            endcase
            
        end
    end

    corner_detect DUT (
        .clk(clk_50),
        .r(r), 
        .g(g), 
        .b(b), 
        .rgb_target(24'hFF0000), 
        .threshold_in(10'd2), 
        .corner_detected(corner)
    );

endmodule
