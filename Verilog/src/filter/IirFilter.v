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

module IirFilter
(
	reset,
	inClock,
	inData,
	outData
);

	`include "FixedPoint.v"
	
	input reset, inClock;
	input signed [WORD_SIZE-1:0] inData;
	output signed [WORD_SIZE-1:0] outData;
	
	wire signed [ACCUM_SIZE-1:0] tmpData[5];
	assign outData = round(tmpData[4] <<< 0);
	assign tmpData[0] = extend(inData);
	
	SecondOrderSection
	#(
		.LOG2_GAIN(5),
		.A0(18'h2085b),
		.A1(18'h0f993),
		.B1(18'h20466),
		.B2_SIGN(0)
	)
	sos0 
	(
		.reset(reset),
		.inClock(inClock),
		.inData(tmpData[0]),
		.outData(tmpData[1])
	);
	
	SecondOrderSection
	#(
		.LOG2_GAIN(2),
		.A0(18'h21677),
		.A1(18'h0ebae),
		.B1(18'h2061d),
		.B2_SIGN(0)
	)
	sos1 
	(
		.reset(reset),
		.inClock(inClock),
		.inData(tmpData[1]),
		.outData(tmpData[2])
	);
	
	SecondOrderSection
	#(
		.LOG2_GAIN(1),
		.A0(18'h22761),
		.A1(18'h0db37),
		.B1(18'h20d97),
		.B2_SIGN(0)
	)
	sos2
	(
		.reset(reset),
		.inClock(inClock),
		.inData(tmpData[2]),
		.outData(tmpData[3])
	);
	
	SecondOrderSection
	#(
		.LOG2_GAIN(2),
		.A0(18'h2363c),
		.A1(18'h0ccd3),
		.B1(18'h264b3),
		.B2_SIGN(0)
	)
	sos3
	(
		.reset(reset),
		.inClock(inClock),
		.inData(tmpData[3]),
		.outData(tmpData[4])
	);

endmodule
