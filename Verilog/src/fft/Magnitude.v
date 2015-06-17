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

module Magnitude #(WORD_SIZE)
(
	input signed [WORD_SIZE-1:0] im,
	input signed [WORD_SIZE-1:0] re,
	output [WORD_SIZE-1:0] mg
);
	
	wire [WORD_SIZE-1:0] absRe, absIm, max, min;
	
	assign absRe = re[WORD_SIZE-1] ? -re : re;
	assign absIm = im[WORD_SIZE-1] ? -im : im;
	assign min = absIm < absRe ? absIm : absRe;
	assign max = absIm < absRe ? absRe : absIm;
	assign mg = max + min >> 2; 

endmodule
