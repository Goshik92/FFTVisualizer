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

module I2CTxLogic
(
	input reset,
	input enable,
	input inClock,
	input [7:0] inData,
	input [1:0] mode, // 0 - start, 1 - byte sending, 2 - stop
	inout sda,
	inout scl,
	output reg ack,
	output reg ready
);

	reg sdaPullDown, sclPullDown;
	reg [3:0] state;
	reg [1:0] bitState;

	assign sda = sdaPullDown ? 1'b0 : 1'bz;
	assign scl = sclPullDown ? 1'b0 : 1'bz;

	always @(posedge reset or posedge inClock)
	begin
		if (reset)
		begin
			ack <= 1'b0;
			state <= 1'b0;
			ready <= 1'b0;
			bitState <= 1'b0;
			sclPullDown <= 1'b0;
			sdaPullDown <= 1'b0;
		end
		
		else
		begin
			case(mode)
				// Start mode
				0: begin 
					case(state)
						0: begin
							sclPullDown <= 1'b0;
							ready <= 1'b0;
						end
						
						1: sdaPullDown <= 1'b1;

						2: begin
							sclPullDown <= 1'b1;
							ready <= 1'b1;
						end
					endcase
					
					if (state == 2'd2) state <= 1'b0;
					else state <= state + 1'b1;
				end
				
				1: begin
					// First cycle
					if (state == 4'd0 && bitState == 2'd0)
					begin
						ready <= 1'b0;
						ack <= 1'b0;
					end
				
					// If we should send bits
					if (state != 4'd8)
					begin
						case(bitState)
							0: sdaPullDown <= ~(inData >> (3'd7 - state));
							1: sclPullDown <= 1'b0;	
							3: begin
								sclPullDown <= 1'b1;
								state <= state + 1'b1;
							end
						endcase
					end
					
					// If we should get ack
					else
					begin
						case(bitState)
							0: sdaPullDown <= 1'b0;
							1: sclPullDown <= 1'b0;
							2: ack <= ~sda;
							3: begin
								sclPullDown <= 1'b1;
								state <= 1'b0;
								ready <= 1'b1;
							end
						endcase
					end
					
					bitState <= bitState + 1'b1;
				end

				// Stop mode
				2: begin
					case(state)
						0: begin
							sdaPullDown <= 1'b1;
							ready <= 1'b0;
						end
						
						1: sclPullDown <= 1'b0;

						2: begin
							sdaPullDown <= 1'b0;
							ready <= 1'b1;
						end
					endcase
					
					if (state == 2'd2) state <= 1'b0;
					else state <= state + 1'b1;
				end
			endcase
		end
	end			
endmodule
