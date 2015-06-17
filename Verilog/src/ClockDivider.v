module ClockDivider #(DIVIDER = 4)
(
	input reset,
	input inClock,
	output reg outClock
);

	localparam WIDTH = $clog2(DIVIDER);

	reg [WIDTH-1:0] counter;
	
	always @(posedge inClock or posedge reset)
	begin
		if (reset)
		begin
			counter <= 1'b0;
			outClock <= 1'b0;
		end
		
		else
		begin
			if (counter == DIVIDER - 1)
			begin
				counter <= 1'b0;
				outClock <= 1'b1;
			end
			
			else
			begin
				counter <= counter + 1'b1;
				if (counter == (DIVIDER - 1) / 2) outClock <= 1'b0; 
			end
		end
	end

endmodule
