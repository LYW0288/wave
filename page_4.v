module page_play(
    input rst,
    input clk,
    input out_valid, 
    input on_off, 
    input wait_,
    input speed,
    input [2:0] down_0,
    input [2:0] down_1,
    input [2:0] down_2,
    input [2:0] down_3,
    input [8:0] time_,//div==480
    input [8:0] h_cnt,
    input [8:0] v_cnt,
    input [1:0] drop_pos,
    output reg [480:0] drop_1,
    output reg [480:0] drop_2,
    output reg [480:0] drop_3,
    output reg [480:0] drop_4,
    output reg [11:0] pixel
);
    reg ack;

    always @(posedge clk or posedge rst) begin
      if (rst | wait_) begin
          ack <= 1'b0;
          drop_1 <= 0;
          drop_2 <= 0;
          drop_3 <= 0;
          drop_4 <= 0;
      end
      else begin
          if ((time_+1)%5==0) begin
              ack <= 1'b1;
              drop_1 <= (ack) ? drop_1: {drop_1[479:0], 1'b0};
              drop_2 <= (ack) ? drop_2: {drop_2[479:0], 1'b0};
              drop_3 <= (ack) ? drop_3: {drop_3[479:0], 1'b0};
              drop_4 <= (ack) ? drop_4: {drop_4[479:0], 1'b0};
          end else begin
              ack <= 1'b0;
          end
          if (out_valid&on_off) begin
              case(drop_pos)
                  2'b0: drop_1 [0] = 1'b1;
                  2'b1: drop_2 [0] = 1'b1;
                  2'b10: drop_3 [0] = 1'b1;
                  2'b11: drop_4 [0] = 1'b1;
              endcase
          end
      end
    end
    always @(*) begin
        if ((h_cnt>=59)&(h_cnt<=147)) begin
            if (v_cnt==206) begin
                pixel <= 12'hFFF;
            end else if ((h_cnt==59)|(h_cnt==81)|(h_cnt==103)|(h_cnt==125)|(h_cnt==147)) begin
                pixel <= 12'hFFF;
            end else if ((h_cnt>59)&(h_cnt<81)) begin
                if (v_cnt>206) begin
                    case (down_0)
                        2'b00: begin//no
                            pixel <= 12'h000;
                        end
                        2'b01: begin//push
                            pixel <= 12'hFFF;
                        end
                        2'b10: begin//good
                            pixel <= 12'hF00;
                        end 
                        2'b11: begin//bad
                            pixel <= 12'h0A0;
                        end
                    endcase
                end else begin
                    pixel <= (drop_1[(v_cnt+178)%480]) ? 12'hF00: 12'h000;
                end
            end else if ((h_cnt>81)&(h_cnt<103)) begin
                if (v_cnt>206) begin
                    case (down_1)
                        2'b00: begin//no
                            pixel <= 12'h000;
                        end
                        2'b01: begin//push
                            pixel <= 12'hFFF;
                        end
                        2'b10: begin//good
                            pixel <= 12'hF00;
                        end 
                        2'b11: begin//bad
                            pixel <= 12'h0A0;
                        end
                    endcase
                end else begin
                    pixel <= (drop_2[(v_cnt+178)%480]) ? 12'hF00: 12'h000;
                end
            end else if ((h_cnt>103)&(h_cnt<125)) begin
                if (v_cnt>206) begin
                    case (down_2)
                        2'b00: begin//no
                            pixel <= 12'h000;
                        end
                        2'b01: begin//push
                            pixel <= 12'hFFF;
                        end
                        2'b10: begin//good
                            pixel <= 12'hF00;
                        end 
                        2'b11: begin//bad
                            pixel <= 12'h0A0;
                        end
                    endcase
                end else begin
                    pixel <= (drop_3[(v_cnt+178)%480]) ? 12'hF00: 12'h000;
                end
            end else if ((h_cnt>125)&(h_cnt<147)) begin
                if (v_cnt>206) begin
                    case (down_3)
                        2'b00: begin//no
                            pixel <= 12'h000;
                        end
                        2'b01: begin//push
                            pixel <= 12'hFFF;
                        end
                        2'b10: begin//good
                            pixel <= 12'hF00;
                        end 
                        2'b11: begin//bad
                            pixel <= 12'h0A0;
                        end
                    endcase
                end else begin
                    pixel <= (drop_4[(v_cnt+178)%480]) ? 12'hF00: 12'h000;
                end
            end else begin
                pixel <= 12'h000;
            end
        end else begin
            pixel <= 12'h000;
        end
    end

    
endmodule