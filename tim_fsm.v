module tim_fsm (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output shift_ena,
    output counting,
    input done_counting,
    output done,
    input ack );
    
    reg start_shifting;
    
    reg [3:0] curr_state, next_state;
    
    parameter IDLE = 0, S1 = 1, S11 = 2, S110 = 3, B0 = 4, B1 = 5, B2 = 6, B3 = 7, COUNT = 8, WAIT = 9;
    
    assign counting = curr_state == COUNT ? 1 : 0;
    
    assign done = curr_state == WAIT ? 1 : 0;
    
    assign shift_ena = curr_state == B0 || curr_state == B1 || curr_state == B2 || curr_state == B3;
     
    //sequence_req u0 (.clk(clk), .reset(reset), .data(data), .start_shifting(start_shifting));
    
    //shift_en u1 (.clk(clk), .reset(start_shifting), .shift_ena(shift_ena));
    
 
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
/*
module sequence_req (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output start_shifting);
    
    parameter IDLE = 0, S1 = 1, S11 = 2, S110 = 3, S1101 = 4;
    
    reg [2:0] curr_state, next_state;
    
    assign start_shifting = curr_state == (S110 && data) ? 1 : 0;
    
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

module shift_en (
    input clk,
    input reset,      // Synchronous reset
    output shift_ena);
    
    reg [2:0] count;
    
    assign shift_ena = count[2] || count[1] || count[0];

    always @ (posedge clk) begin
        if(reset)
            count <= 1;
        else if(count == 4)
            count <= 0;
        else if(count != 0)
            count <= count + 1;
        else
            count <= count;
    end
endmodule
*/
