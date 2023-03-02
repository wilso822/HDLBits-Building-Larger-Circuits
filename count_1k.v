module count_1k (
    input clk,
    input reset,
    output [9:0] q);
    
    parameter PERIOD = 1000;
    
    always @(posedge clk) begin
        if(reset) begin
            q <= '0;
        end
        else if (q == (PERIOD - 1)) begin
            q <= '0;
        end
        else begin
           q <= q + 1; 
        end
    end

endmodule