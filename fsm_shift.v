module fsm_shift (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output start_shifting);
    
    parameter IDLE = 0, S1 = 1, S11 = 2, S110 = 3, S1101 = 4;
    
    reg [2:0] curr_state, next_state;
    
    assign start_shifting = curr_state == S1101 ? 1 : 0;
    
    always @ (posedge clk) begin
        if (reset)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    always_comb begin
        case(curr_state)
			IDLE: begin
                if (data) next_state = S1;
                else next_state = IDLE;
            end
            S1: begin
                if (data) next_state = S11;
                else next_state = IDLE;
            end
            S11: begin
                if (!data) next_state = S110;
                else next_state = S11;
            end
            S110: begin
                if (data) next_state = S1101;
                else next_state = IDLE;
            end
            S1101: begin
                next_state = curr_state;
            end
        endcase
    end

endmodule
