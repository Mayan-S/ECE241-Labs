module d_latch (Clk, D, Qa, Qb);
    input Clk, D;
    output Qa, Qb;
    wire R_g, S_g;

    assign S_g = D & Clk;
    assign R_g = ~D & Clk;
    assign Qa = ~(R_g | Qb);
    assign Qb = ~(S_g | Qa);
endmodule

module part2 (SW, LEDR);
    input [1:0] SW;
    output [9:0] LEDR;

    wire Qa, Qb;
	 
    d_latch u1 (.Clk(SW[1]), .D(SW[0]), .Qa(Qa), .Qb(Qb));
    
	 assign LEDR[0] = Qa;
	 
Endmodule
