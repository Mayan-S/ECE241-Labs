//use this code
module part4 (CLOCK_50, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input CLOCK_50;  
    input  [0:0] KEY;  
    output [6:0] HEX5;
    output [6:0] HEX4;
    output [6:0] HEX3;
    output [6:0] HEX2;
    output [6:0] HEX1;
    output [6:0] HEX0;

    parameter MAX_COUNT = 50_000_000 - 1;

    reg [25:0] big_cnt;

    reg [3:0] codes [5:0];

    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            big_cnt <= 26'd0;
            codes[5] <= 4'h0;
            codes[4] <= 4'h0;
            codes[3] <= 4'h0;
            codes[2] <= 4'hD;  
            codes[1] <= 4'hE;  
            codes[0] <= 4'h1;  
        end
        else if (big_cnt == MAX_COUNT) begin
            big_cnt <= 26'd0;
            codes[5] <= codes[4];
            codes[4] <= codes[3];
            codes[3] <= codes[2];
            codes[2] <= codes[1];
            codes[1] <= codes[0];
            codes[0] <= codes[5];
        end
        else begin
            big_cnt <= big_cnt + 26'd1;
        end
    end

    function [6:0] decode_dE1;
        input [3:0] v;
        begin
            if      (v == 4'h1) decode_dE1 = 7'b1111001; 
            else if (v == 4'hE) decode_dE1 = 7'b0000110;
            else if (v == 4'hD) decode_dE1 = 7'b0100001; 
            else                decode_dE1 = 7'b1111111; 
        end
    endfunction

    assign HEX5 = decode_dE1(codes[5]);
    assign HEX4 = decode_dE1(codes[4]);
    assign HEX3 = decode_dE1(codes[3]);
    assign HEX2 = decode_dE1(codes[2]);
    assign HEX1 = decode_dE1(codes[1]);
    assign HEX0 = decode_dE1(codes[0]);

endmodule
