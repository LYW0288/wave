

module track_monitor( 
	input clk,
	input rst,
    input on,
    input wait_,
    input [18:0] time_,
    input [27:0] out,
    input [1:0] hard,
    output reg out_valid, 
    output reg on_off, 
    output reg [7:0] note,
    output reg [11:0] address
);
    reg [8:0] sav_note;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            note <= 0;
            on_off <= 0;
            address <= 0;
            sav_note <= 0;
            out_valid <= 0;
        end
        else begin
            if (wait_) begin
                note <= 0;
                on_off <= 0;
                address <= 0;
                sav_note <= 0;
                out_valid <= 0;
            end else begin
                if (out[27:9] == time_) begin
                    if (sav_note == out[8:0]) begin
                        out_valid <= 1'b0;
                    end else begin
                        out_valid <= 1'b1;
                        {note, on_off} <= out[8:0];
                        sav_note <= out[8:0];
                        address <= address+12'b1+hard*2;
                    end
                end else begin
                    on_off <= 0;
                    sav_note <= 0;
                    out_valid <= 0;
                end
            end
        end
    end
endmodule

module mem_monitor(
	input clk,
    input [11:0] address_0,
    input [11:0] address_1,
    input [11:0] address_2,
    output wire [27:0] out_0,
    output wire [27:0] out_1,
    output wire [27:0] out_2
);
    friction_track_0 tone(
        .clka(clk),
        .wea(0),
        .addra((address_0)%1342),
        .dina(0),
        .douta(out_0)
    );
    friction_track_0 music_num_1(
        .clka(clk),
        .wea(0),
        .addra((address_1)%1342),
        .dina(0),
        .douta(out_1)
    );
    friction_track_1 music_num_2(
    	.clka(clk),
    	.wea(0),
    	.addra(address_2),
    	.dina(0),
    	.douta(out_2)
    );

endmodule