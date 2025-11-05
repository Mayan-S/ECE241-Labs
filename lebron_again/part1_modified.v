module part1_modified (
    input [1:0] SW,
    input KEY0,     // Clock input (manual)
    output [9:0] LEDR  // LEDR[9] = z output, LEDR[8:0] = state flip-flops
);

    // Internal signals
    wire reset_n;
    wire w;
    wire Clock;
    wire z;
    
    // Input assignments
    assign reset_n = SW[0];  // Active-low reset
    assign w = SW[1];
    assign Clock = KEY0;
    
    // State flip-flops (modified one-hot encoding with inverted y0)
    reg y8, y7, y6, y5, y4, y3, y2, y1, y0;
    
    // Next state logic wires
    wire Y8, Y7, Y6, Y5, Y4, Y3, Y2, Y1, Y0;
    
    // Next state logic using simple assign statements
    // Modified for inverted y0:
    // State A (reset state): all flip-flops = 0 (y0 inverted, so ~y0 represents state A)
    assign Y0 = reset_n;  // y0 = 1 means NOT in state A
    
    // State B: y1 = 1, y0 = 1 (reached from A when w=0)
    assign Y1 = reset_n & (~y0 & ~w | y1 & y0 & ~w | y5 & y0 & ~w);
    
    // State C: y2 = 1, y0 = 1 (reached from B when w=0)
    assign Y2 = reset_n & (y1 & y0 & ~w | y6 & y0 & ~w);
    
    // State D: y3 = 1, y0 = 1 (reached from C when w=0)
    assign Y3 = reset_n & (y2 & y0 & ~w | y7 & y0 & ~w);
    
    // State E: y4 = 1, y0 = 1 (reached from D when w=0, outputs z=1)
    assign Y4 = reset_n & (y3 & y0 & ~w | y4 & y0 & ~w | y8 & y0 & ~w);
    
    // State F: y5 = 1, y0 = 1 (reached from A when w=1)
    assign Y5 = reset_n & (~y0 & w | y1 & y0 & w | y5 & y0 & w);
    
    // State G: y6 = 1, y0 = 1 (reached from F when w=1)
    assign Y6 = reset_n & (y5 & y0 & w | y2 & y0 & w);
    
    // State H: y7 = 1, y0 = 1 (reached from G when w=1)
    assign Y7 = reset_n & (y6 & y0 & w | y3 & y0 & w);
    
    // State I: y8 = 1, y0 = 1 (reached from H when w=1, outputs z=1)
    assign Y8 = reset_n & (y7 & y0 & w | y8 & y0 & w | y4 & y0 & w);
    
    // State flip-flops
    always @(posedge Clock) begin
        if (~reset_n) begin
            // Reset to state A (all 0s in modified encoding)
            y8 <= 1'b0;
            y7 <= 1'b0;
            y6 <= 1'b0;
            y5 <= 1'b0;
            y4 <= 1'b0;
            y3 <= 1'b0;
            y2 <= 1'b0;
            y1 <= 1'b0;
            y0 <= 1'b0;  // y0 = 0 in reset state (inverted)
        end else begin
            // Update state flip-flops
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
    
    // Output logic
    assign z = (y4 & y0) | (y8 & y0);  // z=1 in states E and I (when y0=1)
    
    // Output assignments
    assign LEDR[9] = z;
    assign LEDR[8:0] = {y8, y7, y6, y5, y4, y3, y2, y1, y0};
    
endmodule
