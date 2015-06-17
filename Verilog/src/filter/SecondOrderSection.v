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

module SecondOrderSection #(LOG2_GAIN, A0, A1, B1, B2_SIGN)
(
	reset,
	inClock,
	inData,
	outData
);

	`include "FixedPoint.v"
	
	input reset, inClock;
	input signed [ACCUM_SIZE-1:0] inData;
	output reg signed [ACCUM_SIZE-1:0] outData;

	reg [1:0] clockCounter;
	reg signed [ACCUM_SIZE-1:0] accumulator;
	reg signed [WORD_SIZE-1:0] delaySection[2];
	wire signed [WORD_SIZE-1:0] delaySection1 = B2_SIGN ? -delaySection[1] : delaySection[1];
	wire signed [WORD_SIZE-1:0] shortAccumulator = round(accumulator);
	
	// Multiplier
	reg signed [WORD_SIZE-1:0] factorA, factorB;
	wire signed [PRODUCT_SIZE-1:0] shortProduct;
	wire signed [ACCUM_SIZE-1:0] product = $signed(shortProduct);
	IirMultiplier im0(.dataa(factorA), .datab(factorB), .result(shortProduct));

	always @(posedge inClock or posedge reset)
	begin	
		if (reset)
		begin
			accumulator <= 1'b0;
			clockCounter <= 1'b0;
			outData <= 1'b0;
			delaySection[0] <= 1'b0;
			delaySection[1] <= 1'b0;
		end
		
		else
		begin
			// Choose action
			case(clockCounter)
				0: begin
					accumulator <= inData >>> LOG2_GAIN;
					factorA <= delaySection[0];
					factorB <= A0;
				end
				
				1: begin
					accumulator <= accumulator - product;
					factorA <= delaySection[1];
					factorB <= A1;
				end
				
				2: begin
					accumulator <= accumulator - product;
					factorA <= delaySection[0];
					factorB <= B1;
				end
				
				3: begin
					delaySection[0] <= shortAccumulator;
					delaySection[1] <= delaySection[0];
					outData <= accumulator + product + extend(delaySection1);		
				end
			endcase
			
			clockCounter <= clockCounter + 1'b1;
		end
	end
	
endmodule
