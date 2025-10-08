module part5 (SW, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR);
   input [7:0] SW;
   input [1:0] KEY;
   reg [7:0] Q;
   wire [7:0] B = SW;
   wire [7:0] S;
   output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
   output [9:0] LEDR;
   wire cout;
wire Resetn = KEY[0];
wire clk = KEY[1];
always @ (negedge Resetn, posedge clk)
       if (!Resetn)
           Q <= 8'b0;
       else
           Q <= SW;
   rAdder do2 (Q, B, S, cout);
   hexDisplay do3 (Q[3:0], HEX2);
   hexDisplay do4 (Q[7:4], HEX3);
   hexDisplay do5 (B[3:0], HEX0);
   hexDisplay do6 (B[7:4], HEX1);
   hexDisplay do7 (S[3:0], HEX4);
   hexDisplay do8 (S[7:4], HEX5);
   assign LEDR[0] = cout;
endmodule


module rAdder (x, y, s, Cout);
  input [7:0] x;
  input [7:0] y;
  wire Cin = 1'b0;
  output [7:0] s;
  output Cout;




  wire c1, c2, c3, c4, c5, c6, c7;




  fAdder u1 (x[0], y[0], Cin, s[0], c1);
  fAdder u2 (x[1], y[1], c1, s[1], c2);
  fAdder u3 (x[2], y[2], c2, s[2], c3);
  fAdder u4 (x[3], y[3], c3, s[3], c4);
  fAdder u5 (x[4], y[4], c4, s[4], c5);
  fAdder u6 (x[5], y[5], c5, s[5], c6);
  fAdder u7 (x[6], y[6], c6, s[6], c7);
  fAdder u8 (x[7], y[7], c7, s[7], Cout);
endmodule




module fAdder (a, b, cin, s, cout);
  input a, b, cin;
  output s, cout;
  assign s = a^b^cin;
  assign cout = (a & b) | (a & cin) | (b & cin);
endmodule


module hexDisplay (S, h);
   input [3:0] S;
   output [6:0] h;
  wire s0, s1, s2, s3;
  assign s0 = S[0];
  assign s1 = S[1];
  assign s2 = S[2];
  assign s3 = S[3];
   assign h[0] = (~s3 & s2 & ~s1 & ~s0) | (~s3 & ~s2 & ~s1 & s0) | (s3 & s2 & ~s1 & s0) | (s3 & ~s2 & s1 & s0); 
  assign h[1] = (s3 & s2 & ~s1 & ~s0) | (~s3 & s2 & ~s1 & s0) | (s3 & s1 & s0) | (s2 & s1 & ~s0);
  assign h[2] = (s3 & s2 & s1) | (~s3 & ~s2 & s1 & ~s0) | (s3 & s2 & ~s0);
  assign h[3] = (~s3 & s2 & ~s1 & ~s0) | (~s2 & ~s1 & s0) | (s2 & s1 & s0) | (s3 & ~s2 & s1 & ~s0);
  assign h[4] = (~s3 & s0) | (~s3 & s2 & ~s1) | (~s2 & ~s1 & s0);
  assign h[5] = (~s3 & ~s2 & s0) | (~s3 & s1 & s0) | (~s3 & ~s2 & s1) | (s3 & s2 & ~s1 & s0);
  assign h[6] = (~s3 & ~s2 & ~s1) | (~s3 & s2 & s1 & s0) | (s3 & s2 & ~s1 & ~s0);
endmodule

