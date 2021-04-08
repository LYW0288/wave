
module note_decoder (
    input [7:0] note,
    output reg [31:0] freq
);
    always @ (*) begin
        case (note)
            8'h18 : freq = 32'd262 >> 3;//C
            8'h19 : freq = 32'd277 >> 3;//C#
            8'h1A : freq = 32'd294 >> 3;//D
            8'h1B : freq = 32'd311 >> 3;//D#
            8'h1C : freq = 32'd330 >> 3;//E
            8'h1D : freq = 32'd349 >> 3;//F
            8'h1E : freq = 32'd370 >> 3;//F#
            8'h1F : freq = 32'd392 >> 3;//G
            8'h20 : freq = 32'd415 >> 3;//G#
            8'h21 : freq = 32'd440 >> 3;//A
            8'h22 : freq = 32'd466 >> 3;//A#
            8'h23 : freq = 32'd494 >> 3;//B
            8'h24 : freq = 32'd262 >> 2;//C
            8'h25 : freq = 32'd277 >> 2;//C#
            8'h26 : freq = 32'd294 >> 2;//D
            8'h27 : freq = 32'd311 >> 2;//D#
            8'h28 : freq = 32'd330 >> 2;//E
            8'h29 : freq = 32'd349 >> 2;//F
            8'h2A : freq = 32'd370 >> 2;//F#
            8'h2B : freq = 32'd392 >> 2;//G
            8'h2C : freq = 32'd415 >> 2;//G#
            8'h2D : freq = 32'd440 >> 2;//A
            8'h2E : freq = 32'd466 >> 2;//A#
            8'h2F : freq = 32'd494 >> 2;//B
            8'h30 : freq = 32'd262 >> 1;//C
            8'h31 : freq = 32'd277 >> 1;//C#
            8'h32 : freq = 32'd294 >> 1;//D
            8'h33 : freq = 32'd311 >> 1;//D#
            8'h34 : freq = 32'd330 >> 1;//E
            8'h35 : freq = 32'd349 >> 1;//F
            8'h36 : freq = 32'd370 >> 1;//F#
            8'h37 : freq = 32'd392 >> 1;//G
            8'h38 : freq = 32'd415 >> 1;//G#
            8'h39 : freq = 32'd440 >> 1;//A
            8'h3A : freq = 32'd466 >> 1;//A#
            8'h3B : freq = 32'd494 >> 1;//B
            8'h3C : freq = 32'd262;//C
            8'h3D : freq = 32'd277;//C#
            8'h3E : freq = 32'd294;//D
            8'h3F : freq = 32'd311;//D#
            8'h40 : freq = 32'd330;//E
            8'h41 : freq = 32'd349;//F
            8'h42 : freq = 32'd370;//F#
            8'h43 : freq = 32'd392;//G
            8'h44 : freq = 32'd415;//G#
            8'h45 : freq = 32'd440;//A
            8'h46 : freq = 32'd466;//A#
            8'h47 : freq = 32'd494;//B
            8'h48 : freq = 32'd262 << 1;//C
            8'h49 : freq = 32'd277 << 1;//C#
            8'h4A : freq = 32'd294 << 1;//D
            8'h4B : freq = 32'd311 << 1;//D#
            8'h4C : freq = 32'd330 << 1;//E
            8'h4D : freq = 32'd349 << 1;//F
            8'h4E : freq = 32'd370 << 1;//F#
            8'h4F : freq = 32'd392 << 1;//G
            8'h50 : freq = 32'd415 << 1;//G#
            8'h51 : freq = 32'd440 << 1;//A
            8'h52 : freq = 32'd466 << 1;//A#
            8'h53 : freq = 32'd494 << 1;//B
            8'h54 : freq = 32'd262 << 2;//C
            8'h55 : freq = 32'd277 << 2;//C#
            8'h56 : freq = 32'd294 << 2;//D
            8'h57 : freq = 32'd311 << 2;//D#
            8'h58 : freq = 32'd330 << 2;//E
            8'h59 : freq = 32'd349 << 2;//F
            8'h5A : freq = 32'd370 << 2;//F#
            8'h5B : freq = 32'd392 << 2;//G
            8'h5C : freq = 32'd415 << 2;//G#
            8'h5D : freq = 32'd440 << 2;//A
            8'h5E : freq = 32'd466 << 2;//A#
            8'h5F : freq = 32'd494 << 2;//B
            8'h60 : freq = 32'd262 << 3;//C
            8'h61 : freq = 32'd277 << 3;//C#
            8'h62 : freq = 32'd294 << 3;//D
            8'h63 : freq = 32'd311 << 3;//D#
            8'h64 : freq = 32'd330 << 3;//E
            8'h65 : freq = 32'd349 << 3;//F
            8'h66 : freq = 32'd370 << 3;//F#
            8'h67 : freq = 32'd392 << 3;//G
            8'h68 : freq = 32'd415 << 3;//G#
            8'h69 : freq = 32'd440 << 3;//A
            8'h6A : freq = 32'd466 << 3;//A#
            8'h6B : freq = 32'd494 << 3;//B
            default       : freq = 32'd20000;
        endcase
    end
