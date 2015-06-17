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

localparam M = 1;
localparam N = 16;
localparam WORD_SIZE = M + N + 1;
localparam PRODUCT_SIZE = 2 * WORD_SIZE;
localparam ACCUM_SIZE = PRODUCT_SIZE + 1;
localparam ROUNDIG_OFFSET = 1 << (N - 1);

function signed [ACCUM_SIZE-1:0] extend;
	input signed [WORD_SIZE-1:0] x;
	extend = $signed({x, {N{1'b0}}});
endfunction

function signed [WORD_SIZE-1:0] round;
	input signed [ACCUM_SIZE-1:0] x;
	round = (x + ROUNDIG_OFFSET) >>> N;
endfunction