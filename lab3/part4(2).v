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

module part4 (Clk, D, Qa, Qb, Qc);
    input Clk, D;
    output Qa, Qb, Qc;

    D_latch gated_d (.Clk(Clk), .D(D), .Q(Qa));

    wire Qb_next;
    assign Qb_next = Clk ? D : Qb;
    D_latch positive_edge (.Clk(Clk), .D(Qb_next), .Q(Qb));

    wire Qc_next;
    assign Qc_next = ~Clk ? D : Qc;
    D_latch negative_edge (.Clk(~Clk), .D(Qc_next), .Q(Qc));
endmodule
