// use this code
module T_FF (
    input  wire clk,
    input  wire T,
    input  wire clear_n,    
    output reg  Q
);
    always @(posedge clk) begin
        if (clear_n == 1'b0)
            Q <= 1'b0;
        else if (T)
            Q <= ~Q;
        // else hold
    end
endmodule


module hex_display (
    input  [3:0] value,
    output reg [6:0] HEX
);
    always @(*) begin
        if      (value == 4'h0) HEX = 7'b1000000;
        else if (value == 4'h1) HEX = 7'b1111001;
        else if (value == 4'h2) HEX = 7'b0100100;
        else if (value == 4'h3) HEX = 7'b0110000;
        else if (value == 4'h4) HEX = 7'b0011001;
        else if (value == 4'h5) HEX = 7'b0010010;
        else if (value == 4'h6) HEX = 7'b0000010;
        else if (value == 4'h7) HEX = 7'b1111000;
        else if (value == 4'h8) HEX = 7'b0000000;
        else if (value == 4'h9) HEX = 7'b0010000;
        else if (value == 4'hA) HEX = 7'b0001000;
        else if (value == 4'hB) HEX = 7'b0000011;
        else if (value == 4'hC) HEX = 7'b1000110;
        else if (value == 4'hD) HEX = 7'b0100001;
        else if (value == 4'hE) HEX = 7'b0000110;
        else if (value == 4'hF) HEX = 7'b0001110;
        else                    HEX = 7'b1111111;
    end
endmodule


module part1 (SW, KEY, HEX1, HEX0);
    input  [1:0] SW;    
    input  [0:0] KEY;
    output [6:0] HEX1;
    output [6:0] HEX0;

    wire enable  = SW[1];
    wire clear_n = SW[0];

    wire [7:0] Q;

    wire T0, T1, T2, T3, T4, T5, T6, T7;

    assign T0 = enable;
    assign T1 = enable & Q[0];
    assign T2 = enable & Q[0] & Q[1];
    assign T3 = enable & Q[0] & Q[1] & Q[2];
    assign T4 = enable & Q[0] & Q[1] & Q[2] & Q[3];
    assign T5 = enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4];
    assign T6 = enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5];
    assign T7 = enable & Q[0] & Q[1] & Q[2] & Q[3] & Q[4] & Q[5] & Q[6];

    T_FF ff0 (.clk(KEY[0]), .T(T0), .clear_n(clear_n), .Q(Q[0]));
    T_FF ff1 (.clk(KEY[0]), .T(T1), .clear_n(clear_n), .Q(Q[1]));
    T_FF ff2 (.clk(KEY[0]), .T(T2), .clear_n(clear_n), .Q(Q[2]));
    T_FF ff3 (.clk(KEY[0]), .T(T3), .clear_n(clear_n), .Q(Q[3]));
    T_FF ff4 (.clk(KEY[0]), .T(T4), .clear_n(clear_n), .Q(Q[4]));
    T_FF ff5 (.clk(KEY[0]), .T(T5), .clear_n(clear_n), .Q(Q[5]));
    T_FF ff6 (.clk(KEY[0]), .T(T6), .clear_n(clear_n), .Q(Q[6]));
    T_FF ff7 (.clk(KEY[0]), .T(T7), .clear_n(clear_n), .Q(Q[7]));

    hex_display disp_lo (.value(Q[3:0]), .HEX(HEX0));
    hex_display disp_hi (.value(Q[7:4]), .HEX(HEX1));

endmodule
