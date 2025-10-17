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


module part2 (
    input  [1:0] SW,      
    input  [0:0] KEY,     
    output [6:0] HEX3,    
    output [6:0] HEX2,
    output [6:0] HEX1,
    output [6:0] HEX0     
);

    wire enable  = SW[1];
    wire clear_n = SW[0];

    reg [15:0] Q;

    always @(posedge KEY[0]) begin
        if (clear_n == 1'b0)
            Q <= 16'b0;
        else if (enable)
            Q <= Q + 1;
    end

    hex_display disp0 (.value(Q[ 3: 0]), .HEX(HEX0));
    hex_display disp1 (.value(Q[ 7: 4]), .HEX(HEX1));
    hex_display disp2 (.value(Q[11: 8]), .HEX(HEX2));
    hex_display disp3 (.value(Q[15:12]), .HEX(HEX3));

endmodule
