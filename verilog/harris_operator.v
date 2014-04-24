module harris_operator 
#(
    parameter p_num_bits_in = 13
    )
(
    input [7:0] scale, 
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

    output signed [17:0] out 
    );

    //A = sum(Ix^2), B = sum(Ix*Iy), C = sum(Iy^2)

    wire signed [p_num_bits_in*2-1:0] 
                       x00_Ix_2, x01_Ix_2, x02_Ix_2, 
                       x10_Ix_2, x11_Ix_2, x12_Ix_2,
                       x20_Ix_2, x21_Ix_2, x22_Ix_2;

    wire signed [p_num_bits_in*2-1:0] 
                       x00_Iy_2, x01_Iy_2, x02_Iy_2, 
                       x10_Iy_2, x11_Iy_2, x12_Iy_2, 
                       x20_Iy_2, x21_Iy_2, x22_Iy_2;

    wire signed [p_num_bits_in*2-1:0] 
                       x00_Ix_Iy, x01_Ix_Iy, x02_Ix_Iy, 
                       x10_Ix_Iy, x11_Ix_Iy, x12_Ix_Iy, 
                       x20_Ix_Iy, x21_Ix_Iy, x22_Ix_Iy;

    // squarer x00_Ix_squarer (.dataa(x00_Ix), .result(x00_Ix_2));
    // squarer x01_Ix_squarer (.dataa(x01_Ix), .result(x01_Ix_2));
    // squarer x02_Ix_squarer (.dataa(x02_Ix), .result(x02_Ix_2));
    // squarer x10_Ix_squarer (.dataa(x10_Ix), .result(x10_Ix_2));
    // squarer x11_Ix_squarer (.dataa(x11_Ix), .result(x11_Ix_2));
    // squarer x12_Ix_squarer (.dataa(x12_Ix), .result(x12_Ix_2));
    // squarer x20_Ix_squarer (.dataa(x20_Ix), .result(x20_Ix_2));
    // squarer x21_Ix_squarer (.dataa(x21_Ix), .result(x21_Ix_2));
    // squarer x22_Ix_squarer (.dataa(x22_Ix), .result(x22_Ix_2));

    // squarer x00_Iy_squarer (.dataa(x00_Iy), .result(x00_Iy_2));
    // squarer x01_Iy_squarer (.dataa(x01_Iy), .result(x01_Iy_2));
    // squarer x02_Iy_squarer (.dataa(x02_Iy), .result(x02_Iy_2));
    // squarer x10_Iy_squarer (.dataa(x10_Iy), .result(x10_Iy_2));
    // squarer x11_Iy_squarer (.dataa(x11_Iy), .result(x11_Iy_2));
    // squarer x12_Iy_squarer (.dataa(x12_Iy), .result(x12_Iy_2));
    // squarer x20_Iy_squarer (.dataa(x20_Iy), .result(x20_Iy_2));
    // squarer x21_Iy_squarer (.dataa(x21_Iy), .result(x21_Iy_2));
    // squarer x22_Iy_squarer (.dataa(x22_Iy), .result(x22_Iy_2));

    // mult_s13 mult_x00_Ix_Iy     (.dataa(x00_Ix), .datab(x00_Iy), .result(x00_Ix_Iy));
    // mult_s13 mult_x01_Ix_Iy     (.dataa(x01_Ix), .datab(x01_Iy), .result(x01_Ix_Iy));
    // mult_s13 mult_x02_Ix_Iy     (.dataa(x02_Ix), .datab(x02_Iy), .result(x02_Ix_Iy));
    // mult_s13 mult_x10_Ix_Iy     (.dataa(x10_Ix), .datab(x10_Iy), .result(x10_Ix_Iy));
    // mult_s13 mult_x11_Ix_Iy     (.dataa(x11_Ix), .datab(x11_Iy), .result(x11_Ix_Iy));
    // mult_s13 mult_x12_Ix_Iy     (.dataa(x12_Ix), .datab(x12_Iy), .result(x12_Ix_Iy));
    // mult_s13 mult_x20_Ix_Iy     (.dataa(x20_Ix), .datab(x20_Iy), .result(x20_Ix_Iy));
    // mult_s13 mult_x21_Ix_Iy     (.dataa(x21_Ix), .datab(x21_Iy), .result(x21_Ix_Iy));
    // mult_s13 mult_x22_Ix_Iy     (.dataa(x22_Ix), .datab(x22_Iy), .result(x22_Ix_Iy));

    assign x00_Ix_2 = x00_Ix * x00_Ix;
    assign x01_Ix_2 = x01_Ix * x01_Ix;
    assign x02_Ix_2 = x02_Ix * x02_Ix;
    assign x10_Ix_2 = x10_Ix * x10_Ix;
    assign x11_Ix_2 = x11_Ix * x11_Ix;
    assign x12_Ix_2 = x12_Ix * x12_Ix;
    assign x20_Ix_2 = x20_Ix * x20_Ix;
    assign x21_Ix_2 = x21_Ix * x21_Ix;
    assign x22_Ix_2 = x22_Ix * x22_Ix;

    assign x00_Iy_2 = x00_Iy * x00_Iy;
    assign x01_Iy_2 = x01_Iy * x01_Iy;
    assign x02_Iy_2 = x02_Iy * x02_Iy;
    assign x10_Iy_2 = x10_Iy * x10_Iy;
    assign x11_Iy_2 = x11_Iy * x11_Iy;
    assign x12_Iy_2 = x12_Iy * x12_Iy;
    assign x20_Iy_2 = x20_Iy * x20_Iy;
    assign x21_Iy_2 = x21_Iy * x21_Iy;
    assign x22_Iy_2 = x22_Iy * x22_Iy;
    assign x00_Ix_Iy = x00_Ix * x00_Iy;
    assign x01_Ix_Iy = x01_Ix * x01_Iy;
    assign x02_Ix_Iy = x02_Ix * x02_Iy;
    assign x10_Ix_Iy = x10_Ix * x10_Iy;
    assign x11_Ix_Iy = x11_Ix * x11_Iy;
    assign x12_Ix_Iy = x12_Ix * x12_Iy;
    assign x20_Ix_Iy = x20_Ix * x20_Iy;
    assign x21_Ix_Iy = x21_Ix * x21_Iy;
    assign x22_Ix_Iy = x22_Ix * x22_Iy;

    //max value of Ix and Iy are 3060, so max value of A,B,orC = 84272400 (27 bits + 1sign = 28 bits)
    wire signed [27:0] A, B, C;
    wire signed [55:0] det_temp1, det_temp2, determinant;
    wire signed [55:0] trace, harris_operator;
    assign A = x00_Ix_2 + x01_Ix_2 + x02_Ix_2
             + x10_Ix_2 + x11_Ix_2 + x12_Ix_2
             + x20_Ix_2 + x21_Ix_2 + x22_Ix_2; 

    assign B = x00_Ix_Iy + x01_Ix_Iy + x02_Ix_Iy
             + x10_Ix_Iy + x11_Ix_Iy + x12_Ix_Iy
             + x20_Ix_Iy + x21_Ix_Iy + x22_Ix_Iy; 

    assign C = x00_Iy_2 + x01_Iy_2 + x02_Iy_2
             + x10_Iy_2 + x11_Iy_2 + x12_Iy_2
             + x20_Iy_2 + x21_Iy_2 + x22_Iy_2; 

    // mult_s28 mult_A_C   (.dataa(A), .datab(C), .result(det_temp1));
    // mult_s28 mult_B_B   (.dataa(B), .datab(B), .result(det_temp2));

    assign determinant = A*C - B*B; 
    assign trace = (A + C) >>> scale; //todo find the correct scaler
    // divider det_div_trace (
    //     .numer(determinant), 
    //     .denom(trace), 
    //     .quotient(harris_operator), 
    //     .remain()
    // );

    assign out = (trace == 0) ? 0 : determinant/trace;
    

endmodule