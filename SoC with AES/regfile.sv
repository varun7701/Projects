module msg_register(
				
				input logic CLK,
				input logic [127:0] in,
				input logic load,
				output logic [127:0] out
				
			);
			
			
			
	always_ff @ (posedge CLK) begin
		if(load)
			out <= in;
	end
endmodule 