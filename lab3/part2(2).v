module D_latch (Clk, D, Q);
    input Clk, D;
    output Q;
    wire Qa, Qb;
    wire S, R, R_g, S_g;
    assign S = D;
    assign R = ~D;
    assign R_g = ~(R & Clk);
    assign S_g = ~(S & Clk);
    assign Qa = ~(S_g & Qb);
    assign Qb = ~(R_g & Qa);
    assign Q = Qa;
endmodule

module part2 (SW, LEDR);
    input [1:0] SW;
    output [9:0] LEDR;

    wire Q;
	 
    D_latch u1 (.Clk(SW[1]), .D(SW[0]), .Q(Q));
    
	assign LEDR[0] = Q;
	 
endmodule