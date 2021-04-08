module page_choose(
    input rst,
    input clk_22,
    input clk_25MHz,
    input up,
    input speed,
    input [1:0] hard,
    input [8:0] h_cnt,
    input [8:0] v_cnt,
    output reg [11:0] pixel
);
    wire [16:0] youkoso_addr, sel_addr, addr;
    wire [11:0] pixel_youkoso, pixel_sel, pixel_choose;

    always @(*) begin
        if ((h_cnt>=160-19)&(h_cnt<=160+19)&(v_cnt>=120+18)&(v_cnt<120+30)) begin
            case (hard)
                2'b00: begin
                    if ((h_cnt>160-13)&(h_cnt<=160+13)&(v_cnt>=120+18)&(v_cnt<120+30)) begin
                        pixel <= pixel_choose*12'hFFF;
                    end else begin
                        pixel <= 12'h000;
                    end 
                end
                2'b01: begin
                    if ((h_cnt>160-19)&(h_cnt<=160+19)&(v_cnt>=120+18)&(v_cnt<120+28)) begin
                        pixel <= pixel_choose*12'hFFF;
                    end else begin
                        pixel <= 12'h000;
                    end 
                end
                2'b10: begin
                    if ((h_cnt>160-13)&(h_cnt<=160+13)&(v_cnt>=120+18)&(v_cnt<120+28)) begin
                        pixel <= pixel_choose*12'hFFF;
                    end else begin
                        pixel <= 12'h000;
                    end 
                end
            endcase
        end else if ((h_cnt>=160-13)&(h_cnt<=160+13)&(v_cnt>=120+39)&(v_cnt<120+47)) begin
            if ((h_cnt>=160-6)&(h_cnt<=160+6)&(v_cnt>=120+39)&(v_cnt<120+47)) begin
                pixel <= pixel_choose*12'hFFF;
            end else begin
                pixel <= (speed) ? pixel_choose*12'hFFF: 12'h000;
            end
        end else if ((h_cnt>=160-60)&(h_cnt<=160+60)&(v_cnt>=120-25)&(v_cnt<120+13)) begin
            pixel <= pixel_youkoso;
        end else if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120+21)&(v_cnt<120+27)&~up) begin
            pixel <= pixel_sel*12'hFFF;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120+21)&(v_cnt<120+27)&~up) begin
            pixel <= pixel_sel*12'hFFF;
        end else if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120+40)&(v_cnt<120+46)&up) begin
            pixel <= pixel_sel*12'hFFF;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120+40)&(v_cnt<120+46)&up) begin
            pixel <= pixel_sel*12'hFFF;
        end else begin
            pixel <= 12'h000;
        end
    end
    mem_addr_gen_p2 addr_mem(
        .clk_22(clk_22),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .speed(speed),
        .hard(hard),
        .youkoso_addr(youkoso_addr),
        .addr(addr),
        .sel_addr(sel_addr)
    );
    youkoso youkoso(
      .clka(clk_25MHz),
      .wea(0),
      .addra(youkoso_addr),
      .dina(0),
      .douta(pixel_youkoso)
    );
    choose ch(
      .clka(clk_25MHz),
      .wea(0),
      .addra(addr),
      .dina(0),
      .douta(pixel_choose)
    );
    sel_1 sel_1(
      .clka(clk_25MHz),
      .wea(0),
      .addra(sel_addr),
      .dina(0),
      .douta(pixel_sel)
    );

    
endmodule

module mem_addr_gen_p2(
    input clk_22,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input speed,
    input [1:0] hard,
    output wire [16:0] youkoso_addr,
    output reg [16:0] addr,
    output reg [16:0] sel_addr 
);
    assign youkoso_addr = (h_cnt>=160-60)&(h_cnt<=160+60)&(v_cnt>=120-25)&(v_cnt<120+13)? 
                          (h_cnt-(160-60) + 120*(v_cnt-(120-25)))%4560:0;
    always @(*) begin
        if ((h_cnt>=160-13)&(h_cnt<=160+13)&(v_cnt>=120+18)&(v_cnt<120+28)&hard==0) begin
            addr <= ((h_cnt-(160-13)) + (v_cnt-(120+18))*26)%260;
        end else if ((h_cnt>=160-19)&(h_cnt<=160+19)&(v_cnt>=120+18)&(v_cnt<120+28)&hard==2'b01) begin
            addr <= 260 + ((h_cnt-(160-19)) + (v_cnt-(120+18))*38)%380;
        end else if ((h_cnt>=160-13)&(h_cnt<=160+13)&(v_cnt>=120+18)&(v_cnt<120+30)&hard==2'b10) begin
            addr <= 260 + 380 +((h_cnt-(160-13)) + (v_cnt-(120+18))*26)%312;
        end else if ((h_cnt>=160-6)&(h_cnt<=160+6)&(v_cnt>=120+39)&(v_cnt<120+47)&~speed) begin
            addr <= 260 + 380 + 312 +((h_cnt-(160-6)) + (v_cnt-(120+39))*12)%96;
        end else if ((h_cnt>=160-13)&(h_cnt<=160+13)&(v_cnt>=120+39)&(v_cnt<120+47)) begin
            addr <= 260 + 380 + 312 + 96 +((h_cnt-(160-13)) + (v_cnt-(120+39))*26)%208;
        end else begin
            addr <= 0;
        end
        if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120+21)&(v_cnt<120+27)) begin
            sel_addr <= (h_cnt-(160-28) + 4*(v_cnt-(120+21)))%24;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120+21)&(v_cnt<120+27)) begin
            sel_addr <= (3-(h_cnt-(160+24)) + 4*(v_cnt-(120+21)))%24;
        end else if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120+40)&(v_cnt<120+46)) begin
            sel_addr <= (h_cnt-(160-28) + 4*(v_cnt-(120+40)))%24;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120+40)&(v_cnt<120+46)) begin
            sel_addr <= (3-(h_cnt-(160+24)) + 4*(v_cnt-(120+40)))%24;
        end else begin
            sel_addr <= 17'b0;
        end
    end
endmodule