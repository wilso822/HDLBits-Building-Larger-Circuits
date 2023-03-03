module fancy_timer (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output [3:0] count,
    output counting,
    output done,
    input ack );
    
    reg [9:0] counter;
    wire shift_ena;
    wire count_ena;
    wire done_counting;
    
    seq_fsm u0 (.clk(clk), .reset(reset), .data(data), .shift_ena(shift_ena), .counting(counting), .done_counting(done_counting), .done(done), .ack(ack));
    
    down_shift u1 (.clk(clk), .shift_ena(shift_ena), .count_ena(count_ena), .data(data), .q(count), .done_counting(done_counting));
    
    counter_1k u3 (.clk(clk), .reset(reset), .counting(counting), .q(counter), .count_ena(count_ena)); 

endmodule

module seq_fsm (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output shift_ena,
    output counting,
    input done_counting,
    output done,
    input ack );
       
    reg [3:0] curr_state, next_state;
    
    parameter IDLE = 0, S1 = 1, S11 = 2, S110 = 3, B0 = 4, B1 = 5, B2 = 6, B3 = 7, COUNT = 8, WAIT = 9;
    
    assign counting = curr_state == COUNT ? 1 : 0;
    
    assign done = curr_state == WAIT ? 1 : 0;
    
    assign shift_ena = curr_state == B0 || curr_state == B1 || curr_state == B2 || curr_state == B3;  
 
    always @ (posedge clk) begin
        if (reset)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    always_comb begin
        next_state = IDLE;
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
                if (data) next_state = B0;
                else next_state = IDLE;
            end
            B0: next_state = B1;
            B1: next_state = B2;
            B2: next_state = B3;
            B3: next_state = COUNT;
            COUNT: begin
                if(!done_counting) next_state = COUNT;
                else next_state = WAIT;
            end
            WAIT: begin
                if(!ack) next_state = WAIT;
            end
        endcase
    end

endmodule

module counter_1k (
    input clk,
    input reset,
    input counting,
    output [9:0] q,
	output count_ena);
    
    parameter PERIOD = 1000;
    
    assign count_ena = q == (PERIOD - 1) ? 1 : 0;
    
    always @(posedge clk) begin
        if(reset) begin
            q <= '0;
        end
        else if (q == (PERIOD - 1) && counting) begin
            q <= '0;
        end
        else if (counting) begin
           q <= q + 1; 
        end
        else begin
            q <= q;
        end
    end

endmodule

module down_shift (
    input clk,
    input shift_ena,
    input count_ena,
    input data,
    output [3:0] q,
	output done_counting);
    
    assign done_counting = q == 0 && count_ena;
    
    always @(posedge clk) begin
        if(shift_ena)
            q <= {q[2:0], data}; 
        else if(count_ena)
        	q <= q - 1;
        else
            q <= q;
    end

endmodule
