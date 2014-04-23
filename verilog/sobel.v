//Convolve 3x3 square with sobel operator for x and y gradients.
//Code taken from Video Game Enhancer Project
//modified for use by Julie Wang, jsw267@cornell.edu

module sobel (
    input clk,
    input [17:0] threshold, //orignally {2'b11,15'd0}
    // input [7:0] thres,
    input [23:0] x00, x01, x02, x10, x11, x12, x20, x21, x22,
    output reg signed [12:0] Ix,
    output reg signed [12:0] Iy,
    output reg  p
  );
  
  wire [15:0] R00 = x00[23:16];
  wire [15:0] R01 = x01[23:16];
  wire [15:0] R02 = x02[23:16];
  wire [15:0] R10 = x10[23:16];
  wire [15:0] R11 = x11[23:16];
  wire [15:0] R12 = x12[23:16];
  wire [15:0] R20 = x20[23:16];
  wire [15:0] R21 = x21[23:16];
  wire [15:0] R22 = x22[23:16];
  
  wire [15:0] G00 = x00[15:8];
  wire [15:0] G01 = x01[15:8];
  wire [15:0] G02 = x02[15:8];
  wire [15:0] G10 = x10[15:8];
  wire [15:0] G11 = x11[15:8];
  wire [15:0] G12 = x12[15:8];
  wire [15:0] G20 = x20[15:8];
  wire [15:0] G21 = x21[15:8];
  wire [15:0] G22 = x22[15:8];
  
  wire [15:0] B00 = x00[7:0];
  wire [15:0] B01 = x01[7:0];
  wire [15:0] B02 = x02[7:0];
  wire [15:0] B10 = x10[7:0];
  wire [15:0] B11 = x11[7:0];
  wire [15:0] B12 = x12[7:0];
  wire [15:0] B20 = x20[7:0];
  wire [15:0] B21 = x21[7:0];
  wire [15:0] B22 = x22[7:0];
  
  wire [15:0] M00 = R00 + G00 + B00;
  wire [15:0] M01 = R01 + G01 + B01;
  wire [15:0] M02 = R02 + G02 + B02;
  wire [15:0] M10 = R10 + G10 + B10;
  wire [15:0] M11 = R11 + G11 + B11;
  wire [15:0] M12 = R12 + G12 + B12;
  wire [15:0] M20 = R20 + G20 + B20;
  wire [15:0] M21 = R21 + G21 + B21;
  wire [15:0] M22 = R22 + G22 + B22;
  
  // reg signed [16:0] Ix, Iy;
  // wire [33:0] Ix2, Iy2;
  
  // squarer sx ( Ix, Ix2 );
  // squarer sy ( Iy, Iy2 );
  
  always @ (posedge clk)
  begin
    Ix <= M00 - M02 + {M10,1'b0} - {M12,1'b0} + M20 - M22;
    Iy <= M00 + {M01,1'b0} + M02 - M20 - {M21,1'b0} - M22;
    // p  <= (Ix2+Iy2) > threshold ? 1'b1 : 1'b0;
  end
endmodule