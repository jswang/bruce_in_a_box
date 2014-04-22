module harris_operator 
#(
    parameter p_num_bits_in = 4
    )
(
    input signed [p_num_bits_in-1:0] x00_Ix,
    input signed [p_num_bits_in-1:0] x01_Ix,
    input signed [p_num_bits_in-1:0] x02_Ix,
    input signed [p_num_bits_in-1:0] x10_Ix,
    input signed [p_num_bits_in-1:0] x11_Ix,
    input signed [p_num_bits_in-1:0] x12_Ix,
    input signed [p_num_bits_in-1:0] x20_Ix,
    input signed [p_num_bits_in-1:0] x21_Ix,
    input signed [p_num_bits_in-1:0] x22_Ix,
    input signed [p_num_bits_in-1:0] x00_Iy,
    input signed [p_num_bits_in-1:0] x01_Iy,
    input signed [p_num_bits_in-1:0] x02_Iy,
    input signed [p_num_bits_in-1:0] x10_Iy,
    input signed [p_num_bits_in-1:0] x11_Iy,
    input signed [p_num_bits_in-1:0] x12_Iy,
    input signed [p_num_bits_in-1:0] x20_Iy,
    input signed [p_num_bits_in-1:0] x21_Iy,
    input signed [p_num_bits_in-1:0] x22_Iy,

    output signed [15:0] out 
    );

    //A = sum(Ix^2), B = sum(Ix*Iy), C = sum(Iy^2)
    wire signed [15:0] A, B, C, determinant, trace;
    assign A = x00_Ix*x00_Ix + x01_Ix*x01_Ix + x02_Ix*x02_Ix
             + x10_Ix*x10_Ix + x11_Ix*x11_Ix + x12_Ix*x12_Ix
             + x20_Ix*x20_Ix + x21_Ix*x21_Ix + x22_Ix*x22_Ix; 

    assign B = x00_Ix*x00_Iy + x01_Ix*x01_Iy + x02_Ix*x02_Iy
             + x10_Ix*x10_Iy + x11_Ix*x11_Iy + x12_Ix*x12_Iy
             + x20_Ix*x20_Iy + x21_Ix*x21_Iy + x22_Ix*x22_Iy; 

    assign C = x00_Iy*x00_Iy + x01_Iy*x01_Iy + x02_Iy*x02_Iy
             + x10_Iy*x10_Iy + x11_Iy*x11_Iy + x12_Iy*x12_Iy
             + x20_Iy*x20_Iy + x21_Iy*x21_Iy + x22_Iy*x22_Iy; 

    assign determinant = A*C - B*B; 
    assign trace = A + C; 

    assign out = determinant / trace;
    

endmodule