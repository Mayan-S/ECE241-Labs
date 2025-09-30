module full_adder (a, b, cin, s, cout);
    input a, b, cin;
    output s, cout;
    assign s = a ^ b ^ cin;                		 
    assign cout = (a & b) | (a & cin) | (b & cin); 
endmodule

module part3 (SW, LEDR);
    input [8:0] SW;
	output [9:0] LEDR;
	
    wire [3:0] A = SW[7:4];
    wire [3:0] B = SW[3:0];
    wire [3:0] S;
    wire cin = SW[8];
    wire c1, c2, c3, cout;

    // 4 full adders
    full_adder FA0 (.a(A[0]), .b(B[0]), .cin(cin),  .s(S[0]), .cout(c1));
    full_adder FA1 (.a(A[1]), .b(B[1]), .cin(c1),   .s(S[1]), .cout(c2));
    full_adder FA2 (.a(A[2]), .b(B[2]), .cin(c2),   .s(S[2]), .cout(c3));
    full_adder FA3 (.a(A[3]), .b(B[3]), .cin(c3),   .s(S[3]), .cout(cout));

    assign LEDR[3:0] = S;
    assign LEDR[4] = cout;
endmodule
