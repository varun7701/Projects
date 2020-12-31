module InvAddRoundKey ( 
	input logic [127:0] in,
	input logic [127:0] key, 
	output logic [127:0] out
	);
	
	always_comb begin
		out = in ^ key;
	end
endmodule 
//logic [127:0] RoundKey;
//always_comb
//begin
//	case (round)
//		4'b0000:
//			RoundKey = key_schedule[127:0];
//		4'b0001:
//			RoundKey = key_schedule[255:128];
//		4'b0010:
//			RoundKey = key_schedule[383:256];
//		4'b0011:
//			RoundKey = key_schedule[511:384];
//		4'b0100:
//			RoundKey = key_schedule[639:512];
//		4'b0101:
//			RoundKey = key_schedule[767:640];
//		4'b0110:
//			RoundKey = key_schedule[895:768];
//		4'b0111:
//			RoundKey = key_schedule[1023:896];
//		4'b1000:
//			RoundKey = key_schedule[1151:1024];
//		4'b1001:
//			RoundKey = key_schedule[1279:1152];
//		4'b1010:
//			RoundKey = key_schedule[1407:1280];
//		default:
//			RoundKey = 128'b0;
//	endcase
//end
//assign out = state ^ RoundKey;
//endmodule