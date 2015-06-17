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

module FFTVisualisator
(
	input CLOCK_50,
	input AUD_ADCDAT,
	input AUD_ADCLRCK,
	input AUD_BCLK,
	output AUD_XCK,
	inout I2C_SCLK,
	inout I2C_SDAT,
	input [3:0] KEY,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [17:0] SW,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_SYNC_N,
	output VGA_CLK,
	output VGA_HS,
	output VGA_VS
);

	localparam MIC_WORD_SIZE = 16;
	localparam FILTER_WORD_SIZE = 18;

	wire signed [MIC_WORD_SIZE-1:0] micData, leftData, rightData, fftInData;
	wire [FILTER_WORD_SIZE-1:0] filterInData, filterOutData;
	wire [MIC_WORD_SIZE-1:0] fftInDataAbs, fftOutData;
	wire configReady, i2cClock, codecClock, sampleRate, filterClock, reset;
	wire [25:0] LEDS;
	wire [9:0] fftSampleNumber;
	
	assign reset = ~KEY[0];
	assign AUD_XCK = codecClock;
	assign {LEDR, LEDG[7:0]} = LEDS;
	//assign LEDG[8] = configReady;
	assign LEDS = ~(26'h3FF_FFFF << fftInDataAbs[9:5]);
	assign filterInData = $signed(micData);
	assign fftInData = SW[17] ? micData : filterOutData[MIC_WORD_SIZE-1:0];
	assign micData = SW[16] ? leftData : rightData;
	assign fftInDataAbs = (fftInData[MIC_WORD_SIZE-1] ? -fftInData : fftInData);
	
	ClockDivider #(.DIVIDER(500))  cd0(.reset(reset), .inClock(CLOCK_50), .outClock(i2cClock));
	ClockDivider #(.DIVIDER(4))    cd1(.reset(reset), .inClock(CLOCK_50), .outClock(codecClock));
	ClockDivider #(.DIVIDER(256))  cd2(.reset(reset), .inClock(CLOCK_50), .outClock(filterClock));
	ClockDivider #(.DIVIDER(1024)) cd3(.reset(reset), .inClock(CLOCK_50), .outClock(sampleRate));
	
	CodecConfigurator cc0
	(
		.reset(reset),
		.inClock(i2cClock),
		.sda(I2C_SDAT),
		.scl(I2C_SCLK),
		.ready(configReady)
		//.ackNum(LEDS[3:0])
	);
	
	I2SReceiver #(.WORD_SIZE(MIC_WORD_SIZE)) i2sr0 
	(
		.reset(~configReady), // Disable receiver while codec is configuring
		.codecBitClock(AUD_BCLK),
		.codecLRClock(AUD_ADCLRCK),
		.codecData(AUD_ADCDAT),
		.outDataLeft(leftData),
		.outDataRight(rightData)
 	);
	
	IirFilter iirf0
	(
		.reset(~configReady),
		.inClock(filterClock),
		.inData(filterInData),
		.outData(filterOutData)
	);
	
	VGAGenerator vgag0
	(
		.reset(~configReady),
		.inClock(CLOCK_50),
		.pixelClock(VGA_CLK),
		.rColor(VGA_R),
		.gColor(VGA_G),
		.bColor(VGA_B),
		.hSync(VGA_HS),
		.vSync(VGA_VS),
		.blankN(VGA_BLANK_N),
		.syncN(VGA_SYNC_N),
		.bgColor(SW[2:0]),
		.vramWriteClock(sampleRate),
		.vramWriteAddr(fftSampleNumber),
		.vramInData(fftOutData)
	);
	
	FFT #(.WORD_SIZE(MIC_WORD_SIZE)) fft0
	(
		.reset(~configReady),
		.inClock(sampleRate),
		.sampleNumber(fftSampleNumber),
		.inData(fftInData),
		.outData(fftOutData)
	);
	
endmodule
