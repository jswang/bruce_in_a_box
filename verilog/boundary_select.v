module boundary_select 
#(
    parameter p_image_width = 80,
    parameter p_image_heigth = 480, 


    )
(
    input clk,
    input reset, 
    input  unsigned [10:0] top_left_x,
    input  unsigned [10:0] top_left_y,
    input  unsigned [10:0] top_right_x,
    input  unsigned [10:0] top_right_y,
    input  unsigned [10:0] bot_left_x,
    input  unsigned [10:0] bot_left_y,
    input  unsigned [10:0] bot_right_x,
    input  unsigned [10:0] bot_right_y, 
    output unsigned [10:0] draw_start_x, 
    output unsigned [10:0] draw_start_y,
    output unsigned [10:0] draw_end_x, 
    output unsigned [10:0] draw_end_y,
    output unsigned [7 :0] scale
);

    


endmodule