module part1(SW, KEY, LEDR);
    input [1:0] SW;   
    input [0:0] KEY;  
    output [9:0] LEDR;

    wire reset_n = SW[0];
    wire w = SW[1];
    wire clk = KEY[0];

    reg  [8:0] y;
    wire [8:0] Y_n;

    assign Y_n[0] = 1'b0;                                   
    assign Y_n[1] = (~w) & (y[0] | y[5] | y[6] | y[7] | y[8]);
    assign Y_n[2] = (~w) & y[1];
    assign Y_n[3] = (~w) & y[2];
    assign Y_n[4] = (~w) & (y[3] | y[4]);
    assign Y_n[5] =  w  & (y[0] | y[1] | y[2] | y[3] | y[4]);
    assign Y_n[6] =  w  & y[5];
    assign Y_n[7] =  w  & y[6];
    assign Y_n[8] =  w  & (y[7] | y[8]);

    always @(posedge clk) begin
        if (!reset_n)    
            y <= 9'b000000001;
        else              
            y <= Y_n;
    end

    wire z = y[4] | y[8];

    assign LEDR[9]   = z;
    assign LEDR[8:0] = y;
endmodule
