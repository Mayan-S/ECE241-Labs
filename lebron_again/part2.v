module part2 (
    input [1:0] SW,      // SW[0] = reset_n, SW[1] = w
    input [0:0] KEY,     // KEY[0] = Clock
    output [9:0] LEDR    // LEDR[9] = z, LEDR[3:0] = state
);

    // Define signals
    wire Clock, reset_n, w;
    wire z;
    
    // Input assignments
    assign Clock = KEY[0];
    assign reset_n = SW[0];
    assign w = SW[1];
    
    // State registers: y_Q = current state, Y_D = next state
    reg [3:0] y_Q, Y_D;
    
    // State encoding parameters
    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100,
              F = 4'b0101, G = 4'b0110, H = 4'b0111, I = 4'b1000;
    
    // Next state logic - combinational always block
    always @(w, y_Q)
    begin: state_table
        case (y_Q)
            A: begin
                if (!w) Y_D = B;
                else Y_D = F;
            end
            
            B: begin
                if (!w) Y_D = C;
                else Y_D = F;
            end
            
            C: begin
                if (!w) Y_D = D;
                else Y_D = F;
            end
            
            D: begin
                if (!w) Y_D = E;
                else Y_D = F;
            end
            
            E: begin
                if (!w) Y_D = E;  // Stay in E if w=0 (four or more 0s)
                else Y_D = F;
            end
            
            F: begin
                if (!w) Y_D = B;
                else Y_D = G;
            end
            
            G: begin
                if (!w) Y_D = B;
                else Y_D = H;
            end
            
            H: begin
                if (!w) Y_D = B;
                else Y_D = I;
            end
            
            I: begin
                if (!w) Y_D = B;
                else Y_D = I;  // Stay in I if w=1 (four or more 1s)
            end
            
            default: Y_D = 4'bxxxx;
        endcase
    end // state_table
    
    // State flip-flops - sequential always block
    always @(posedge Clock)
    begin: state_FFs
        if (!reset_n)  // Active-low synchronous reset
            y_Q <= A;
        else
            y_Q <= Y_D;
    end // state_FFs
    
    // Output logic
    assign z = (y_Q == E) | (y_Q == I);  // z=1 in states E and I
    
    // Assignments for LEDs
    assign LEDR[9] = z;           // Output z on LEDR9
    assign LEDR[3:0] = y_Q;       // Current state on LEDR[3:0]
    assign LEDR[8:4] = 5'b00000;  // Unused LEDs off
    
endmodule