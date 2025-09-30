module part4 (SW, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input  [8:0] SW;         
    output [9:0] LEDR;       
    output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0; 

    wire [3:0] X, Y;
    wire cin;
    wire [4:0] binary_sum;
    wire [3:0] ones, tens;
    wire [4:0] corrected_sum;
    wire invalid;

    // Assign inputs
    assign X   = SW[7:4];
    assign Y   = SW[3:0];
    assign cin = SW[8];

    // Step 1: Perform binary addition
    assign binary_sum = X + Y + cin;

    // Step 2: Detect invalid BCD inputs
    assign invalid = (X > 9) | (Y > 9);

    // Step 3: Correct sum if > 9
    assign corrected_sum = (binary_sum > 9) ? (binary_sum + 6) : binary_sum;

    // Step 4: Extract BCD digits
    assign tens = corrected_sum / 10;
    assign ones = corrected_sum % 10;

    // Step 5: Drive outputs
    assign LEDR[4:0] = binary_sum; 
    assign LEDR[9]   = invalid;     
    assign LEDR[8:5] = 4'b0;

    // Step 6: 7-seg decoders
    seg7 X_display (X, HEX5); 
    assign HEX4 = 7'b1111111;       
    seg7 Y_display (Y, HEX3);
    assign HEX2 = 7'b1111111;       
    seg7 tens_display (tens, HEX1);
    seg7 ones_display (ones, HEX0);

endmodule

module seg7 (input [3:0] c, output [6:0] display);
    assign display[0] = ~((~c[3] & ~c[2] & ~c[1] & c[0]) |
                          (~c[3] & c[2] & ~c[1] & ~c[0]) |
                          (c[3] & ~c[2] & c[1] & c[0]) |
                          (c[3] & c[2] & ~c[1] & c[0]));
    assign display[1] = ~((~c[3] & c[2] & ~c[1] & c[0]) |
                          (c[2] & c[1] & ~c[0]) |
                          (c[3] & c[1] & c[0]) |
                          (c[3] & c[2] & ~c[0]));
    assign display[2] = ~((~c[3] & ~c[2] & c[1] & ~c[0]) |
                          (c[3] & c[2] & ~c[0]) |
                          (c[3] & c[2] & c[1]));
    assign display[3] = ~((~c[2] & ~c[1] & c[0]) |
                          (~c[3] & c[2] & ~c[1] & ~c[0]) |
                          (c[2] & c[1] & c[0]) |
                          (c[3] & ~c[2] & c[1] & ~c[0]));
    assign display[4] = ~((~c[3] & c[0]) |
                          (~c[3] & c[2] & ~c[1]) |
                          (~c[2] & ~c[1] & c[0]));
    assign display[5] = ~((~c[3] & ~c[2] & c[0]) |
                          (~c[3] & ~c[2] & c[1]) |
                          (~c[3] & c[1] & c[0]) |
                          (c[3] & c[2] & ~c[1] & c[0]));
    assign display[6] = ~((~c[3] & ~c[2] & ~c[1]) |
                          (~c[3] & c[2] & c[1] & c[0]) |
                          (c[3] & c[2] & ~c[1] & ~c[0]));
endmodule
