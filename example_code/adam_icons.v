module icons (
    input reset, clk, button,
    input [9:0] x, y,
    input [23:0] pixel_0, pixel_1, pixel_2, pixel_3, pixel_4, pixel_5, pixel_6, pixel_7,
    output reg [2:0] effect,
    output reg effect_en,
    output reg [9:0] rom_addr_0, rom_addr_1, rom_addr_2, rom_addr_3, rom_addr_4, rom_addr_5, rom_addr_6, rom_addr_7,
    output reg [29:0] pixel
  );
  
  reg [28:0] timer;
  reg [4:0] rand;
  reg [2:0] state;
  parameter choosing=0, debounce=1, ready=2, counting=3, delay=4;
  reg [21:0] counter;
  
  always @ (posedge clk)
  begin
    if (x == 639 && y == 479) rand <= rand + 1;
    if (reset)
    begin
      effect     <= 0;
      effect_en  <= 0;
      timer      <= 0;
      state       <= choosing;
    end
    else
    begin
      case (state)
        choosing:
          begin
            if (!button)
            begin
              if (rand < 4)       effect <= 0;
              else if (rand < 8)  effect <= 1;
              else if (rand < 12) effect <= 2;
              else if (rand < 16) effect <= 3;
              else if (rand < 20) effect <= 4;
              else if (rand < 24) effect <= 5;
              else if (rand < 28) effect <= 6;
              else                effect <= 7;
            end
            else
            begin
              state   <= debounce;
              counter <= 1;
            end
          end
        debounce:
          begin
            if (counter == 0) state <= ready;
            else
            begin
              if (!button) counter <= counter + 1;
              else          counter <= 1;
            end
          end
        ready:
          begin
            if (button)
            begin
              effect_en  <= 1;
              timer      <= 0;
              state      <= counting;
            end
          end
        counting:
          begin
            if (timer == 10 * 27_000_000)
            begin
              effect     <= 0;
              effect_en  <= 0;
              state      <= delay;
              timer      <= 0;
            end
            else timer <= timer + 1;
          end
        delay:
          begin
            if (timer == 10 * 27_000_000) state <= choosing;
            else timer <= timer + 1;
          end
        default:
          begin
            effect     <= 0;
            effect_en  <= 0;
            timer      <= 0;
            state      <= choosing;
          end
      endcase
    end
  end

  always @ (posedge clk)
  begin
    if (y < 300)
    begin
      pixel <= 0;
      rom_addr_0 <= 0;
      rom_addr_1 <= 0;
      rom_addr_2 <= 0;
      rom_addr_3 <= 0;
      rom_addr_4 <= 0;
      rom_addr_5 <= 0;
      rom_addr_6 <= 0;
      rom_addr_7 <= 0;
    end
    else if (y < 332)
    begin
      if (x < 150)
      begin
        pixel <= 0;
        if (x == 149) rom_addr_1 <= rom_addr_1 + 1;
      end
      else if (state == counting || state == delay) pixel <= 0;
      else if (x < 182)
      begin
        pixel <= (effect != 1) ? 0 : { pixel_1[23:16],pixel_1[17:16],
                                          pixel_1[15:8],pixel_1[9:8],
                                          pixel_1[7:0],pixel_1[1:0]     };
        if (x != 181) rom_addr_1 <= rom_addr_1 + 1;
      end
      else if (x < 250)
      begin
        pixel <= 0;
        if (x == 249) rom_addr_2 <= rom_addr_2 + 1;
      end
      else if (x < 282)
      begin
        pixel <= (effect != 2) ? 0 : { pixel_2[23:16],pixel_2[17:16],
                                          pixel_2[15:8],pixel_2[9:8],
                                          pixel_2[7:0],pixel_2[1:0]     };
        if (x != 281) rom_addr_2 <= rom_addr_2 + 1;
      end
      else if (x < 350)
      begin
        pixel <= 0;
        if (x == 349) rom_addr_3 <= rom_addr_3 + 1;
      end
      else if (x < 382)
      begin
        pixel <= (effect != 3) ? 0 : { pixel_3[23:16],pixel_3[17:16],
                                          pixel_3[15:8],pixel_3[9:8],
                                          pixel_3[7:0],pixel_3[1:0]     };
        if (x != 381) rom_addr_3 <= rom_addr_3 + 1;
      end
      else if (x < 450)
      begin
        pixel <= 0;
        if (x == 449) rom_addr_4 <= rom_addr_4 + 1;
      end
      else if (x < 482)
      begin
        pixel <= (effect != 4) ? 0 : { pixel_4[23:16],pixel_4[17:16],
                                          pixel_4[15:8],pixel_4[9:8],
                                          pixel_4[7:0],pixel_4[1:0]     };
        if (x != 481) rom_addr_4 <= rom_addr_4 + 1;
      end
      else pixel <= 0;
    end
    else if (y < 400) pixel <= 0;
    else if (y < 432)
    begin
      if (x < 150)
      begin
        pixel <= 0;
        if (x == 149) rom_addr_0 <= rom_addr_0 + 1;
      end
      else if (state == counting || state == delay) pixel <= 0;
      else if (x < 182)
      begin
        pixel <= (effect != 0) ? 0 : { pixel_0[23:16],pixel_0[17:16],
                                          pixel_0[15:8],pixel_0[9:8],
                                          pixel_0[7:0],pixel_0[1:0]     };
        if (x != 181) rom_addr_0 <= rom_addr_0 + 1;
      end
      else if (x < 250)
      begin
        pixel <= 0;
        if (x == 249) rom_addr_7 <= rom_addr_7 + 1;
      end
      else if (x < 282)
      begin
        pixel <= (effect != 7) ? 0 : { pixel_7[23:16],pixel_7[17:16],
                                          pixel_7[15:8],pixel_7[9:8],
                                          pixel_7[7:0],pixel_7[1:0]     };
        if (x != 281) rom_addr_7 <= rom_addr_7 + 1;
      end
      else if (x < 350)
      begin
        pixel <= 0;
        if (x == 349) rom_addr_6 <= rom_addr_6 + 1;
      end
      else if (x < 382)
      begin
        pixel <= (effect != 6) ? 0 : { pixel_6[23:16],pixel_6[17:16],
                                          pixel_6[15:8],pixel_6[9:8],
                                          pixel_6[7:0],pixel_6[1:0]     };
        if (x != 381) rom_addr_6 <= rom_addr_6 + 1;
      end
      else if (x < 450)
      begin
        pixel <= 0;
        if (x == 449) rom_addr_5 <= rom_addr_5 + 1;
      end
      else if (x < 482)
      begin
        pixel <= (effect != 5) ? 0 : { pixel_5[23:16],pixel_5[17:16],
                                          pixel_5[15:8],pixel_5[9:8],
                                          pixel_5[7:0],pixel_5[1:0]     };
        if (x != 481) rom_addr_5 <= rom_addr_5 + 1;
      end
      else pixel <= 0;
    end
    else pixel <= 0;
  end

endmodule