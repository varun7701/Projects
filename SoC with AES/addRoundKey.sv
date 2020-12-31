module addRoundKey(
							
		input logic [127:0] msg_in,
		input logic [127:0] key,
		output logic [127:0] msg_out
		);
		

always_comb begin
	msg_out = msg_in ^ key;
	end
endmodule
