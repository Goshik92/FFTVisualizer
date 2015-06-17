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