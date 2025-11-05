module part3 (SW, CLOCK_50, KEY, LEDR);
	input CLOCK_50;
	input [2:0]SW;
	input [1:0]KEY;
	output [9:0]LEDR;

	wire [3:0] SR_load;
	wire [1:0] Counter_load;
	wire HsecEn;

	HSecCounter halfSecCounter(CLOCK_50, HsecEn, KEY[0]);

	code_mux mux1(SW, SR_load);
	counter_mux mux2(SW, Counter_load);

	wire shiftcountTrigger, loadTrigger;
	wire [3:0] SR_out;
	wire [1:0] counter_out;

	fsm u3(HsecEn, counter_out, SR_out[3], KEY[0], KEY[1], loadTrigger, shiftcountTrigger, LEDR[0], CLOCK_50);

	shiftReg u1(loadTrigger, SR_load, SR_out, shiftcountTrigger, HsecEn, CLOCK_50, KEY[0]);
	slow_counter u2(HsecEn, shiftcountTrigger, Counter_load, loadTrigger, counter_out, CLOCK_50, KEY[0]);
endmodule

module code_mux(letter, loadSR);
	input [2:0]letter;
	output reg [3:0]loadSR;

	always @ (*)
	if (letter == 3'b000)
		loadSR = 4'b0100;
	else if (letter == 3'b001)
		loadSR = 4'b1000;
	else if (letter == 3'b010)
		loadSR = 4'b1010;
	else if (letter == 3'b011)
		loadSR = 4'b1000;
	else if (letter == 3'b100)
		loadSR = 4'b0000;
	else if (letter == 3'b101)
		loadSR = 4'b0010;
	else if (letter == 3'b110)
		loadSR = 4'b1100;
	else if (letter == 3'b111)
		loadSR = 4'b0000;

endmodule

module counter_mux(letter, count);
	input [2:0]letter;
	output reg [1:0]count;

	always @ (*)
	if (letter == 3'b000)
		count = 2'b01;
	else if (letter == 3'b001)
		count = 2'b11;
	else if (letter == 3'b010)
		count = 2'b11;
	else if (letter == 3'b011)
		count = 2'b10;
	else if (letter == 3'b100)
		count = 2'b00;
	else if (letter == 3'b101)
		count = 2'b11;
	else if (letter == 3'b110)
		count = 2'b10;
	else if (letter == 3'b111)
		count = 2'b11;
endmodule

module shiftReg(L, R, Q, shiftTrigger, HsecEn, CLOCK_50, resetn);
	input L, shiftTrigger, HsecEn, CLOCK_50, resetn;
	input [3:0]R;
	output reg [3:0]Q;
	
	always @ (posedge CLOCK_50)
	if (!resetn)
		Q <= 0;
	else if (HsecEn)
		if (L)
			Q <= R;
		else if (shiftTrigger)
			Q <= {Q[2:0], 1'b0};
endmodule

module slow_counter(HsecEn, countTrigger, R, L, Count, CLOCK_50, resetn);
	input HsecEn, countTrigger, L, CLOCK_50, resetn;
	input [1:0]R;
	output reg [1:0]Count;

	always @ (posedge CLOCK_50)
	if (!resetn)
		Count <= 0;
	else if (HsecEn)
		if (L)
			Count <= R;
		else if (countTrigger && (Count != 2'b00))
			Count <= Count - 1; 
endmodule

module fsm(HsecEn, z, b, resetn, initiateTrigger, loadTrigger, shiftcountTrigger, LED, CLOCK_50);
	input HsecEn, b, resetn, initiateTrigger, CLOCK_50;
	input [1:0]z;
	output loadTrigger, shiftcountTrigger, LED;

	wire [2:0]y;
	wire [2:0]Y;

	combA u1 (Y, y, HsecEn, z, b, initiateTrigger);
	flips u2 (HsecEn, y, Y, resetn, CLOCK_50);
	combB u3 (y, loadTrigger, shiftcountTrigger, LED);
endmodule

module combA(Y, y, HsecEn, z, b, initiateTrigger);
	input HsecEn, b, initiateTrigger;
	input [1:0]z;
	input [2:0]y;
	output reg [2:0]Y;

	parameter A = 3'b000, B = 3'b001, Dot = 3'b010, Dash1 = 3'b011, Dash2 = 3'b100, Dash3 = 3'b101, C = 3'b110;

	always @ (*)
	begin
		case(y)
			A: if (~initiateTrigger) Y = B;
			   else if (initiateTrigger) Y = A;
			B: if (HsecEn && !b) Y = Dot;
			   else if (HsecEn && b) Y = Dash1;
			   else if (~HsecEn) Y = B;
			Dot: if (HsecEn) Y = C;
			     else if (~HsecEn) Y = Dot;
			Dash1: if (HsecEn) Y = Dash2;
			       else if (~HsecEn) Y = Dash1;
			Dash2: if (HsecEn) Y = Dash3;
			       else if (~HsecEn) Y = Dash2;
			Dash3: if (HsecEn) Y = C;
			       else if (~HsecEn) Y = Dash3;
			C: if (HsecEn && (z==0)) Y = A;
			   else if (HsecEn && (z!=0)) Y = B;
			   else if (~HsecEn) Y = C;
			default: Y = A;
		endcase
	end
endmodule

module flips(HsecEn, y, Y, resetn, CLOCK_50);
	input [2:0]Y;
	input resetn, HsecEn, CLOCK_50;
	output reg [2:0]y;

	always @ (posedge CLOCK_50)
		if (!resetn)
			y <= 3'b000;
		else if (HsecEn)
			y <= Y;
endmodule

module combB(y, loadTrigger, shiftcountTrigger, LED);
	input [2:0]y;
	output loadTrigger, shiftcountTrigger, LED;

	parameter A = 3'b000, B = 3'b001, Dot = 3'b010, Dash1 = 3'b011, Dash2 = 3'b100, Dash3 = 3'b101, C = 3'b110;

	assign shiftcountTrigger = (y == C);
	assign loadTrigger = (y == A);
	assign LED = (y == Dot) | (y == Dash1) | (y == Dash2) | (y == Dash3);

	//assign shiftcountTrigger = ~y[2]&y[1]&~y[0] | y[2]&~y[1]&y[0];
	//assign loadTrigger = ~y[2]&~y[1]&y[0];
	//assign LED = ~y[2]&y[1] | y[2]&~y[1];
		
endmodule

module HSecCounter(CLOCK_50, HsecEn, resetn);
	input CLOCK_50, resetn;
	output reg HsecEn;
	reg [25:0]HsecCount;

	always @ (posedge CLOCK_50)
	begin
		if (!resetn)
		begin
			HsecCount <= 0;
			HsecEn <= 0;
		end
		else
			if (HsecCount == 24999999)
			begin
				HsecCount <= 0;
				HsecEn <= 1;
			end
			else
			begin
				HsecCount <= HsecCount + 1;
				HsecEn <= 0;
			end
	end

endmodule
