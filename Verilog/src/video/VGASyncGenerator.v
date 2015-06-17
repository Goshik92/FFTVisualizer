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

// See http://tinyvga.com/vga-timing for VGA parameters
module VGASyncGenerator
(
	reset,
	inClock,
	vSync,
	hSync,
	blank,
	xPixel,
	yPixel
);

	localparam H_IS_NEGATIVE = 1'b1;
	localparam H_VISIBLE_AREA = 1024;
	localparam H_FRONT_PORCH = 24;
	localparam H_SYNC_PULSE = 136;
	localparam H_BACK_PORCH = 144;
	localparam H_TOTAL_PIX = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
	localparam H_VISIBLE_AREA_MIN = H_FRONT_PORCH + H_SYNC_PULSE;
	localparam H_VISIBLE_AREA_MAX = H_VISIBLE_AREA_MIN + H_VISIBLE_AREA;
	localparam H_SIZE = $clog2(H_TOTAL_PIX + 1);
	localparam X_PIXELS_SIZE = $clog2(H_VISIBLE_AREA);

	localparam V_IS_NEGATIVE = 1'b1;
	localparam V_VISIBLE_AREA = 768;                            
	localparam V_FRONT_PORCH = 3;
	localparam V_SYNC_PULSE = 6;
	localparam V_BACK_PORCH = 29;
	localparam V_TOTAL_PIX = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
	localparam V_VISIBLE_AREA_MIN = V_FRONT_PORCH + V_SYNC_PULSE;
	localparam V_VISIBLE_AREA_MAX = V_VISIBLE_AREA_MIN + V_VISIBLE_AREA;
	localparam V_SIZE = $clog2(V_TOTAL_PIX + 1);
	localparam Y_PIXELS_SIZE = $clog2(V_VISIBLE_AREA);
	
	input reset;
	input inClock;
	output vSync;
	output hSync;
	output blank;
	output [X_PIXELS_SIZE-1:0] xPixel;
	output [Y_PIXELS_SIZE-1:0] yPixel;
	
	wire hBlank, vBlank;
	reg [V_SIZE-1:0] vCounter;
	reg [H_SIZE-1:0] hCounter;

	assign vSync = V_IS_NEGATIVE ^ (vCounter < V_SYNC_PULSE);
	assign hSync = H_IS_NEGATIVE ^ (hCounter < H_SYNC_PULSE);
	assign hBlank = (hCounter < H_VISIBLE_AREA_MIN) || (hCounter > H_VISIBLE_AREA_MAX);
	assign vBlank = (vCounter < V_VISIBLE_AREA_MIN) || (vCounter > V_VISIBLE_AREA_MAX);
	assign blank = hBlank || vBlank;
	assign xPixel = hBlank ? 1'b0 : (hCounter - H_VISIBLE_AREA_MIN);
	assign yPixel = vBlank ? 1'b0 : (vCounter - V_VISIBLE_AREA_MIN);
	
	always @(posedge reset or posedge inClock)
	begin
		if (reset)
		begin
			hCounter <= 1'b0;
			vCounter <= 1'b0;
		end
		
		else
		begin
			if (hCounter == H_TOTAL_PIX)
			begin
				if (vCounter == V_TOTAL_PIX) vCounter <= 1'b0;
				else vCounter <= vCounter + 1'b1;
				hCounter <= 1'b0;
			end
			
			else hCounter <= hCounter + 1'b1;
		end
	end

endmodule
