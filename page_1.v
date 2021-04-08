module page_start(
    input rst,
    input clk_22,
    input clk_25MHz,
    input opt,
    input [8:0] h_cnt,
    input [8:0] v_cnt,
    output reg [11:0] pixel
);
    wire [16:0] addr, sel_addr;
    wire [11:0] pixel_start, pixel_sel;

    always @(*) begin
        if ((h_cnt>=160-19)&(h_cnt<=160+19)&(v_cnt>=120-6)&(v_cnt<120+6)) begin
            if (opt) begin
                if ((h_cnt>160-16)&(h_cnt<=160+16)&(v_cnt>=120-5)&(v_cnt<120+5)) begin
                    pixel <= pixel_start*12'hFFF;
                end else begin
                    pixel <= 12'h000;
                end 
            end else begin
                pixel <= pixel_start*12'hFFF;
            end
        end else if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120-3)&(v_cnt<120+3)) begin
            pixel <= pixel_sel*12'hFFF;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120-3)&(v_cnt<120+3)) begin
            pixel <= pixel_sel*12'hFFF;
        end else begin
            pixel <= 12'h000;
        end
    end
    mem_addr_gen_p1 addr_gen(
        .clk_22(clk_22),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .opt(opt),
        .addr(addr),
        .sel_addr(sel_addr)
    );
    page_start_pic page_start_pic(
      .clka(clk_25MHz),
      .wea(0),
      .addra(addr),
      .dina(0),
      .douta(pixel_start)
    );
    sel_1 sel_1(
      .clka(clk_25MHz),
      .wea(0),
      .addra(sel_addr),
      .dina(0),
      .douta(pixel_sel)
    );

    
endmodule

module mem_addr_gen_p1(
    input clk_22,
    input rst,
    input opt,
    input [8:0] h_cnt,
    input [8:0] v_cnt,
    output reg [16:0] addr,
    output reg [16:0] sel_addr
);
    always @(*) begin
        if ((h_cnt>=160-16)&(h_cnt<=160+16)&(v_cnt>=120-5)&(v_cnt<120+5)&opt) begin
            addr <= (h_cnt-(160-16) + 32*(v_cnt-(120-5)))%320;
        end else if ((h_cnt>=160-19)&(h_cnt<=160+19)&(v_cnt>=120-6)&(v_cnt<120+6)) begin
            addr <= 320 + (h_cnt-(160-19) + 38*(v_cnt-(120-6)))%456;
        end else begin
            addr <= 0;
        end
        if ((h_cnt>=160-28)&(h_cnt<=160-24)&(v_cnt>=120-3)&(v_cnt<120+3)) begin
            sel_addr <= (h_cnt-(160-28) + 4*(v_cnt-(120-3)))%24;
        end else if ((h_cnt>=160+24)&(h_cnt<=160+28)&(v_cnt>=120-3)&(v_cnt<120+3)) begin
            sel_addr <= (3-(h_cnt-(160+24)) + 4*(v_cnt-(120-3)))%24;
        end else begin
            sel_addr <= 17'b0;
        end
    end
endmodule