module part2(SW, KEY, LEDR);
	input [1:0] SW;  
    input [0:0] KEY;  
    output [9:0] LEDR;

    wire Clock, reset_n, w;
    wire z;
    
    assign Clock = KEY[0];
    assign reset_n = SW[0];
    assign w = SW[1];
    
    reg [3:0] y_Q, Y_D;
    
    parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, F = 4'b0101, G = 4'b0110, H = 4'b0111, I = 4'b1000;
    
    always @(w, y_Q)
    begin: state_table
        case (y_Q)
            A: begin
                if (!w) 
                    Y_D = B;
                else 
                    Y_D = F;
            end
            
            B: begin
                if (!w) 
                    Y_D = C;
                else 
                    Y_D = F;
            end
            
            C: begin
                if (!w) 
                    Y_D = D;
                else 
                    Y_D = F;
            end
            
            D: begin
                if (!w) 
                    Y_D = E;
                else 
                    Y_D = F;
            end
            
            E: begin
                if (!w) 
                    Y_D = E;  
                else 
                    Y_D = F;
            end
            
            F: begin
                if (!w) 
                    Y_D = B;
                else 
                    Y_D = G;
            end
            
            G: begin
                if (!w) 
                    Y_D = B;
                else 
                    Y_D = H;
            end
            
            H: begin
                if (!w) 
                    Y_D = B;
                else 
                    Y_D = I;
            end
            
            I: begin
                if (!w) 
                    Y_D = B;
                else 
                    Y_D = I; 
            end
            
            default: Y_D = 4'bxxxx;
        endcase
    end
    
    always @(posedge Clock)
    begin: state_FFs
        if (!reset_n)  
            y_Q <= A;
        else
            y_Q <= Y_D;
    end 
    
    assign z = (y_Q == E) | (y_Q == I);  
    
    assign LEDR[9] = z;           
    assign LEDR[3:0] = y_Q;       
    assign LEDR[8:4] = 5'b00000;  
    
endmodule