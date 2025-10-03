module d_latch (Clk, D, Qa, Qb);
    input Clk, D;
    output Qa, Qb;
    wire R_g, S_g;

    assign S_g = D & Clk;
    assign R_g = ~D & Clk;
    assign Qa = ~(R_g | Qb);
    assign Qb = ~(S_g | Qa);
endmodule

module part3 (SW, LEDR);
    input [1:0] SW;
    output [9:0] LEDR;

    wire Qa_m, Qb_m, Qa_s, Qb_s;

    d_latch master (.Clk(~SW[1]), .D(SW[0]), .Qa(Qa_m), .Qb(Qb_m));
	 
    d_latch slave (.Clk(SW[1]), .D(Qa_m), .Qa(Qa_s), .Qb(Qb_s));

    assign LEDR[0] = Qa_s;

	//Turn on: SW[0] == 1, then SW[1] ==1
	//Turn off: SW[0] == 0, then toggle SW[1] on and off
	 
endmodule



