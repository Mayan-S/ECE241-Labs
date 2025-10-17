// part3.v
module part3 (
    input  [0:0] KEY,        
    input        CLOCK_50,   
    output reg [6:0] HEX0    
);

    parameter MAX_COUNT = 50_000_000 - 1;

    reg [25:0] big_cnt;
    reg [3:0]  digit_cnt;

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

    always @(*) begin
        case (digit_cnt)
            4'd0: HEX0 = 7'b1000000; 
            4'd1: HEX0 = 7'b1111001; 
            4'd2: HEX0 = 7'b0100100; 
            4'd3: HEX0 = 7'b0110000; 
            4'd4: HEX0 = 7'b0011001; 
            4'd5: HEX0 = 7'b0010010; 
            4'd6: HEX0 = 7'b0000010; 
            4'd7: HEX0 = 7'b1111000; 
            4'd8: HEX0 = 7'b0000000; 
            4'd9: HEX0 = 7'b0010000; 
            default: HEX0 = 7'b1111111; 
        endcase
    end

endmodule
