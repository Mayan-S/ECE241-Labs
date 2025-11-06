module part1(SW, KEY, LEDR);
    input [1:0] SW;   
    input [0:0] KEY;  
    output [9:0] LEDR;

    wire reset_n;
    wire w;
    wire Clock;
    wire z;
    
    assign reset_n = SW[0];  
    assign w = SW[1];
    assign Clock = KEY[0];
    
    reg y8, y7, y6, y5, y4, y3, y2, y1, y0;
    wire Y8, Y7, Y6, Y5, Y4, Y3, Y2, Y1, Y0;
    
    assign Y0 = ~reset_n;
    assign Y1 = reset_n & (y0 & ~w | y1 & ~w | y5 & ~w);
    assign Y2 = reset_n & (y1 & ~w | y6 & ~w);
    assign Y3 = reset_n & (y2 & ~w | y7 & ~w);
    assign Y4 = reset_n & (y3 & ~w | y4 & ~w | y8 & ~w);
    assign Y5 = reset_n & (y0 & w | y1 & w | y5 & w);
    assign Y6 = reset_n & (y5 & w | y2 & w);
    assign Y7 = reset_n & (y6 & w | y3 & w);
    assign Y8 = reset_n & (y7 & w | y8 & w | y4 & w);
    
    always @(posedge Clock) begin
        if (~reset_n) begin
            y8 <= 1'b0;
            y7 <= 1'b0;
            y6 <= 1'b0;
            y5 <= 1'b0;
            y4 <= 1'b0;
            y3 <= 1'b0;
            y2 <= 1'b0;
            y1 <= 1'b0;
            y0 <= 1'b1;
        end else begin
            y8 <= Y8;
            y7 <= Y7;
            y6 <= Y6;
            y5 <= Y5;
            y4 <= Y4;
            y3 <= Y3;
            y2 <= Y2;
            y1 <= Y1;
            y0 <= Y0;
        end
    end
    
    assign z = y4 | y8;  
    
    assign LEDR[9] = z;
    assign LEDR[8:0] = {y8, y7, y6, y5, y4, y3, y2, y1, y0};
    
endmodule
