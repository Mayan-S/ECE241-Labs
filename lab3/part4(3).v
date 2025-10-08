module part4 (Clk, D, Qa, Qb, Qc);
input Clk, D;
output Qa, Qb, Qc;
   D_latch q1 (D, Clk, Qa);
   posFlip q2 (D, Clk, Qb);
   posFlip q3 (D, ~Clk, Qc);
endmodule


module D_latch (D, Clk, Q);
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


module posFlip (D, Clk, Q);
input D, Clk;
output Q;
wire Qm;
   D_latch t1 (D, ~Clk, Qm);
   D_latch t2 (Qm, Clk, Q);
endmodule
