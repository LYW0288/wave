module page_option(
    input rst,
    input clk_22,
    input clk_25MHz,
    input which,
    input [4:0] find_num_1,
    input [4:0] find_num_2,
    input [4:0] find_num_3,
    input [4:0] find_num_4,
    input [3:0] wasd,
    input [3:0] volume,
    input [8:0] h_cnt,
    input [8:0] v_cnt,
    output reg [11:0] pixel
);
    wire [16:0] sel_addr, wasd_addr, addr;
    wire [11:0] pixel_sel, pixel_wasd, pixel_opt;
    wire [0:6] out_1, out_2;

    Decoder D1((volume%10), out_1);
    Decoder D2((volume/10), out_2);
    always @(*) begin
        if ((h_cnt>160-70)&(h_cnt<=160-60)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            if (wasd==4'b00) begin
                pixel <= (pixel_opt) ? 12'hF00: 12'hFFF;
            end else begin
                pixel <= (pixel_opt) ? 12'h0: 12'hFFF;
            end
        end else if ((h_cnt>160-27)&(h_cnt<=160-17)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            if (wasd==4'b01) begin
                pixel <= (pixel_opt) ? 12'hF00: 12'hFFF;
            end else begin
                pixel <= (pixel_opt) ? 12'h0: 12'hFFF;
            end
        end else if ((h_cnt>160+16)&(h_cnt<=160+26)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            if (wasd==4'b10) begin
                pixel <= (pixel_opt) ? 12'hF00: 12'hFFF;
            end else begin
                pixel <= (pixel_opt) ? 12'h0: 12'hFFF;
            end
        end else if ((h_cnt>160+59)&(h_cnt<=160+69)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            if (wasd==4'b11) begin
                pixel <= (pixel_opt) ? 12'hF00: 12'hFFF;
            end else begin
                pixel <= (pixel_opt) ? 12'h0: 12'hFFF;
            end
        end else if ((h_cnt>160-84)&(h_cnt<=160-46)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            if ((h_cnt>160-82)&(h_cnt<=160-48)&(v_cnt>=120-32)&(v_cnt<120+2)&wasd==4'b00) begin
                pixel <= (pixel_wasd==12'h000) ? 12'hF00: pixel_wasd;
            end else begin
                pixel <= pixel_wasd;
            end
        end else if ((h_cnt>160-41)&(h_cnt<=160-3)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            if ((h_cnt>160-39)&(h_cnt<=160-5)&(v_cnt>=120-32)&(v_cnt<120+2)&wasd==4'b01) begin
                pixel <= (pixel_wasd==12'h000) ? 12'hF00: pixel_wasd;
            end else begin
                pixel <= pixel_wasd;
            end
        end else if ((h_cnt>160+2)&(h_cnt<=160+40)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            if ((h_cnt>160+4)&(h_cnt<=160+38)&(v_cnt>=120-32)&(v_cnt<120+2)&wasd==4'b10) begin
                pixel <= (pixel_wasd==12'h000) ? 12'hF00: pixel_wasd;
            end else begin
                pixel <= pixel_wasd;
            end
        end else if ((h_cnt>160+45)&(h_cnt<=160+83)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            if ((h_cnt>160+47)&(h_cnt<=160+81)&(v_cnt>=120-32)&(v_cnt<120+2)&wasd==4'b11) begin
                pixel <= (pixel_wasd==12'h000) ? 12'hF00: pixel_wasd;
            end else begin
                pixel <= pixel_wasd;
            end
        end else if ((h_cnt>160-13)&(h_cnt<=160-7)&(v_cnt>=120+19)&(v_cnt<120+28)) begin
            if (v_cnt==120+19) begin
                if ((h_cnt>160-11)&(h_cnt<=160-9)) begin
                    pixel <= (out_1[0]) ? 12'h000: 12'hFFF;
                end else if (h_cnt<=160-11) begin
                    pixel <= (out_1[0]&out_1[5]) ? 12'h000: 12'hFFF;
                end else if (h_cnt>160-9) begin
                    pixel <= (out_1[0]&out_1[1]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 0;
                end
            end else if (v_cnt==120+27) begin
                if ((h_cnt>160-11)&(h_cnt<=160-9)) begin
                    pixel <= (out_1[3]) ? 12'h000: 12'hFFF;
                end else if (h_cnt<=160-11) begin
                    pixel <= (out_1[3]&out_1[4]) ? 12'h000: 12'hFFF;
                end else if (h_cnt>160-9) begin
                    pixel <= (out_1[3]&out_1[2]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 0;
                end
            end else if (v_cnt==120+23) begin
                pixel <= (out_1[6]) ? 12'h000: 12'hFFF;
            end else if ((h_cnt>160-13)&(h_cnt<=160-11)) begin
                if ((v_cnt>=120+19)&(v_cnt<120+23)) begin
                    pixel <= (out_1[5]) ? 12'h000: 12'hFFF;
                end else if ((v_cnt>=120+24)&(v_cnt<120+28)) begin
                    pixel <= (out_1[4]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 12'h000;
                end
            end else if ((h_cnt>160-9)&(h_cnt<=160-7)) begin
                if ((v_cnt>=120+19)&(v_cnt<120+23)) begin
                    pixel <= (out_1[1]) ? 12'h000: 12'hFFF;
                end else if ((v_cnt>=120+24)&(v_cnt<120+28)) begin
                    pixel <= (out_1[2]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 12'h000;
                end
            end else begin
                pixel <= 12'h000;
            end
        end else if ((h_cnt>160-22)&(h_cnt<=160-16)&(v_cnt>=120+19)&(v_cnt<120+28)) begin
            if (v_cnt==120+19) begin
                if ((h_cnt>160-24)&(h_cnt<=160-18)) begin
                    pixel <= (out_2[0]) ? 12'h000: 12'hFFF;
                end else if (h_cnt<=160-24) begin
                    pixel <= (out_2[0]&out_2[5]) ? 12'h000: 12'hFFF;
                end else if (h_cnt>160-18) begin
                    pixel <= (out_2[0]&out_2[1]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 0;
                end
            end else if (v_cnt==120+27) begin
                if ((h_cnt>160-24)&(h_cnt<=160-18)) begin
                    pixel <= (out_2[3]) ? 12'h000: 12'hFFF;
                end else if (h_cnt<=160-24) begin
                    pixel <= (out_2[3]&out_2[4]) ? 12'h000: 12'hFFF;
                end else if (h_cnt>160-18) begin
                    pixel <= (out_2[3]&out_2[2]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 0;
                end
            end else if (v_cnt==120+23) begin
                pixel <= (out_2[6]) ? 12'h000: 12'hFFF;
            end else if ((h_cnt>160-22)&(h_cnt<=160-20)) begin
                if ((v_cnt>=120+19)&(v_cnt<120+23)) begin
                    pixel <= (out_2[5]) ? 12'h000: 12'hFFF;
                end else if ((v_cnt>=120+24)&(v_cnt<120+28)) begin
                    pixel <= (out_2[4]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 12'h000;
                end
            end else if ((h_cnt>160-18)&(h_cnt<=160-16)) begin
                if ((v_cnt>=120+19)&(v_cnt<120+23)) begin
                    pixel <= (out_2[1]) ? 12'h000: 12'hFFF;
                end else if ((v_cnt>=120+24)&(v_cnt<120+28)) begin
                    pixel <= (out_2[2]) ? 12'h000: 12'hFFF;
                end else begin
                    pixel <= 12'h000;
                end
            end else begin
                pixel <= 12'h000;
            end
        end else if ((h_cnt>160-82)&(h_cnt<=160-44)&(v_cnt>=120+18)&(v_cnt<120+28)) begin
            pixel <= pixel_opt*12'hFFF;
        end else if ((h_cnt>160-101)&(h_cnt<=160-97)&(v_cnt>=120-18)&(v_cnt<120-12)&which) begin
            pixel <= pixel_sel*12'hFFF;
        end else if ((h_cnt>160-101)&(h_cnt<=160-97)&(v_cnt>=120+20)&(v_cnt<120+26)&~which) begin
            pixel <= pixel_sel*12'hFFF;
        end else begin
            pixel <= 12'h000;
        end
    end
    mem_addr_gen_p3 addr(
        .clk_22(clk_22),
        .rst(rst),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .find_num_1(find_num_1),
        .find_num_2(find_num_2),
        .find_num_3(find_num_3),
        .find_num_4(find_num_4),
        .wasd_addr(wasd_addr),
        .addr(addr),
        .sel_addr(sel_addr)
    );
    page_opt page_opt(
      .clka(clk_25MHz),
      .wea(0),
      .addra(addr),
      .dina(0),
      .douta(pixel_opt)
    );
    wasd wasd_pic(
      .clka(clk_25MHz),
      .wea(0),
      .addra(wasd_addr),
      .dina(0),
      .douta(pixel_wasd)
    );
    sel_1 sel_1(
      .clka(clk_25MHz),
      .wea(0),
      .addra(sel_addr),
      .dina(0),
      .douta(pixel_sel)
    );

    
endmodule

module mem_addr_gen_p3(
    input clk_22,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input [4:0] find_num_1,
    input [4:0] find_num_2,
    input [4:0] find_num_3,
    input [4:0] find_num_4,
    output reg [16:0] wasd_addr,
    output reg [16:0] addr,
    output reg [16:0] sel_addr
);
    always @(*) begin
        if ((h_cnt>=160-82)&(h_cnt<=160-44)&(v_cnt>=120+18)&(v_cnt<120+28)) begin
            addr <= (h_cnt-(160-82) + 38*(v_cnt-(120+18)))%380;
        end else if ((h_cnt>=160-70)&(h_cnt<=160-60)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            addr <= (((h_cnt-(160-70))>>1) + (130)*((v_cnt-(120-27))>>1)) + find_num_1*5 + 380;
        end else if ((h_cnt>=160-27)&(h_cnt<=160-17)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            addr <= (((h_cnt-(160-27))>>1) + (130)*((v_cnt-(120-27))>>1)) + find_num_2*5 + 380;
        end else if ((h_cnt>=160+16)&(h_cnt<=160+26)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            addr <= (((h_cnt-(160+16))>>1) + (130)*((v_cnt-(120-27))>>1)) + find_num_3*5 + 380;
        end else if ((h_cnt>=160+59)&(h_cnt<=160+69)&(v_cnt>=120-27)&(v_cnt<120-3)) begin
            addr <= (((h_cnt-(160+59))>>1) + (130)*((v_cnt-(120-27))>>1)) + find_num_4*5 + 380;
        end else begin
            addr <= 17'b0;
        end
        if ((h_cnt>160-84)&(h_cnt<=160-46)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            wasd_addr <= (h_cnt-(160-84)) + (v_cnt-(120-34))*38;
        end else if ((h_cnt>160-41)&(h_cnt<=160-3)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            wasd_addr <= (h_cnt-(160-41)) + (v_cnt-(120-34))*38;
        end else if ((h_cnt>160+2)&(h_cnt<=160+40)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            wasd_addr <= (h_cnt-(160+2)) + (v_cnt-(120-34))*38;
        end else if ((h_cnt>160+45)&(h_cnt<=160+83)&(v_cnt>=120-34)&(v_cnt<120+4)) begin
            wasd_addr <= (h_cnt-(160+45)) + (v_cnt-(120-34))*38;
        end else begin
            wasd_addr <= 17'b0;
        end
        if ((h_cnt>160-101)&(h_cnt<=160-97)&(v_cnt>=120-18)&(v_cnt<120-12)) begin
            sel_addr <= 3 - (h_cnt-(160-101)) + 4*(v_cnt-(120-18));
        end else if ((h_cnt>160-101)&(h_cnt<=160-97)&(v_cnt>=120+20)&(v_cnt<120+26)) begin
            sel_addr <= 3 - (h_cnt-(160-101)) + 4*(v_cnt-(120+20));
        end else begin
            sel_addr <= 17'b0;
        end
    end
endmodule

module Decoder(D, out);
    input [4:0] D; // {dot, 4-bit binary number}
    output reg [0:6] out; // {dot, A,B,C,D,E,F,G}
    
    always@(*) begin
        case(D[3:0])
            4'd0: out = 7'b0000001;
            4'd1: out = 7'b1001111;
            4'd2: out = 7'b0010010;
            4'd3: out = 7'b0000110;
            4'd4: out = 7'b1001100;
            4'd5: out = 7'b0100100;
            4'd6: out = 7'b0100000;
            4'd7: out = 7'b0001111;
            4'd8: out = 7'b0000000;
            4'd9: out = 7'b0000100;
            4'd10: out = 7'b0001000;
            4'd11: out = 7'b1100000;
            4'd12: out = 7'b0110001;
            4'd13: out = 7'b1000010;
            4'd14: out = 7'b0110000;
            4'd15: out = 7'b0111000;
            default: out = 7'b111_1111;
        endcase
    end
endmodule 