module part5 (
    input [7:0] SW,       // Switches for input
    input [1:0] KEY,      // Keys for reset and clock
    output [6:0] HEX5,    // 7-segment display for sum
    output [6:0] HEX4,    // 7-segment display for sum
    output [6:0] HEX3,    // 7-segment display for A
    output [6:0] HEX2,    // 7-segment display for A
    output [6:0] HEX1,    // 7-segment display for B
    output [6:0] HEX0,    // 7-segment display for B
    output [9:0] LEDR     // LEDR[0] for carry-out
);

    reg [7:0] A, B;
    wire [8:0] S; // 9 bits to accommodate carry-out

    // Assign the sum
    assign S = A + B;

    // Display the carry-out
    assign LEDR[0] = S[8];

    // 7-segment display decoder
    function [6:0] hex_to_7seg;
        input [3:0] hex;
        case (hex)
            4'h0: hex_to_7seg = 7'b1000000;
            4'h1: hex_to_7seg = 7'b1111001;
            4'h2: hex_to_7seg = 7'b0100100;
            4'h3: hex_to_7seg = 7'b0110000;
            4'h4: hex_to_7seg = 7'b0011001;
            4'h5: hex_to_7seg = 7'b0010010;
            4'h6: hex_to_7seg = 7'b0000010;
            4'h7: hex_to_7seg = 7'b1111000;
            4'h8: hex_to_7seg = 7'b0000000;
            4'h9: hex_to_7seg = 7'b0010000;
            4'hA: hex_to_7seg = 7'b0001000;
            4'hB: hex_to_7seg = 7'b0000011;
            4'hC: hex_to_7seg = 7'b1000110;
            4'hD: hex_to_7seg = 7'b0100001;
            4'hE: hex_to_7seg = 7'b0000110;
            4'hF: hex_to_7seg = 7'b0001110;
            default: hex_to_7seg = 7'b1111111; // Blank
        endcase
    endfunction

    // Assign 7-segment displays
    assign HEX3 = hex_to_7seg(A[7:4]);
    assign HEX2 = hex_to_7seg(A[3:0]);
    assign HEX1 = hex_to_7seg(B[7:4]);
    assign HEX0 = hex_to_7seg(B[3:0]);
    assign HEX5 = hex_to_7seg(S[7:4]);
    assign HEX4 = hex_to_7seg(S[3:0]);

    // Register logic for A and B
    always @(negedge KEY[1] or negedge KEY[0]) begin
        if (!KEY[0]) begin
            A <= 8'b0;
            B <= 8'b0;
        end else begin
            if (SW[7:0] != 8'b0) begin
                A <= SW[7:0];
            end else begin
                B <= SW[7:0];
            end
        end
    end

endmodule
