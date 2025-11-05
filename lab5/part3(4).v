module part3 (SW, KEY, LEDR, CLOCK_50);
  input [2:0] SW;
  input [1:0] KEY;
  input CLOCK_50;
  output [9:0] LEDR;

  wire rst_n = ~KEY[0];
  wire start_tx = ~KEY[1];

  wire [10:0] codeword;
  wire [3:0]  codeLen;
  mux_big_8to1    u_mux_bits   (.V(codeword), .s(SW));
  mux_4bit_8to1   u_mux_length (.V(codeLen),  .s(SW));

  wire tick;
  halfsec_counter u_hsc (
    .clk   (CLOCK_50),
    .reset (!rst_n),
    .tick  (tick)
  );

  wire [10:0] shiftQ;
  reg         load_sr, shift_sr;
  shift_reg #(11) u_sr (
    .clk   (CLOCK_50),
    .reset (!rst_n),
    .load  (load_sr),
    .shift (shift_sr),
    .D     (codeword),
    .Q     (shiftQ)
  );

  reg  [2:0] state, next_state;
  reg  [3:0] rem_len, next_len;
  reg  [1:0] tick_cnt, next_tcnt;
  reg  [1:0] sym_ticks, next_sticks;

  localparam
    S_IDLE  = 3'd0,
    S_LOAD  = 3'd1,
    S_ON    = 3'd2,
    S_OFF   = 3'd3,
    S_SHIFT = 3'd4;

  always @(posedge CLOCK_50 or negedge rst_n) begin
    if (!rst_n) begin
      state    <= S_IDLE;
      rem_len  <= 4'd0;
      tick_cnt <= 2'd0;
      sym_ticks<= 2'd0;
    end else begin
      state    <= next_state;
      rem_len  <= next_len;
      tick_cnt <= next_tcnt;
      sym_ticks<= next_sticks;
    end
  end

  assign LEDR[0]    = (state == S_ON);
  assign LEDR[9:1]  = 9'd0;

  always @(*) begin
    load_sr     = 1'b0;
    shift_sr    = 1'b0;
    next_state = state;
    next_len   = rem_len;
    next_tcnt  = tick_cnt;
    next_sticks= sym_ticks;

    case(state)
      S_IDLE: begin
        if (start_tx) begin
          next_state = S_LOAD;
        end
      end

      S_LOAD: begin
        load_sr    = 1'b1;
        next_len   = codeLen;
        next_state = S_ON;
      end

      S_ON: begin
        if (tick) begin
          next_sticks = shiftQ[0] ? 2'd3 : 2'd1;
          next_tcnt   = 2'd1;
          next_state  = S_OFF;
        end
      end

      S_OFF: begin
        if (tick) begin
          if (tick_cnt + 1 < sym_ticks) begin
            next_tcnt = tick_cnt + 1;
          end else begin
            next_state = S_SHIFT;
          end
        end
      end

      S_SHIFT: begin
        shift_sr   = 1'b1;
        next_len  = rem_len - 1;
        if (rem_len == 1)
          next_state = S_IDLE;
        else
          next_state = S_ON;
      end

    endcase
  end

endmodule

module halfsec_counter (
  input        clk,
  input        reset,
  output       tick
);
  reg [24:0] cnt;
  always @(posedge clk or posedge reset) begin
    if (reset)
      cnt <= 25'd0;
    else if (cnt == 25_000_000-1)
      cnt <= 25'd0;
    else
      cnt <= cnt + 1;
  end
  assign tick = (cnt == 25_000_000-1);
endmodule

module shift_reg #(parameter W=11) (
  input              clk,
  input              reset,
  input              load,
  input              shift,
  input  [W-1:0]     D,
  output reg [W-1:0] Q
);
  always @(posedge clk or posedge reset) begin
    if (reset)
      Q <= {W{1'b0}};
    else if (load)
      Q <= D;
    else if (shift)
      Q <= Q >> 1;
  end
endmodule

module mux_big_8to1 (
  output reg [10:0] V,
  input      [2:0]  s
);
  parameter A = 11'b00000000011;
  parameter B = 11'b00000001000;
  parameter C = 11'b00000101010;
  parameter D = 11'b00000000100;
  parameter E = 11'b00000000001;
  parameter F = 11'b00000010101;
  parameter G = 11'b00000011001;
  parameter H = 11'b00000000000;

  always @(*) begin
    case(s)
      3'd0: V = A;
      3'd1: V = B;
      3'd2: V = C;
      3'd3: V = D;
      3'd4: V = E;
      3'd5: V = F;
      3'd6: V = G;
      3'd7: V = H;
      default: V = 11'd0;
    endcase
  end
endmodule

module mux_4bit_8to1 (
  output reg [3:0] V,
  input      [2:0] s
);
  always @(*) begin
    case(s)
     3'd0: V = 4'd2;
     3'd1: V = 4'd4;
     3'd2: V = 4'd4;
     3'd3: V = 4'd3;
     3'd4: V = 4'd1;
     3'd5: V = 4'd4;
     3'd6: V = 4'd3;
     3'd7: V = 4'd4;
     default: V = 4'd0;
    endcase
  end
endmodule
