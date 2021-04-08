module top(
    input clk,
    input rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output [3:0] vgaRed,
    output [3:0] vgaGreen,
    output [3:0] vgaBlue,
    output hsync,
    output vsync,
    output pmod_1,
    output pmod_2,
    output pmod_4
);
    parameter [8:0] A_TO_Z [0:25] = {
        9'b0_0001_1100,  // A  1C
        9'b0_0011_0010,  // B  32
        9'b0_0010_0001,  // C  21
        9'b0_0010_0011,  // D  23
        9'b0_0010_0100,  // E  24
        9'b0_0010_1011,  // F  2B
        9'b0_0011_0100,  // G  34
        9'b0_0011_0011,  // H  33
        9'b0_0100_0011,  // I  43
        9'b0_0011_1011,  // J  3B
        9'b0_0100_0010,  // K  42
        9'b0_0100_1011,  // L  4B
        9'b0_0011_1010,  // M  3A
        9'b0_0011_0001,  // N  31
        9'b0_0100_0100,  // O  44
        9'b0_0100_1101,  // P  4D
        9'b0_0001_0101,  // Q  15
        9'b0_0010_1101,  // R  2D
        9'b0_0001_1011,  // S  1B
        9'b0_0010_1100,  // T  2C
        9'b0_0011_1100,  // U  3C
        9'b0_0010_1010,  // V  2A
        9'b0_0001_1101,  // W  1D
        9'b0_0010_0010,  // X  22
        9'b0_0011_0101,  // Y  35
        9'b0_0001_1010   // Z  1A
    };
    parameter [8:0] UP_DOWN [0:3] = {
        9'b0_0111_0011, // 5 => 73
        9'b0_0111_0010, // 2 => 72
        9'b0_0110_1001, // 1 => 69
        9'b0_0111_1010  // 3 => 7A
    };
    parameter [8:0] ENTER = 9'b0_0101_1010; //ENTER 5A 
    parameter [8:0] ESC = 9'b0_0111_0110; //ESC 76
    parameter [18:0] song_time [0:1] = {
        0,
        {8'd84, 2'b10, 9'b0}
    };


    reg opt, which, up, speed, on, wait_, song;
    reg [1:0] hard, wasd;
    reg [3:0] stage, volume;
    reg [8:0] key [0:3];
    reg [2:0] down [0:3];
    reg [4:0] find_num [0:3];
    wire [8:0] last_change;
    wire [8:0] h_cnt, v_cnt; //320x240
    wire [11:0] pixel [0:3];
    wire [511:0] key_down;
    wire [480:0] drop_node [0:3];
    wire clk_25MHz, clk_22, valid, been_ready;

    reg [7:0] sav_note;
    reg [1:0] drop_pos;

    reg [8:0] div;
    reg [7:0] measure;
    reg [1:0] beat;
    reg [31:0] bpm;
    reg [31:0] counter;
    wire [31:0] count_div = 12500000 / bpm;

    wire out_valid_0, out_valid_1, out_valid_2;
    wire on_off_0, on_off_1, on_off_2;
    wire [7:0] note_0, note_1, note_2;
    wire [11:0] num_track_1, num_track_2;
    wire [11:0] address_0, address_1, address_2;
    wire [27:0] out_0, out_1, out_2;
    assign pmod_2 = 1'd1; //no gain(6dB)
    assign pmod_4 = 1'd1; //turn-on
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel[stage]:12'hFFF;
    gen_track_triangle track_1(
        .clk(clk),
        .reset(rst),
        .on(on),
        .num(num_track_1),
        .out_valid(out_valid_1), 
        .on_off(on_off_1),
        .note(note_1)
    );
    gen_track_triangle track_2(
        .clk(clk),
        .reset(rst),
        .on(on),
        .num(num_track_2),
        .out_valid(out_valid_2), 
        .on_off(on_off_2),
        .note(note_2)
    );
    PWM_gen_x all_track(
        .clk(clk),
        .reset(rst),
        .num_1(num_track_1),
        .num_2(num_track_2),
        .PWM(pmod_1)
    );


    track_monitor tone( 
        .clk(clk),
        .rst(rst),
        .on(on),
        .wait_(wait_),
        .hard(hard),
        .time_({measure, beat, div}),
        .out(out_0),
        .out_valid(out_valid_0), 
        .on_off(on_off_0), 
        .note(note_0),
        .address(address_0)
    );
    track_monitor track_monitor_1( 
        .clk(clk),
        .rst(rst),
        .on(on),
        .wait_(wait_),
        .hard(0),
        .time_({measure-1, beat, div}),
        .out(out_1),
        .out_valid(out_valid_1), 
        .on_off(on_off_1), 
        .note(note_1),
        .address(address_1)
    );
    track_monitor track_monitor_2( 
        .clk(clk),
        .rst(rst),
        .on(on),
        .wait_(wait_),
        .hard(0),
        .time_({measure-1, beat, div}),
        .out(out_2),
        .out_valid(out_valid_2), 
        .on_off(on_off_2), 
        .note(note_2),
        .address(address_2)
    );
    mem_monitor mem_moniter(
        .clk(clk),
        .address_0(address_0),
        .address_1(address_1),
        .address_2(address_2),
        .out_0(out_0),
        .out_1(out_1),
        .out_2(out_2)
    );



    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );
    clock_divisor clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz),
        .clk22(clk_22)
    );
    page_option page_option(
        .rst(rst),
        .clk_22(clk_22),
        .clk_25MHz(clk_25MHz),
        .which(which),
        .wasd(wasd),
        .volume(volume),
        .find_num_1(find_num[0]),
        .find_num_2(find_num[1]),
        .find_num_3(find_num[2]),
        .find_num_4(find_num[3]),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel(pixel[1])
    );
    page_start page_start(
        .rst(rst),
        .clk_22(clk_22),
        .clk_25MHz(clk_25MHz),
        .opt(opt),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel(pixel[0])
    );
    page_choose page_choose(
        .rst(rst),
        .clk_22(clk_22),
        .clk_25MHz(clk_25MHz),
        .up(up),
        .speed(speed),
        .hard(hard),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel(pixel[2])
    );
    page_play page_play(
        .rst(rst),
        .clk(clk),
        .out_valid(out_valid_0), 
        .on_off(on_off_0),
        .wait_(wait_), 
        .time_(div),//div==480
        .down_0(down[0]),
        .down_1(down[1]),
        .down_2(down[2]),
        .down_3(down[3]),
        .drop_1(drop_node[0]),
        .drop_2(drop_node[1]),
        .drop_3(drop_node[2]),
        .drop_4(drop_node[3]),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel(pixel[3]),
        .drop_pos(drop_pos)
    );
    vga_controller   vga_inst(
      .pclk(clk_25MHz),
      .reset(rst),
      .hsync(hsync),
      .vsync(vsync),
      .valid(valid),
      .h_cnt_div(h_cnt),
      .v_cnt_div(v_cnt)
    );
    always @ (posedge clk, posedge rst) begin//page
        if (rst) begin
            on <= 0;
            wait_ <= 1'b1;
            song <= 1'b1;
            stage <= 0;
            up <= 0;
            opt <= 1'b1;
            wasd <= 4'b0;
            hard <= 1'b1;
            which <= 1'b1;
            speed <= 1'b0;
            volume <= 4'd10;
            down[0] <= 0;
            down[1] <= 0;
            down[2] <= 0;
            down[3] <= 0;
            key[0] <= A_TO_Z[25]; // Z
            key[1] <= A_TO_Z[23]; // X
            key[2] <= A_TO_Z[02]; // C
            key[3] <= A_TO_Z[21]; // V
            find_num[0] <= 25; // Z
            find_num[1] <= 23; // X
            find_num[2] <= 2; // C
            find_num[3] <= 21; // V
        end else begin
            case (stage)
                4'b0000: begin //title
                    up <= 0;
                    wasd <= 4'b0;
                    wait_ <= 1'b1;
                    which <= 1'b1;
                    if (been_ready && key_down[last_change] == 1'b1) begin
                        case (last_change)
                            UP_DOWN[2] : opt <= ~opt;
                            UP_DOWN[3] : opt <= ~opt;
                            ENTER : begin
                                if (opt) begin
                                    stage <= 4'b0010;
                                end else begin
                                    stage <= 4'b0001;
                                end
                            end
                        endcase
                    end
                end
                4'b0001: begin //option
                    up <= 0;
                    opt <= 1'b1;
                    wait_ <= 1'b1;
                    if (been_ready && key_down[last_change] == 1'b1) begin
                        case (last_change)
                            UP_DOWN[00] : which <= ~which;
                            UP_DOWN[01] : which <= ~which;
                            UP_DOWN[02] : begin
                                if (which) begin
                                    wasd <= wasd-1;
                                end else begin
                                    volume <= (volume==4'b0) ? 4'b0: volume-1;
                                end
                            end
                            UP_DOWN[03] : begin
                                if (which) begin
                                    wasd <= wasd+1;
                                end else begin
                                    volume <= (volume==4'd10) ? 4'd10: volume+1;
                                end
                            end 
                            ESC: begin
                                stage <= 4'b0000;
                            end
                            A_TO_Z [0]: begin
                                if (which&A_TO_Z [0]!=key[0]&A_TO_Z [0]!=key[1]
                                    &A_TO_Z [0]!=key[2]&A_TO_Z [0]!=key[2]) begin
                                    find_num[wasd] <= 0; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [1]: begin
                                if (which&A_TO_Z [1]!=key[0]&A_TO_Z [1]!=key[1]
                                    &A_TO_Z [1]!=key[2]&A_TO_Z [1]!=key[3]) begin
                                    find_num[wasd] <= 1; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [2]: begin
                                if (which&A_TO_Z [2]!=key[0]&A_TO_Z [2]!=key[1]
                                    &A_TO_Z [2]!=key[2]&A_TO_Z [2]!=key[3]) begin
                                    find_num[wasd] <= 2; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [3]: begin
                                if (which&A_TO_Z [3]!=key[0]&A_TO_Z [3]!=key[1]
                                    &A_TO_Z [3]!=key[2]&A_TO_Z [3]!=key[3]) begin
                                    find_num[wasd] <= 3; 
                                    key[wasd] <= last_change;
                                end
                            end 
                            A_TO_Z [4]: begin
                                if (which&A_TO_Z [4]!=key[0]&A_TO_Z [4]!=key[1]
                                    &A_TO_Z [4]!=key[2]&A_TO_Z [4]!=key[3]) begin
                                    find_num[wasd] <= 4; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [5]: begin
                                if (which&A_TO_Z [5]!=key[0]&A_TO_Z [5]!=key[1]
                                    &A_TO_Z [5]!=key[2]&A_TO_Z [5]!=key[3]) begin
                                    find_num[wasd] <= 5; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [6]: begin
                                if (which&A_TO_Z [6]!=key[0]&A_TO_Z [6]!=key[1]
                                    &A_TO_Z [6]!=key[2]&A_TO_Z [6]!=key[3]) begin
                                    find_num[wasd] <= 6; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [7]: begin
                                if (which&A_TO_Z [7]!=key[0]&A_TO_Z [7]!=key[1]
                                    &A_TO_Z [7]!=key[2]&A_TO_Z [7]!=key[3]) begin
                                    find_num[wasd] <= 7; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [8]: begin
                                if (which&A_TO_Z [8]!=key[0]&A_TO_Z [8]!=key[1]
                                    &A_TO_Z [8]!=key[2]&A_TO_Z [8]!=key[3]) begin
                                    find_num[wasd] <= 8; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [9]: begin
                                if (which&A_TO_Z [9]!=key[0]&A_TO_Z [9]!=key[1]
                                    &A_TO_Z [9]!=key[2]&A_TO_Z [9]!=key[3]) begin
                                    find_num[wasd] <= 9; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [10]: begin
                                if (which&A_TO_Z [10]!=key[0]&A_TO_Z [10]!=key[1]
                                    &A_TO_Z [10]!=key[2]&A_TO_Z [10]!=key[3]) begin
                                    find_num[wasd] <= 10; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [11]: begin
                                if (which&A_TO_Z [11]!=key[0]&A_TO_Z [11]!=key[1]
                                    &A_TO_Z [11]!=key[2]&A_TO_Z [11]!=key[3]) begin
                                    find_num[wasd] <= 11; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [12]: begin
                                if (which&A_TO_Z [12]!=key[0]&A_TO_Z [12]!=key[1]
                                    &A_TO_Z [12]!=key[2]&A_TO_Z [12]!=key[3]) begin
                                    find_num[wasd] <= 12; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [13]: begin
                                if (which&A_TO_Z [13]!=key[0]&A_TO_Z [13]!=key[1]
                                    &A_TO_Z [13]!=key[2]&A_TO_Z [13]!=key[3]) begin
                                    find_num[wasd] <= 13; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [14]: begin
                                if (which&A_TO_Z [14]!=key[0]&A_TO_Z [14]!=key[1]
                                    &A_TO_Z [14]!=key[2]&A_TO_Z [14]!=key[3]) begin
                                    find_num[wasd] <= 14; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [15]: begin
                                if (which&A_TO_Z [15]!=key[0]&A_TO_Z [15]!=key[1]
                                    &A_TO_Z [15]!=key[2]&A_TO_Z [15]!=key[3]) begin
                                    find_num[wasd] <= 15; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [16]: begin
                                if (which&A_TO_Z [16]!=key[0]&A_TO_Z [16]!=key[1]
                                    &A_TO_Z [16]!=key[2]&A_TO_Z [16]!=key[3]) begin
                                    find_num[wasd] <= 16; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [17]: begin
                                if (which&A_TO_Z [17]!=key[0]&A_TO_Z [17]!=key[1]
                                    &A_TO_Z [17]!=key[2]&A_TO_Z [17]!=key[3]) begin
                                    find_num[wasd] <= 17; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [18]: begin
                                if (which&A_TO_Z [18]!=key[0]&A_TO_Z [18]!=key[1]
                                    &A_TO_Z [18]!=key[2]&A_TO_Z [18]!=key[3]) begin
                                    find_num[wasd] <= 18; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [19]: begin
                                if (which&A_TO_Z [19]!=key[0]&A_TO_Z [19]!=key[1]
                                    &A_TO_Z [19]!=key[2]&A_TO_Z [19]!=key[3]) begin
                                    find_num[wasd] <= 19; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [20]: begin
                                if (which&A_TO_Z [20]!=key[0]&A_TO_Z [20]!=key[1]
                                    &A_TO_Z [20]!=key[2]&A_TO_Z [20]!=key[3]) begin
                                    find_num[wasd] <= 20; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [21]: begin
                                if (which&A_TO_Z [21]!=key[0]&A_TO_Z [21]!=key[1]
                                    &A_TO_Z [21]!=key[2]&A_TO_Z [21]!=key[3]) begin
                                    find_num[wasd] <= 21; 
                                    key[wasd] <= last_change;
                                end
                            end 
                            A_TO_Z [22]: begin
                                if (which&A_TO_Z [22]!=key[0]&A_TO_Z [22]!=key[1]
                                    &A_TO_Z [22]!=key[2]&A_TO_Z [22]!=key[3]) begin
                                    find_num[wasd] <= 22; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [23]: begin
                                if (which&A_TO_Z [23]!=key[0]&A_TO_Z [23]!=key[1]
                                    &A_TO_Z [23]!=key[2]&A_TO_Z [23]!=key[3]) begin
                                    find_num[wasd] <= 23; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [24]: begin
                                if (which&A_TO_Z [24]!=key[0]&A_TO_Z [24]!=key[1]
                                    &A_TO_Z [24]!=key[2]&A_TO_Z [24]!=key[3]) begin
                                    find_num[wasd] <= 24; 
                                    key[wasd] <= last_change;
                                end
                            end
                            A_TO_Z [25]: begin
                                if (which&A_TO_Z [25]!=key[0]&A_TO_Z [25]!=key[1]
                                    &A_TO_Z [25]!=key[2]&A_TO_Z [25]!=key[3]) begin
                                    find_num[wasd] <= 25; 
                                    key[wasd] <= last_change;
                                end
                            end
                        endcase
                    end
                end
                4'b0010: begin //choose
                    opt <= 1'b1;
                    wasd <= 4'b0;
                    which <= 1'b1;
                    wait_ <= 1'b1;
                    if (been_ready && key_down[last_change] == 1'b1) begin
                        case (last_change)
                            UP_DOWN[00] : up <=  ~up;
                            UP_DOWN[01] : up <= ~up;
                            UP_DOWN[02] : begin
                                if (~up) begin
                                    hard <= (hard==2'b10) ? 2'b0: hard+1;
                                end else begin
                                    speed <= ~speed;
                                end
                            end
                            UP_DOWN[03] : begin
                                if (~up) begin
                                    hard <= (hard==2'b0) ? 2'b10: hard-1; 
                                end else begin
                                    speed <= ~speed;
                                end
                            end
                            ENTER : begin
                                on <= 1'b1;
                                wait_ <= 1'b0;
                                stage <= 4'b0011;
                            end
                            ESC: begin
                                stage <= 4'b0000;
                            end
                        endcase
                    end
                end
                4'b0011: begin
                    up <= 0;
                    opt <= 1'b1;
                    wasd <= 4'b0;
                    which <= 1'b1;
                    if (been_ready && key_down[last_change] == 1'b1) begin
                        case (last_change)
                            key[0]: begin
                                if (drop_node[0][388+4:380-4]!=0) begin
                                    down[0] <= 2'b10;
                                end else if (drop_node[0][392+4:376-4]!=0) begin
                                    down[0] <= 2'b11;
                                end else begin
                                    down[0] <= 2'b01;
                                end
                            end
                            key[1]: begin
                                if (drop_node[1][388+4:380-4]!=0) begin
                                    down[1] <= 2'b10;
                                end else if (drop_node[1][392+4:376-4]!=0) begin
                                    down[1] <= 2'b11;
                                end else begin
                                    down[1] <= 2'b01;
                                end
                            end
                            key[2]: begin
                                if (drop_node[2][388+4:380-4]!=0) begin
                                    down[2] <= 2'b10;
                                end else if (drop_node[0][392+4:376-4]!=0) begin
                                    down[2] <= 2'b11;
                                end else begin
                                    down[2] <= 2'b01;
                                end
                            end
                            key[3]: begin
                                if (drop_node[3][388+4:380-4]!=0) begin
                                    down[3] <= 2'b10;
                                end else if (drop_node[0][392+4:376-4]!=0) begin
                                    down[3] <= 2'b11;
                                end else begin
                                    down[3] <= 2'b01;
                                end
                            end
                            ESC: begin
                                if (on) begin
                                    on <= 1'b0;
                                end else begin
                                    stage <= 4'b0;
                                    wait_ <= 1'b1;
                                    down[0] <= 0;
                                    down[1] <= 0;
                                    down[2] <= 0;
                                    down[3] <= 0;
                                end
                            end
                            ENTER: begin
                                if (~on) begin
                                    on <= 1'b1;
                                end
                            end
                        endcase
                    end
                    if (been_ready && key_down[last_change] == 1'b0) begin
                        case (last_change)
                            key[0]: begin
                                down[0] <= 2'b0;
                            end
                            key[1]: begin
                                down[1] <= 2'b0;
                            end
                            key[2]: begin
                                down[2] <= 2'b0;
                            end
                            key[3]: begin
                                down[3] <= 2'b0;
                            end
                        endcase
                    end
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin//to decide which raw will have next node
      if (rst|wait_) begin
          sav_note <= 0;
          drop_pos <= 0;
      end
      else begin
          if (sav_note == out_0 [8:1]) begin
              drop_pos <= drop_pos;
          end else if ((sav_note <= out_0 [8:1]+8)&(sav_note > out_0 [8:1])) begin
              drop_pos <= drop_pos-1;
              sav_note <= out_0 [8:1];
          end else if (sav_note > out_0 [8:1]+8) begin
              drop_pos <= drop_pos-2;
              sav_note <= out_0 [8:1];
          end else if ((sav_note >= out_0 [8:1]-8)&(sav_note < out_0 [8:1])) begin
              drop_pos <= drop_pos+1;
              sav_note <= out_0 [8:1];
          end else if (sav_note < out_0 [8:1]-8) begin
              drop_pos <= drop_pos+2;
              sav_note <= out_0 [8:1];
          end
      end
    end
    always @(posedge clk or posedge rst) begin//It's used to counting
        if (rst|wait_) begin
            bpm<= 32'd130;
            counter <= 32'b1;
            measure <= 8'b1;
            beat <= 2'b0;
            div <= 9'b0;
        end else begin
            if (on) begin
                if (counter < count_div) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 32'b1;
                    if (div < 9'd480) begin
                        div <= div+9'b1;
                    end else begin
                        div <= 9'b0;
                        if (beat != 2'b11) begin
                            beat <= beat+2'b1;
                        end else begin
                            beat <= 2'b0;
                            measure <= measure+8'b1;
                        end
                    end
                end
            end
        end
    end
endmodule
