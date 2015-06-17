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

// Yelds data every 64 inClock
module I2SReceiver #(WORD_SIZE = 16)
(
	input reset,
	input codecBitClock,
	input codecLRClock,
	input codecData,
	output reg dataReady,
	output reg [WORD_SIZE-1:0] outDataLeft,
	output reg [WORD_SIZE-1:0] outDataRight
);

	localparam BUFF_SIZE = 32;

	reg oldRLClock;
	reg [BUFF_SIZE-1:0] buffer;
	wire [BUFF_SIZE-1:0] nextBuffer;
	
	assign nextBuffer = {buffer[BUFF_SIZE-2:0], codecData};
	
	always @(posedge reset or posedge codecBitClock)
	begin
		if (reset)
		begin
			outDataLeft <= 1'b0;
			outDataRight <= 1'b0;
			oldRLClock <= codecLRClock;
			dataReady <= 1'b0;
		end
		
		else
		begin
			buffer <= nextBuffer;
			oldRLClock <= codecLRClock;
			
			if (codecLRClock != oldRLClock)
			begin
				if (oldRLClock)
				begin
					outDataLeft <= nextBuffer[BUFF_SIZE-1:BUFF_SIZE-WORD_SIZE-2];
					dataReady <= 1'b0;
				end
				
				else
				begin
					outDataRight <= nextBuffer[BUFF_SIZE-1:BUFF_SIZE-WORD_SIZE-2];
					dataReady <= 1'b1;
				end
			end
		end
	end

endmodule
