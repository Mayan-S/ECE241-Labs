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

module part3 (SW, LEDR);
    input [1:0] SW;
    output [9:0] LEDR;

    wire Q_m, Q_s;

    D_latch Master (.Clk(~SW[1]), .D(SW[0]), .Q(Q_m));
	 
    D_latch Slave (.Clk(SW[1]), .D(Q_m), .Q(Q_s));

    assign LEDR[0] = Q_s;

endmodule
