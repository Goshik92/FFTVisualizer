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
