module fancy_timer (
    input clk,
    input reset,      // Synchronous reset
    input data,
    output [3:0] count,
    output counting,
    output done,
    input ack );
    
    reg [9:0] counter; //used to count the 1k clock cycles.
    wire shift_ena; //raised for 4 clock cycles to shift in the 4 bits from input stream into the shift register of down_shift.
    wire count_ena; //raised by the counter_1k to tell the down_shift that 1k clock cycles have passed.
    wire done_counting; //raised by the down_shift to tell the state machine that counting has ceased.

    //this is the sequential state machine that goes through all the necessary states as outline in the diagram of the readme.
    seq_fsm u0 (.clk(clk), .reset(reset), .data(data), .shift_ena(shift_ena), .counting(counting), .done_counting(done_counting), .done(done), .ack(ack));

    //this down shifter first gets the amount of 1k clock cycles to pass via count, then signals when that amount of cycles has completed.
    down_shift u1 (.clk(clk), .shift_ena(shift_ena), .count_ena(count_ena), .data(data), .q(count), .done_counting(done_counting));

   //this 1k counter simply runs based on the input signal from the seq_fsm
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

    //registers for the current and next states
    reg [3:0] curr_state, next_state;

    //essentially an enum for all the possible states
    parameter IDLE = 0, S1 = 1, S11 = 2, S110 = 3, B0 = 4, B1 = 5, B2 = 6, B3 = 7, COUNT = 8, WAIT = 9;

    //we are considered counting for as long as we are in the count state
    assign counting = curr_state == COUNT ? 1 : 0;

    //we assert that we are done after counting untile we receive an ack
    assign done = curr_state == WAIT ? 1 : 0;

    //this lets us shift in 4 digits as these states always go from one to the next
    assign shift_ena = curr_state == B0 || curr_state == B1 || curr_state == B2 || curr_state == B3;  

    //updates state on the clock
    always @ (posedge clk) begin
        if (reset)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    //checks the correct sequence then goes into shift states(B0-B3), count state, and wait state
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

    //tells the down_shift to count down when the counter rolls over
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

    //tells the fsm that we have finished counting based on the input signal from 1k counter
    assign done_counting = q == 0 && count_ena;

    //simply shifts in next bit or decrements q depending on signals
    always @(posedge clk) begin
        if(shift_ena)
            q <= {q[2:0], data}; 
        else if(count_ena)
        	q <= q - 1;
        else
            q <= q;
    end

endmodule
