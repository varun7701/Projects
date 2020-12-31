module testbench();


	 logic CLK;
	 logic RESET;
	 logic AES_START;
	 logic AES_DONE;
	 logic [127:0] AES_KEY;
	 logic [127:0] AES_MSG_ENC;
	 logic [127:0] AES_MSG_DEC;	
	 
	 
	 
//AES aes(.*);
AES aes(.CLK(CLK), .RESET(RESET), .AES_START(AES_START), .AES_DONE(AES_DONE), .AES_KEY(AES_KEY), .AES_MSG_ENC(AES_MSG_ENC), .AES_MSG_DEC(AES_MSG_DEC));

always begin : CLOCK_GENERATION
#1 CLK = ~CLK;
end

initial begin: CLOCK_INITIALIZATION
CLK = 0;
end

initial begin: TEST_VECTORS
RESET = 0;
#3 RESET = 1;
#3 RESET = 0;
AES_START = 0;
#11 AES_KEY = 128'h000102030405060708090a0b0c0d0e0f;
#25 AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;


#4 AES_START = 1;
#4 AES_START = 0;
#200;
end
endmodule 