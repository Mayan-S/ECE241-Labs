module part3 (SW, KEY, LEDR, CLOCK_50);
    input [2:0] SW;
    input [1:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;

    wire reset = KEY[0];
    wire transmit = KEY[1];

    reg [1:0] y_Q, Y;
    parameter S1 = 2'b00;
    parameter S2 = 2'b01;
    parameter S3 = 2'b10;
    parameter S4 = 2'b11;
        
    wire out;
    assign LEDR[0] = out;
    reg [3:0] M;
	wire [3:0] initialM;
	wire [3:0] nextM;
    wire [10:0] X;
	wire [10:0] shiftQ;
    wire [24:0] C;
	wire cTrack;
    wire [2:0] lC;
    reg counterEn = 1'b0;
    reg shiftL = 1'b0;
    reg shiftEn = 1'b0;
    reg codeCountEn = 1'b0;

    mux_big_8to1 u1 (X, SW);
    mux_4bit_8to1 u2 (initialM, SW);
    shift u3 (X, shiftL, 0, shiftQ, CLOCK_50, shiftEn);
    codeCounter u4 (nextM, codeCountEn);
    counter u5 (CLOCK_50, reset, C, lC, counterEn, cTrack);

    always @ (*)
	begin
    case (y_Q)
        S1:
		begin
		  if (transmit) 
            Y = S1;
        else if (transmit == 0)
            Y = S2;
		end
        S2: 
        begin
	    shiftL = 1'b1;
		 M = initialM;
            Y = S3;
        end
        S3:
        begin
     
	    shiftL = 1'b0;
	    shiftEn = 1'b0;
		 codeCountEn = 1'b0;
            counterEn = 1'b1;
            if (C == 0 && M > 0)
                Y = S4;
            else if (M == 0)
                Y = S1;
            else if (C > 0)
                Y = S3;
        end
        S4: 
        begin
 	    shiftEn = 1'b1;
           codeCountEn = 1'b1;
			  M = nextM;
            Y = S3;
        end
		  default: Y = S1;
    endcase
	end

    always @(posedge CLOCK_50)
    begin: state_FFs
        if (!reset)
        y_Q <= S1;
        else
        y_Q <= Y;
    end // state_FFS
	assign out = (~cTrack & shiftQ[0] & (y_Q == S3));
endmodule

module codeCounter (M, pastM, enable);
	input enable;
	input [3:0] pastM;
	output reg [3:0] M;
	always @ (*)
	begin
		if (enable == 1)
			M = pastM - 1;
		else
			M = M;
	end
endmodule

module mux_big_8to1(V, s);
input [2:0] s;
output reg [10:0] V;
parameter A = 5'b10111, B = 9'b111010101, C = 11'b11101011101, D = 7'b1110101,
        E = 1'b1, F = 9'b101011101, G = 9'b111011101, H = 7'b1010101;
always @ (*)
begin 
    if (s == 3'b000)
        V = A;
    else if (s == 3'b001)
        V = B;
    else if (s == 3'b010)
        V = C;
    else if (s == 3'b011)
        V = D;
    else if (s == 3'b100)
        V = E;
    else if (s == 3'b101)
        V = F;
    else if (s == 3'b110)
        V = G;
    else if (s == 3'b111)
        V = H;
		else
		V = 3'b000;
end
endmodule

module mux_4bit_8to1(V, s);
    input [2:0] s;
    output reg [3:0] V;
    parameter A = 3'b101, B = 4'b1001, C = 4'b1011, D = 3'b111,
        E = 1'b1, F = 4'b1001, G = 4'b1001, H = 3'b111;
    always @ (*)
begin 
    if (s == 3'b000)
        V = A;
    else if (s == 3'b001)
        V = B;
    else if (s == 3'b010)
        V = C;
    else if (s == 3'b011)
        V = D;
    else if (s == 3'b100)
        V = E;
    else if (s == 3'b101)
        V = F;
    else if (s == 3'b110)
        V = G;
    else if (s == 3'b111)
        V = H;
		  else
		V = 3'b000;
end
endmodule

module shift (R, L, W, Q, Clock, enable);
    input [0:10] R;
    input L, W, enable, Clock;
    output reg [0:10] Q;
    always @ (posedge Clock)
    begin
        if (L == 1'b1)
            Q <= R;
        else if (enable == 1)
            begin
                Q[0] <= W;
                Q[1] <= Q[0];
                Q[2] <= Q[1];
                Q[3] <= Q[2];
                Q[4] <= Q[3];
                Q[5] <= Q[4];
                Q[6] <= Q[5];
                Q[7] <= Q[6];
                Q[8] <= Q[7];
                Q[9] <= Q[8];
                Q[10] <= Q[9];
            end
			else
				Q <= Q;
    end
assign led = Q[10];
endmodule


module counter (CLOCK_50, reset, large_count, small_count, enable, finish);
input CLOCK_50, reset, enable;
output reg finish;
   output reg [24:0] large_count;
   output reg [2:0] small_count;
   always @ (posedge CLOCK_50)
   begin
   if (reset == 0)
       begin
       large_count <= 25'b1011111010111100001000000;
       small_count <= 0;
       end
   else if (enable == 1)
       begin
           large_count <= large_count - 1;
           if (large_count == 0)
               small_count <= small_count + 1;
					if (small_count == 3'b111)
						finish = 1'b1;
						else
						finish = 1'b0;
       end
   else
		begin
       large_count <= 25'b1011111010111100001000000;
       small_count <= 0;
       end
   end
endmodule
