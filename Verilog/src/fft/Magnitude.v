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
