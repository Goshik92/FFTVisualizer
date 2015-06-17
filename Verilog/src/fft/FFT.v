module FFT #(WORD_SIZE)
(
	input reset,
	input inClock,
	output reg [9:0] sampleNumber,
	input [WORD_SIZE-1:0] inData,
	output [WORD_SIZE-1:0] outData
);

	localparam NUM_POINTS = 4096;
	localparam ADDITIONAL_BITS = 18; // related on exp max value (see FFT docs)
	localparam EXT_WORD_SIZE = ADDITIONAL_BITS + WORD_SIZE;
	localparam GAIN = 12;

	wire signed [WORD_SIZE-1:0] fftOutIm, fftOutRe;
	wire signed [EXT_WORD_SIZE-1:0] fftOutImScaled, fftOutReScaled, extOutData;
	wire sinkSop, sinkEop, sourceSop;
	reg sinkValid, sinkReady;
	wire signed [5:0] exp;
	reg [11:0] dataCounter;
	
	assign sinkSop = (dataCounter == 0);
	assign sinkEop = (dataCounter == NUM_POINTS - 1);
	assign fftOutImScaled = exp[5] ? fftOutIm <<< -exp : fftOutIm >>> exp;
	assign fftOutReScaled = exp[5] ? fftOutRe <<< -exp : fftOutRe >>> exp;
	assign outData = extOutData[EXT_WORD_SIZE-GAIN-1:EXT_WORD_SIZE-GAIN-WORD_SIZE];

	always @(posedge reset or posedge inClock)
	begin
		if (reset)
		begin
			dataCounter <= NUM_POINTS - 1;
			sampleNumber <= 1'b0;
			sinkValid <= 1'b0;
			sinkReady <= 1'b0;
		end
		
		else
		begin
			dataCounter <= dataCounter + 1'b1;
			sinkValid <= 1'b1;
			sinkReady <= 1'b1;
			
			if (sourceSop) sampleNumber <= 1'b0;
			else if (sampleNumber != 10'h3FF) sampleNumber <= sampleNumber + 1'b1;
		end
	end
	
	FFT_mf fftmf0
	(
		.reset_n(~reset),
		.clk(inClock),
		.inverse(1'b0),
		.sink_sop(sinkSop),
		.sink_eop(sinkEop),
		.sink_valid(sinkValid),
		.sink_error(2'b00),
		.sink_real(inData),
		.sink_imag(1'b0),
		.source_exp(exp),
		.source_real(fftOutRe),
		.source_imag(fftOutIm),
		.source_ready(sinkReady),
		.source_sop(sourceSop)
	);

	Magnitude #(.WORD_SIZE(EXT_WORD_SIZE)) m0
	(
		.im(fftOutImScaled),
		.re(fftOutReScaled),
		.mg(extOutData)
	);

endmodule
