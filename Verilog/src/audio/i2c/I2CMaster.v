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

module I2CMaster
(
	input reset,
	input inClock,
	input [23:0] inData,
	inout sda,
	inout scl,
	output reg ack, // It will 1 when all 3 bytes was sent successfully
	output reg ready
);

	reg [1:0] txState, bytesCounter, ackNum;
	reg [7:0] txData;
	wire txReady, txAck;
	
	always @*
	begin
		case(bytesCounter)
			0: txData <= inData[23:16];
			1: txData <= inData[15:8];
			2: txData <= inData[7:0];
			default: txData <= 1'b0;
		endcase
	end
	
	always @(posedge reset or posedge txReady)
	begin
		if (reset)
		begin
			txState <= 1'b0;
			bytesCounter <= 1'b0;
			ready <= 1'b0;
			ackNum <= 1'b0;
			ack <= 1'b0;
		end
		
		else
		begin
			case(txState)
				0: begin
					txState <= 2'd1;
					ready <= 1'b1;
					ackNum <= 1'b0;
				end
				
				1: begin
					if (bytesCounter == 2'd2)
					begin
						bytesCounter <= 1'b0;
						txState <= 2'd2;
					end
					
					else bytesCounter <= bytesCounter + 1'b1;
					ackNum = ackNum + txAck;
					ack <= (ackNum == 2'd3);
				end
				
				2: begin
					txState <= 2'd0;
					ready <= 1'b0;
				end
			endcase
		end
	end
	
	I2CTxLogic txLogic
	(
		.reset(reset),
		.inClock(inClock),
		.inData(txData),
		.mode(txState),
		.sda(sda),
		.scl(scl),
		.ack(txAck),
		.ready(txReady)
	);

endmodule
