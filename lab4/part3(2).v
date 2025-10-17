module part3 (KEY, CLOCK_50, HEX0);
    input      [0:0] KEY;
    input            CLOCK_50;
    output     [6:0] HEX0;

    parameter MAX_COUNT = 50_000_000 - 1;

    reg [25:0] big_cnt;
    reg  [3:0] digit_cnt;

    // Internal register to hold the 7-segment pattern
    reg  [6:0] HEX0_reg;

    // 50 MHz counter → decimal digit incrementer
    always @(posedge CLOCK_50) begin
        if (!KEY[0]) begin
            big_cnt   <= 26'd0;
            digit_cnt <= 4'd0;
        end
        else if (big_cnt == MAX_COUNT) begin
            big_cnt <= 26'd0;
            if (digit_cnt == 4'd9)
                digit_cnt <= 4'd0;
            else
                digit_cnt <= digit_cnt + 4'd1;
        end
        else begin
            big_cnt <= big_cnt + 26'd1;
        end
    end

    // Digit → 7-segment decode, exactly as before, but driving HEX0_reg
    always @(*) begin
             if (digit_cnt == 4'd0) HEX0_reg = 7'b1000000; 
        else if (digit_cnt == 4'd1) HEX0_reg = 7'b1111001; 
        else if (digit_cnt == 4'd2) HEX0_reg = 7'b0100100; 
        else if (digit_cnt == 4'd3) HEX0_reg = 7'b0110000; 
        else if (digit_cnt == 4'd4) HEX0_reg = 7'b0011001; 
        else if (digit_cnt == 4'd5) HEX0_reg = 7'b0010010; 
        else if (digit_cnt == 4'd6) HEX0_reg = 7'b0000010; 
        else if (digit_cnt == 4'd7) HEX0_reg = 7'b1111000; 
        else if (digit_cnt == 4'd8) HEX0_reg = 7'b0000000; 
        else if (digit_cnt == 4'd9) HEX0_reg = 7'b0010000; 
        else                      HEX0_reg = 7'b1111111;
    end

    // Hook internal reg out to the wire port
    assign HEX0 = HEX0_reg;

endmodule
