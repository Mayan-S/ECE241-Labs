module part1_mod(
    input  [1:0] SW,    // SW[0] = active-low sync reset, SW[1] = w
    input        KEY,   // KEY[0] = clk
    output [9:0] LEDR
);

    wire reset_n = SW[0];
    wire w       = SW[1];
    wire clk     = KEY;

    // 9 state bits, one-hot but with A = 000000000
    reg  [8:0] y;
    wire [8:0] d;

    // Because in the new code y[0] = 0 in A, =1 in every other state,
    // we invert it to recover the “original” A-bit when writing the logic:
    wire y0_orig = ~y[0];

    //--- next-state logic ---
    // D[0] must now be 1 in every non-reset state (and on reset we'll force y=0)
    assign d[0] = 1'b1;

    // all the other D’s are identical to before, except that
    // any reference to the old y[0] is now y0_orig:
    assign d[1] = (~w) & ( y0_orig | y[5] | y[6] | y[7] | y[8] );
    assign d[2] = (~w) & y[1];
    assign d[3] = (~w) & y[2];
    assign d[4] = (~w) & y[3];
    assign d[5] =  w    & ( y0_orig | y[1] | y[2] | y[3] | y[4] );
    assign d[6] =  w    & y[5];
    assign d[7] =  w    & y[6];
    assign d[8] =  w    & ( y[7] | y[8] );

    //--- state register with synchronous, active-low reset ---
    always @(posedge clk) begin
        if (!reset_n)
            y <= 9'b000000000;  // reset state = A = all zeros
        else
            y <= d;
    end

    //--- output z = 1 in states E or I just as before ---
    wire z = y[4] | y[8];

    // LEDR[8:0] show the one-hot state bits, LEDR[9] = z
    assign LEDR[8:0] = y;
    assign LEDR[9]   = z;

endmodule
