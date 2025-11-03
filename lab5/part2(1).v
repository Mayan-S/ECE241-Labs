module part2(SW, KEY, LEDR);
    input  [1:0] SW;
    input  [0:0] KEY;
    output [9:0] LEDR;

    wire reset_n = SW[0];
    wire w = SW[1];
    wire clk = KEY[0];

    reg  [3:0] y_Q, Y_D;
    wire z;

    parameter A = 4'b0000,
              B = 4'b0001,
              C = 4'b0010,
              D = 4'b0011,
              E = 4'b0100,
              F = 4'b0101,
              G = 4'b0110,
              H = 4'b0111,
              I = 4'b1000;

    always @(*) begin
        case (y_Q)
            A: Y_D = (w ? F : B);
            B: Y_D = (w ? F : C);
            C: Y_D = (w ? F : D);
            D: Y_D = (w ? F : E);
            E: Y_D = (w ? F : E);
            F: Y_D = (w ? G : B);
            G: Y_D = (w ? H : B);
            H: Y_D = (w ? I : B);
            I: Y_D = (w ? I : B);
            default: Y_D = A;
        endcase
    end

    always @(posedge clk) begin
        if (!reset_n)
            y_Q <= A;
        else
            y_Q <= Y_D;
    end

    assign z = (y_Q == E) || (y_Q == I);
    assign LEDR[9] = z;
    assign LEDR[3:0] = y_Q;
    assign LEDR[8:4] = 5'b0;

endmodule
