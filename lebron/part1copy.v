module part1 (
    input  wire [1:0] SW,     // SW[0]=resetn (active-low), SW[1]=w
    input  wire [0:0] KEY,    // KEY[0]=clock (tap to step)
    output wire [9:0] LEDR    // LEDR[9]=z, LEDR[8:0]=state one-hot (A..I)
);
    wire resetn = SW[0];
    wire w      = SW[1];
    wire clock  = KEY[0];

    // One-hot state register: y_r[0]=A, ..., y_r[8]=I
    reg  [8:0] y_r;
    wire [8:0] Y;

    // -------- Next-state (matches Fig. 2) --------
    // From A: w=0 -> B, w=1 -> F
    assign Y[1] = (y_r[0] & ~w) | ((y_r[5]|y_r[6]|y_r[7]|y_r[8]) & ~w); // to B on 0
    assign Y[5] = (y_r[0] &  w) | ((y_r[1]|y_r[2]|y_r[3]|y_r[4]) &  w); // to F on 1

    // ZEROS run (left): B->C->D->E on w=0 ; E holds on 0
    assign Y[2] =  y_r[1] & ~w;
    assign Y[3] =  y_r[2] & ~w;
    assign Y[4] = (y_r[3] & ~w) | (y_r[4] & ~w);

    // ONES run (right): F->G->H->I on w=1 ; I holds on 1
    assign Y[6] =  y_r[5] &  w;
    assign Y[7] =  y_r[6] &  w;
    assign Y[8] = (y_r[7] &  w) | (y_r[8] &  w);

    // No incoming arcs to A (other than reset)
    assign Y[0] = 1'b0;

    // -------- State FFs (sync, active-low reset to A) --------
    always @(posedge clock) begin
        if (!resetn) y_r <= 9'b000000001;  // A
        else         y_r <= Y;
    end

    // -------- Outputs --------
    wire z = y_r[4] | y_r[8];    // E or I
    assign LEDR[9]   = z;
    assign LEDR[8:0] = y_r;      // Table 1 one-hot on LEDs: LEDR0=A ... LEDR8=I
endmodule