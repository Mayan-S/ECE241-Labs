module part3 (SW, CLOCK_50, KEY, LEDR);
    // Inputs and Outputs
    input [2:0] SW; // 3-bit input to select the letter (000 for A, 001 for B, etc.)
    input [1:0] KEY; // 2-bit input: KEY[0] is reset, KEY[1] is transmit
    input CLOCK_50; // 50 MHz clock input
    output [9:0] LEDR; // 10-bit output, LEDR[0] used for Morse code output

    // Internal Signals
    wire reset = KEY[0]; // Active-low reset signal
    wire transmit = KEY[1]; // Transmit signal to start Morse code transmission

    // State Registers and Parameters
    reg [1:0] y_Q, Y; // Current state (y_Q) and next state (Y) of the FSM
    parameter S1 = 2'b00; // State S1: Idle state
    parameter S2 = 2'b01; // State S2: Load state
    parameter S3 = 2'b10; // State S3: Transmit state
    parameter S4 = 2'b11; // State S4: Shift state

    // Additional Signals
    wire out; // Output signal for Morse code
    assign LEDR[0] = out; // Connect output to LEDR[0]
    reg [3:0] M; // 4-bit register for Morse code symbol count
    wire [3:0] initialM; // Initial Morse code length
    wire [3:0] nextM; // Next value of Morse code length
    wire [10:0] X; // Morse code pattern for the selected letter
    wire [10:0] shiftQ; // Shift register output
    wire [24:0] C; // 25-bit counter for timing
    wire cTrack; // Signal indicating counter completion
    wire [2:0] sC; // Small counter for additional timing
    reg counterEn = 1'b0; // Enable signal for the counter
    reg shiftL = 1'b0; // Load signal for the shift register
    reg shiftEn = 1'b0; // Enable signal for shifting
    reg codeCountEn = 1'b0; // Enable signal for code counter
    reg mCheck = 1'b0; // Signal to check and load initial Morse code length

    // Module Instantiations
    mux_big_8to1 u1 (X, SW); // Multiplexer to select Morse code pattern
    mux_4bit_8to1 u2 (initialM, SW); // Multiplexer to select Morse code length
    shift u3 (X, shiftL, 0, shiftQ, CLOCK_50, shiftEn); // Shift register for Morse code
    codeCounter u4 (nextM, M, initialM, codeCountEn, CLOCK_50); // Counter for Morse code length
    counter u5 (CLOCK_50, reset, C, sC, counterEn, cTrack); // Timing counter for dots and dashes

    // FSM Logic
    always @ (*)
    begin
        Y = y_Q; // Default next state is the current state
        codeCountEn = 1'b0; // Default disable code counter
        shiftL = 1'b0; // Default disable shift load
        shiftEn = 1'b0; // Default disable shift enable
        counterEn = 1'b0; // Default disable counter
        mCheck = 1'b0; // Default disable Morse code check

        case (y_Q)
            S1: // Idle state
            begin
                if (transmit) Y = S1; // Stay in S1 if transmit is high
                else if (transmit == 0) Y = S2; // Move to S2 if transmit is low
            end
            S2: // Load state
            begin
                shiftL = 1'b1; // Load shift register
                mCheck = 1'b1; // Load initial Morse code length
                Y = S3; // Move to S3
            end
            S3: // Transmit state
            begin
                counterEn = 1'b1; // Enable counter for timing
                if (cTrack & ~(M == 4'b0000)) Y = S4; // Move to S4 if counter finished and M not zero
                else if (M == 0) Y = S1; // Return to S1 if all symbols transmitted
                else if (~cTrack) Y = S3; // Stay in S3 if counter not finished
            end
            S4: // Shift state
            begin
                shiftEn = 1'b1; // Enable shifting
                codeCountEn = 1'b1; // Enable code counter to decrement M
                Y = S3; // Return to S3
            end
            default: Y = S1; // Default state is S1
        endcase
    end

    // State Register Update
    always @(posedge CLOCK_50)
    begin: state_FFs
        if (~reset)
        begin
            y_Q <= S1; // Reset state to S1
        end
        else
        begin
            y_Q <= Y; // Update current state to next state
            if (codeCountEn) M <= nextM; // Update M if code counter enabled
            else if (mCheck) M <= initialM; // Load initial M if mCheck enabled
        end
    end

    // Output Assignment
    assign out = (~cTrack & shiftQ[0] & (y_Q == S3)); // Output logic for Morse code

endmodule

// Submodule: codeCounter
module codeCounter (M, pastM, inM, enable, Clock);
    input enable, Clock;
    input [3:0] pastM;
    input [3:0] inM;
    output reg [3:0] M;
    always @ (posedge Clock)
    begin
        if (enable == 1)
            M <= pastM - 1; // Decrement M if enabled
        else if (enable == 0)
            M <= inM; // Load M with initial value if not enabled
    end
endmodule

// Submodule: mux_big_8to1
module mux_big_8to1(V, s);
    input [2:0] s;
    output reg [10:0] V;
    parameter A = 5'b11101, B = 9'b101010111, C = 11'b10111010111, D = 7'b1010111,
        E = 1'b1, F = 9'b101110101, G = 9'b101110111, H = 7'b1010101;
    always @ (*)
    begin 
        if (s == 3'b000)
            V = A; // Morse code for A
        else if (s == 3'b001)
            V = B; // Morse code for B
        else if (s == 3'b010)
            V = C; // Morse code for C
        else if (s == 3'b011)
            V = D; // Morse code for D
        else if (s == 3'b100)
            V = E; // Morse code for E
        else if (s == 3'b101)
            V = F; // Morse code for F
        else if (s == 3'b110)
            V = G; // Morse code for G
        else if (s == 3'b111)
            V = H; // Morse code for H
        else
            V = 3'b000; // Default case
    end
endmodule

// Submodule: mux_4bit_8to1
module mux_4bit_8to1(V, s);
    input [2:0] s;
    output reg [3:0] V;
    parameter A = 3'b101, B = 4'b1001, C = 4'b1011, D = 3'b111,
        E = 1'b1, F = 4'b1001, G = 4'b1001, H = 3'b111;
    always @ (*)
    begin 
        if (s == 3'b000)
            V = A; // Length for A
        else if (s == 3'b001)
            V = B; // Length for B
        else if (s == 3'b010)
            V = C; // Length for C
        else if (s == 3'b011)
            V = D; // Length for D
        else if (s == 3'b100)
            V = E; // Length for E
        else if (s == 3'b101)
            V = F; // Length for F
        else if (s == 3'b110)
            V = G; // Length for G
        else if (s == 3'b111)
            V = H; // Length for H
        else
            V = 3'b000; // Default case
    end
endmodule

// Submodule: shift
module shift (R, L, W, Q, Clock, enable);
    input [0:10] R;
    input L, W, enable, Clock;
    output reg [0:10] Q;
    always @ (posedge Clock)
    begin
        if (L == 1'b1)
            Q <= R; // Load shift register
        else if (enable == 1)
        begin
            Q[0] <= W; // Shift bits
            Q[1] <= Q[0];
            Q[2] <= Q[1];
            Q[3] <= Q[2];
            Q[4] <= Q[3];
            Q[5] <= Q[4];
            Q[6] <= Q[5];
            Q[7] <= Q[6];
            Q[8] <= Q[7];
            Q[9] <= Q[8];
            Q[10] <= Q[9];
        end
        else
            Q <= Q; // Hold current state
    end
endmodule

// Submodule: counter
module counter (clock, reset, large_count, small_count, enable, finish);
    input clock, reset, enable;
    output reg finish;
    output reg [24:0] large_count;
    output reg small_count;
    always @ (posedge clock)
    begin
        if (reset == 0)
        begin
            large_count <= 25'b1011111010111100001000000; // Initial count value
            small_count <= 1'b0; // Reset small count
            finish <= 1'b0; // Reset finish flag
        end
        else if (enable == 1)
        begin
            large_count <= large_count - 1; // Decrement large count
            if (large_count == 0)
            begin
                small_count <= small_count + 1; // Increment small count
                if (small_count == 1'b1)
                    finish <= 1'b1; // Set finish flag
                else
                    finish <= 1'b0; // Clear finish flag
            end
        end
        else
        begin
            large_count <= 25'b1011111010111100001000000; // Reset large count
            small_count <= 1'b0; // Reset small count
            finish <= 1'b0; // Reset finish flag
        end
    end
endmodule