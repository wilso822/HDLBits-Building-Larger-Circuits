# HDLBits-Building-Larger-Circuits
This is my version of HDLBits excercise in building larger circuits starting at https://hdlbits.01xz.net/wiki/Exams/review2015_count1k

This is the Mealey Model used for the tim_fsm.v
![tim_fsm diagram white](https://user-images.githubusercontent.com/46980468/222592135-2156b53f-9d86-4011-ad98-300721e0e6e0.png)

fancy_timer.v was the fifth and final excercise and was made according to this:
"We want to create a timer with one input that:

is started when a particular input pattern (1101) is detected,
shifts in 4 more bits to determine the duration to delay,
waits for the counters to finish counting, and
notifies the user and waits for the user to acknowledge the timer.
The serial data is available on the data input pin. When the pattern 1101 is received, the circuit must then shift in the next 4 bits, most-significant-bit first. These 4 bits determine the duration of the timer delay. I'll refer to this as the delay[3:0].

After that, the state machine asserts its counting output to indicate it is counting. The state machine must count for exactly (delay[3:0] + 1) * 1000 clock cycles. e.g., delay=0 means count 1000 cycles, and delay=5 means count 6000 cycles. Also output the current remaining time. This should be equal to delay for 1000 cycles, then delay-1 for 1000 cycles, and so on until it is 0 for 1000 cycles. When the circuit isn't counting, the count[3:0] output is don't-care (whatever value is convenient for you to implement).

At that point, the circuit must assert done to notify the user the timer has timed out, and waits until input ack is 1 before being reset to look for the next occurrence of the start sequence (1101).

The circuit should reset into a state where it begins searching for the input sequence 1101.

Here is an example of the expected inputs and outputs. The 'x' states may be slightly confusing to read. They indicate that the FSM should not care about that particular input signal in that cycle. For example, once the 1101 and delay[3:0] have been read, the circuit no longer looks at the data input until it resumes searching after everything else is done. In this example, the circuit counts for 2000 clock cycles because the delay[3:0] value was 4'b0001. The last few cycles starts another count with delay[3:0] = 4'b1110, which will count for 15000 cycles."
