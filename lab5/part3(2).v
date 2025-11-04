module part3(SW, CLOCK_50, KEY, LEDR);

    input  [2:0] SW;
    input CLOCK_50;
    input  [1:0] KEY;
    output [9:0] LEDR;

    wire reset_n = KEY[0];
    wire start = ~KEY[1];
    wire [2:0] letter = SW;
    
    parameter HALF_SEC_COUNT = 3;
    reg [24:0] half_sec_counter;
    wire half_sec_enable;
    
    always @(posedge CLOCK_50) begin
        if (!reset_n)
            half_sec_counter <= 0;
        else if (half_sec_counter == HALF_SEC_COUNT - 1)
            half_sec_counter <= 0;
        else
            half_sec_counter <= half_sec_counter + 1;
    end
    
    assign half_sec_enable = (half_sec_counter == HALF_SEC_COUNT - 1);
    
    reg [3:0] morse_pattern;
    reg [2:0] morse_length;
    
    always @(*) begin
        case (letter)
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
    
    parameter IDLE     = 3'd0,
              LOAD     = 3'd1,
              SEND_ON  = 3'd2,
              WAIT_OFF = 3'd3,
              SPACE    = 3'd4;
    
    reg [2:0] state;
    reg [3:0] shift_register;
    reg [2:0] symbols_left;
    reg [2:0] time_counter;
    reg led_output;
    
    reg start_prev;
    wire start_pulse;
    
    always @(posedge CLOCK_50) begin
        if (!reset_n)
            start_prev <= 0;
        else
            start_prev <= start;
    end
    
    assign start_pulse = start && !start_prev;
    
    always @(posedge CLOCK_50) begin
        if (!reset_n) begin
            state <= IDLE;
            shift_register <= 4'b0;
            symbols_left <= 3'b0;
            time_counter <= 3'b0;
            led_output <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    led_output <= 1'b0;
                    if (start_pulse) begin
                        state <= LOAD;
                    end
                end
                
                LOAD: begin
                    shift_register <= morse_pattern;
                    symbols_left <= morse_length;
                    if (morse_length > 0) begin
                        state <= SEND_ON;
                        time_counter <= shift_register[3] ? 3'd3 : 3'd1;
                        led_output <= 1'b1;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                
                SEND_ON: begin
                    if (half_sec_enable) begin
                        if (time_counter > 1) begin
                            time_counter <= time_counter - 1;
                        end
                        else begin
                            led_output <= 1'b0;
                            state <= WAIT_OFF;
                            time_counter <= 3'd1;
                        end
                    end
                end
                
                WAIT_OFF: begin
                    if (half_sec_enable) begin
                        if (time_counter > 1) begin
                            time_counter <= time_counter - 1;
                        end
                        else begin
                            symbols_left <= symbols_left - 1;
                            shift_register <= {shift_register[2:0], 1'b0};
                            
                            if (symbols_left > 1) begin
                                state <= SEND_ON;
                                time_counter <= shift_register[2] ? 3'd3 : 3'd1;
                                led_output <= 1'b1;
                            end
                            else begin
                                state <= IDLE;
                            end
                        end
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
    assign LEDR[0] = led_output;
    assign LEDR[9:1] = 9'b0;
    
endmodule
