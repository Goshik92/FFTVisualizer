/*
*
* Copyright (c) 2015 Goshik (goshik92@gmail.com)
*
*
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
* 
*/

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
