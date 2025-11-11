module part2 (
    input  wire [1:0] SW,     // SW[0]=resetn, SW[1]=w
    input  wire [0:0] KEY,    // KEY[0]=Clock
    output wire [9:0] LEDR    // LEDR[9]=z; LEDR[3:0]=y_Q; others 0
);
    wire resetn = SW[0];
    wire w      = SW[1];
    wire Clock  = KEY[0];

    // 4 FFs for binary-coded state
    reg  [3:0] y_Q, Y_D;

    // Table 3 encodings: y3 y2 y1 y0
    localparam [3:0]
        A = 4'b0000,
        B = 4'b0001, // zeros-run: 1st zero
        C = 4'b0010, // zeros-run: 2nd zero
        D = 4'b0011, // zeros-run: 3rd zero
        E = 4'b0100, // zeros-run: 4+ zeros (z=1)
        F = 4'b0101, // ones-run:  1st one
        G = 4'b0110, // ones-run:  2nd one
        H = 4'b0111, // ones-run:  3rd one
        I = 4'b1000; // ones-run:  4+ ones  (z=1)

    // Next-state logic (matches Fig. 2)
    always @(*) begin
        case (y_Q)
            A:  Y_D = (~w) ? B : F;
            B:  Y_D = (~w) ? C : F;
            C:  Y_D = (~w) ? D : F;
            D:  Y_D = (~w) ? E : F;
            E:  Y_D = (~w) ? E : F;  // hold on 0s
            F:  Y_D = ( w) ? G : B;
            G:  Y_D = ( w) ? H : B;
            H:  Y_D = ( w) ? I : B;
            I:  Y_D = ( w) ? I : B;  // hold on 1s
            default: Y_D = A;
        endcase
    end

    // State FFs (sync, active-low reset)
    always @(posedge Clock) begin
        if (!resetn) y_Q <= A;
        else         y_Q <= Y_D;
    end

    // Outputs: z in E or I; LEDs show binary state code on LEDR[3:0]
    wire z = (y_Q == E) | (y_Q == I);

    assign LEDR[9]   = z;
    assign LEDR[3:0] = y_Q;      // y3..y0
    assign LEDR[8:4] = 5'b0;     // unused LEDs off
endmodule