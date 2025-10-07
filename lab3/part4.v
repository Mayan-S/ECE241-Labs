module d_latch (Clk, D, Qa, Qb);
    input Clk, D;
    output Qa, Qb;
    wire R_g, S_g;

    assign S_g = D & Clk;
    assign R_g = ~D & Clk;
    assign Qa = ~(R_g | Qb);
    assign Qb = ~(S_g | Qa);
endmodule

module part4 (SW, LEDR);
    input [1:0] SW;
    output [9:0] LEDR;

    wire Qa, Qb, Qc;

    d_latch gated_d (.Clk(SW[1]), .D(SW[0]), .Qa(Qa), .Qb());

    wire Qb_next;
    assign Qb_next = SW[1] ? SW[0] : Qb;
    d_latch positive_edge (.Clk(SW[1]), .D(Qb_next), .Qa(Qb), .Qb());

    wire Qc_next;
    assign Qc_next = ~SW[1] ? SW[0] : Qc;
    d_latch negative_edge (.Clk(~SW[1]), .D(Qc_next), .Qa(Qc), .Qb());

    assign LEDR[0] = Qa;
    assign LEDR[1] = Qb;
    assign LEDR[2] = Qc;
endmodule
