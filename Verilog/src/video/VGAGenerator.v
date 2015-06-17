module VGAGenerator
(
	input reset,
	input inClock,
	output pixelClock,
	output [7:0] rColor,
	output [7:0] gColor,
	output [7:0] bColor,
	output hSync,
	output vSync,
	output blankN,
	output syncN,
	input [2:0] bgColor,
	input vramWriteClock,
	input signed [9:0] vramWriteAddr,
	input signed [9:0] vramInData
);

	localparam Y_OFFSET = 768;

	wire vgaClock, blank;
	wire [23:0] bgFullColor;
	reg [23:0] fullColor;
	wire [9:0] xActivePixel, yActivePixel;
	wire signed [9:0] yActivePixelPos, vramOutData;

	assign bgFullColor = {{8{bgColor[0]}}, {8{bgColor[1]}}, {8{bgColor[2]}}};
	assign {rColor, gColor, bColor} = fullColor;
	assign syncN = 1'b0;
	assign blankN = ~blank;

	VGASyncGenerator vgasg0
	(
		.reset(reset),
		.inClock(pixelClock),
		.vSync(vSync),
		.hSync(hSync),
		.blank(blank),
		.xPixel(xActivePixel),
		.yPixel(yActivePixel)
	);
	
	VGAClockSource vgacs0
	(
		.areset(reset),
		.inclk0(inClock),
		.c0(pixelClock)
	);
	
	VideoRAM vram0
	(
		.data(vramInData),
		.rdaddress(xActivePixel),
		.rdclock(pixelClock),
		.wraddress(vramWriteAddr),
		.wrclock(vramWriteClock),
		.wren(1'b1),
		.q(yActivePixelPos)
	);
	
	always @(posedge pixelClock or posedge reset)
	begin
		if (reset)
		begin
			fullColor <= 1'b0;
		end
	
		else
		begin
			if (Y_OFFSET - yActivePixelPos <= yActivePixel) fullColor <= ~bgFullColor;
			else fullColor <= bgFullColor;
		end
	end

endmodule