endmodule

module gen_track_triangle(
    input clk,
    input reset,
    input on,
    input out_valid, // ignore the following if it's invalid
    input on_off, // if this note is to be turned on or off
    input [7:0] note,
    output wire [11:0] num
);
    wire [9:0] num_1, num_2, num_3, num_4;
    reg [3:0] select;
    reg [7:0] note_1, note_2, note_3, note_4;

    assign num = (on) ? (num_1 + num_2 + num_3 + num_4): 0;
    gen_triangle gen_1(
        .clk(clk),
        .reset(reset),
        .num(num_1),
        .on_off(select[0]), 
        .note (note_1)
    );
    gen_triangle gen_2(
        .clk(clk),
        .reset(reset),
        .num(num_2),
        .on_off(select[1]), 
        .note (note_2)
    );
    gen_triangle gen_3(
        .clk(clk),
        .reset(reset),
        .num(num_3),
        .on_off(select[2]), 
        .note (note_3)
    );
    gen_triangle gen_4(
        .clk(clk),
        .reset(reset),
        .num(num_4),
        .on_off(select[3]), 
        .note (note_4)
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            select <= 4'b0;
            note_1 <= 8'b0;
            note_2 <= 8'b0;
            note_3 <= 8'b0;
            note_4 <= 8'b0;
        end else begin
            if (out_valid) begin
                if (on_off) begin
                    if (select[0]==0) begin
                        select[0] <= 1'b1;
                        note_1 <= note;
                    end else if (select[1]==0) begin
                        select[1] <= 1'b1;
                        note_2 <= note;
                    end else if (select[2]==0) begin
                        select[2] <= 1'b1;
                        note_3 <= note;
                    end else if (select[3]==0) begin
                        select[3] <= 1'b1;
                        note_4 <= note;
                    end
                end else begin
                    if (note_1==note) begin
                        select[0] <= 1'b0;
                        note_1 <= 8'b0;
                    end
                    if (note_2==note) begin
                        select[1] <= 1'b0;
                       note_2 <= 8'b0;
                    end
                    if (note_3==note) begin
                        select[2] <= 1'b0;
                        note_3 <= 8'b0;
                    end
                    if (note_4==note) begin
                        select[3] <= 1'b0;
                        note_4 <= 8'b0;
                    end
                end
            end
        end
    end

endmodule

module gen_triangle (
    input clk,
    input reset,
    output reg [9:0] num,
    input on_off, // if this note is to be turned on or off
    input [7:0] note // 0x00~0x7F, 3C is Middle-C, 262 Hz.  "Each value is a 'half-step' above or below the adjacent values"
);
    wire [31:0] freq;
    wire [31:0] count_max = 32'd100_000_000/freq;
    wire [31:0] count_duty = count_max / 32'd2048;
    reg [31:0] count;

    note_decoder nt_d(
        .note(note),
        .freq(freq)
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            num <= 10'b0;
        end else begin
            if(on_off)begin
                if (count < count_max) begin
                    count <= count + 1;
                    if (count%count_duty==0)begin
                        if (count < count_max/2) begin
                            num <= (num<10'b11_1111_1111) ? num + 1: num;
                        end else begin
                            num <= (num>10'b0) ? num - 1: num;
                        end
                    end
                end else begin
                    count <= 0;
                    num <= 10'b0;
                end
            end else begin
                count <= 0;
                num <= 10'b0;
            end
        end
    end

endmodule

module gen_track_sawtooth(
    input clk,
    input reset,
    input on,
    input out_valid, // ignore the following if it's invalid
    input on_off, // if this note is to be turned on or off
    input [3:0] volume,
    input [7:0] note,
    output wire [11:0] num
);
    wire [9:0] num_1, num_2, num_3, num_4;
    reg [3:0] select;
    reg [7:0] note_1, note_2, note_3, note_4;

    assign num = (on) ? num_1 + num_2 + num_3 + num_4: 0;
    gen_sawtooth gen_1(
        .clk(clk),
        .reset(reset),
        .num(num_1),
        .on_off(select[0]), 
        .note (note_1)
    );
    gen_sawtooth gen_2(
        .clk(clk),
        .reset(reset),
        .num(num_2),
        .on_off(select[1]), 
        .note (note_2)
    );
    gen_sawtooth gen_3(
        .clk(clk),
        .reset(reset),
        .num(num_3),
        .on_off(select[2]), 
        .note (note_3)
    );
    gen_sawtooth gen_4(
        .clk(clk),
        .reset(reset),
        .num(num_4),
        .on_off(select[3]), 
        .note (note_4)
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            select <= 4'b0;
            note_1 <= 8'b0;
            note_2 <= 8'b0;
            note_3 <= 8'b0;
            note_4 <= 8'b0;
        end else begin
            if (out_valid) begin
                if (on_off) begin
                    if (select[0]==0) begin
                        select[0] <= 1'b1;
                        note_1 <= note;
                    end else if (select[1]==0) begin
                        select[1] <= 1'b1;
                        note_2 <= note;
                    end else if (select[2]==0) begin
                        select[2] <= 1'b1;
                        note_3 <= note;
                    end else if (select[3]==0) begin
                        select[3] <= 1'b1;
                        note_4 <= note;
                    end
                end else begin
                    if (note_1==note) begin
                        select[0] <= 1'b0;
                        note_1 <= 8'b0;
                    end
                    if (note_2==note) begin
                        select[1] <= 1'b0;
                       note_2 <= 8'b0;
                    end
                    if (note_3==note) begin
                        select[2] <= 1'b0;
                        note_3 <= 8'b0;
                    end
                    if (note_4==note) begin
                        select[3] <= 1'b0;
                        note_4 <= 8'b0;
                    end
                end
            end
        end
    end

endmodule
module gen_sawtooth (
    input clk,
    input reset,
    output reg [9:0] num,
    input on_off, // if this note is to be turned on or off
    input [7:0] note // 0x00~0x7F, 3C is Middle-C, 262 Hz.  "Each value is a 'half-step' above or below the adjacent values"
);
    wire [31:0] freq;
    wire [31:0] count_max = 32'd100_000_000/freq;
    wire [31:0] count_duty = count_max / 32'd1024;
    reg [31:0] count;

    note_decoder nt_d(
        .note(note),
        .freq(freq)
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            num <= 10'b0;
        end else begin
            if(on_off)begin
                if (count < count_max) begin
                    count <= count + 1;
                    num <= (num<10'b11_1111_1111 & count%count_duty==0) ? num + 1: num;
                end else begin
                    count <= 0;
                    num <= 10'b0;
                end
            end else begin
                count <= 0;
                num <= 10'b0;
            end
        end
    end

endmodule

module gen_square (
    input clk,
    input reset,
    output reg [9:0] num,
    input on_off, // if this note is to be turned on or off
    input [7:0] note // 0x00~0x7F, 3C is Middle-C, 262 Hz.  "Each value is a 'half-step' above or below the adjacent values"
);
    wire [31:0] freq;
    wire [31:0] count_max = 32'd100_000_000/freq;
    wire [31:0] count_duty = count_max / 32'd1024;
    reg [31:0] count;

    note_decoder nt_d(
        .note(note),
        .freq(freq)
    );
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            num <= 0;
        end else begin
            if(on_off)begin
                if (count < count_max) begin
                    count <= count + 1;
                    if(count%count_duty==0) begin
                        num <= (num==10'b11_1111_1111) ? 0: 10'b11_1111_1111;
                    end
                end else begin
                    count <= 0;
                    num <= 0;
                end
            end else begin
                count <= 0;
                num <= 0;
            end
        end
    end

endmodule

module PWM_gen_x (
    input clk,
    input reset,
    input [11:0] num_1,
    input [11:0] num_2,
    output reg PWM
);
    reg [12:0] sav_num;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sav_num <= 0;
            PWM <= 0;
        end else begin
            if (sav_num>12'b1111_1111_1111) begin
                PWM <= 1;
                sav_num <= sav_num + num_1/8 + num_2/8 - 12'b1111_1111_1111;
            end else begin
                PWM <= 0;
                sav_num <= sav_num + num_1/8 + num_2/8;
            end
        end
    end

endmodule
