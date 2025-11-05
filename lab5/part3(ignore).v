module part3 (SW, KEY, LEDR, CLOCK_50);
    input [2:0] SW;
    input [1:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    
    wire reset_n = KEY[0];
    wire transmit_button = KEY[1];
    
    reg [2:0] y_Q, Y_D;
    parameter IDLE = 3'd0;
    parameter LOAD = 3'd1;
    parameter SEND_DOT = 3'd2;
    parameter SEND_DASH = 3'd3;
    parameter WAIT_OFF = 3'd4;
    
    reg transmit_prev;
    wire transmit_pulse;
    
    always @(posedge CLOCK_50) begin
        if (!reset_n)
            transmit_prev <= 1'b1;
        else
            transmit_prev <= transmit_button;
    end
    
    assign transmit_pulse = transmit_prev & ~transmit_button;
    
    parameter HALF_SEC_COUNT = 25000000;
    
    reg [24:0] half_sec_counter;
    reg counter_enable;
    wire half_sec_tick;
    
    always @(posedge CLOCK_50) begin
        if (!reset_n || !counter_enable)
            half_sec_counter <= 25'd0;
        else if (half_sec_counter == HALF_SEC_COUNT - 1)
            half_sec_counter <= 25'd0;
        else
            half_sec_counter <= half_sec_counter + 1'b1;
    end
    
    assign half_sec_tick = (half_sec_counter == HALF_SEC_COUNT - 1);
    
    reg [3:0] morse_pattern;
    reg [2:0] morse_length;
    
    always @(*) begin
        case (SW)
            3'b000: begin
                morse_pattern = 4'b0100;
                morse_length = 3'd2;
            end
            3'b001: begin
                morse_pattern = 4'b1000;
                morse_length = 3'd4;
            end
            3'b010: begin
                morse_pattern = 4'b1010;
                morse_length = 3'd4;
            end
            3'b011: begin
                morse_pattern = 4'b1000;
                morse_length = 3'd3;
            end
            3'b100: begin
                morse_pattern = 4'b0000;
                morse_length = 3'd1;
            end
            3'b101: begin
                morse_pattern = 4'b0010;
                morse_length = 3'd4;
            end
            3'b110: begin
                morse_pattern = 4'b1100;
                morse_length = 3'd3;
            end
            3'b111: begin
                morse_pattern = 4'b0000;
                morse_length = 3'd4;
            end
            default: begin
                morse_pattern = 4'b0000;
                morse_length = 3'd0;
            end
        endcase
    end
    
    reg [3:0] shift_reg;
    reg [2:0] symbols_remaining;
    reg [1:0] time_count;
    reg led_out;
    
    reg load_shift_reg;
    reg shift_enable;
    reg load_time_count;
    
    always @(*) begin
        Y_D = y_Q;
        counter_enable = 1'b0;
        load_shift_reg = 1'b0;
        shift_enable = 1'b0;
        load_time_count = 1'b0;
        
        case (y_Q)
            IDLE: begin
                if (transmit_pulse) begin
                    Y_D = LOAD;
                end
            end
            
            LOAD: begin
                load_shift_reg = 1'b1;
                if (morse_length > 0) begin
                    load_time_count = 1'b1;
                    if (morse_pattern[3])
                        Y_D = SEND_DASH;
                    else
                        Y_D = SEND_DOT;
                end else begin
                    Y_D = IDLE;
                end
            end
            
            SEND_DOT: begin
                counter_enable = 1'b1;
                if (half_sec_tick && time_count == 2'd1) begin
                    Y_D = WAIT_OFF;
                    load_time_count = 1'b1;
                end
            end
            
            SEND_DASH: begin
                counter_enable = 1'b1;
                if (half_sec_tick && time_count == 2'd1) begin
                    Y_D = WAIT_OFF;
                    load_time_count = 1'b1;
                end
            end
            
            WAIT_OFF: begin
                counter_enable = 1'b1;
                if (half_sec_tick && time_count == 2'd1) begin
                    shift_enable = 1'b1;
                    if (symbols_remaining > 3'd1) begin
                        load_time_count = 1'b1;
                        if (shift_reg[2])
                            Y_D = SEND_DASH;
                        else
                            Y_D = SEND_DOT;
                    end else begin
                        Y_D = IDLE;
                    end
                end
            end
            
            default: Y_D = IDLE;
        endcase
    end
    
    always @(posedge CLOCK_50) begin
        if (!reset_n)
            y_Q <= IDLE;
        else
            y_Q <= Y_D;
    end
    
    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            shift_reg <= 4'b0;
        end else if (load_shift_reg) begin
            shift_reg <= morse_pattern;
        end else if (shift_enable) begin
            shift_reg <= {shift_reg[2:0], 1'b0};
        end
    end
    
    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            symbols_remaining <= 3'd0;
        end else if (load_shift_reg) begin
            symbols_remaining <= morse_length;
        end else if (shift_enable) begin
            symbols_remaining <= symbols_remaining - 1'b1;
        end
    end
    
    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            time_count <= 2'd0;
        end else if (load_time_count) begin
            if (Y_D == SEND_DOT || y_Q == SEND_DOT)
                time_count <= 2'd1;
            else if (Y_D == SEND_DASH || y_Q == SEND_DASH)
                time_count <= 2'd3;
            else
                time_count <= 2'd1;
        end else if (counter_enable && half_sec_tick) begin
            time_count <= time_count - 1'b1;
        end
    end
    
    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            led_out <= 1'b0;
        end else begin
            if (y_Q == SEND_DOT || y_Q == SEND_DASH)
                led_out <= 1'b1;
            else
                led_out <= 1'b0;
        end
    end
    
    assign LEDR[0] = led_out;
    assign LEDR[9:1] = 9'b0;
    
endmodule