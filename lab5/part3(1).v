module part3(SW, CLOCK_50, KEY, LEDR);
    input  [2:0] SW;
    input CLOCK_50;
    input  [1:0] KEY;
    output [9:0] LEDR;

    wire reset_n = KEY[0];
    wire start_tx = ~KEY[1];

    reg  [1:0] half_cnt;
    wire half_tick = (half_cnt == 2);

    always @(posedge CLOCK_50) begin
        if (!reset_n)
            half_cnt <= 0;
        else if (half_cnt == 2)
            half_cnt <= 0;
        else
            half_cnt <= half_cnt + 1;
    end

    reg [3:0] code_map;
    reg [2:0] code_len;
    always @(*) begin
        case (SW)
            3'b000: begin code_map = 4'b0100; code_len = 3'd2; end
            3'b001: begin code_map = 4'b1000; code_len = 3'd4; end
            3'b010: begin code_map = 4'b1010; code_len = 3'd4; end
            3'b011: begin code_map = 4'b1000; code_len = 3'd3; end
            3'b100: begin code_map = 4'b0000; code_len = 3'd1; end
            3'b101: begin code_map = 4'b0010; code_len = 3'd4; end
            3'b110: begin code_map = 4'b1100; code_len = 3'd3; end
            3'b111: begin code_map = 4'b0000; code_len = 3'd4; end
            default: begin code_map = 4'b0000; code_len = 3'd0; end
        endcase
    end

    parameter IDLE  = 3'd0,
              LOAD  = 3'd1,
              ON    = 3'd2,
              COUNT = 3'd3,
              OFF   = 3'd4;

    reg [2:0] state, next_state;
    reg [3:0] shift_reg;
    reg [2:0] len_cnt;
    reg [2:0] sym_time;
    reg       led;

    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            state     <= IDLE;
            shift_reg <= 4'b0;
            len_cnt   <= 3'b0;
            sym_time  <= 3'b0;
            led       <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    led <= 1'b0;
                end
                LOAD: begin
                    shift_reg <= code_map;
                    len_cnt   <= code_len;
                end
                ON: begin
                    led      <= 1'b1;
                    sym_time <= (shift_reg[3] ? 3'd3 : 3'd1);
                end
                COUNT: begin
                    if (half_tick) begin
                        if (sym_time > 1)
                            sym_time <= sym_time - 1;
                        else
                            led <= 1'b0;
                    end
                end
                OFF: begin
                    if (half_tick) begin
                        shift_reg <= {shift_reg[2:0], 1'b0};
                        len_cnt   <= len_cnt - 1;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE:
                if (start_tx) next_state = LOAD;
            LOAD:
                next_state = (code_len > 0 ? ON : IDLE);
            ON:
                next_state = COUNT;
            COUNT:
                if (half_tick && sym_time == 1)
                    next_state = OFF;
            OFF:
                if (half_tick)
                    next_state = (len_cnt > 1 ? ON : IDLE);
        endcase
    end

    assign LEDR[0]   = led;
    assign LEDR[9:1] = 9'b0;

endmodule