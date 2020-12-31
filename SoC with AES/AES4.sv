module AES4 (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
//avalon_aes_interface decrypt(.CLK(CLK), .RESET(RESET), .*);
				
	logic [1407:0] keyschedule;
	logic [127:0] msg, outShift, outAdd, outMix, outSub, reg_mux_out;
	logic [31:0] outMixByte;
	logic [2:0] mux_select;
	logic [3:0] count, count1;
	logic load;
	logic [1:0] mix_mux_select;
	
	assign AES_MSG_DEC = msg;
	
	
	
	enum logic [4:0] {WAIT, INIT, Add1, Add2, Shift, Sub, Mix_1, Mix_2, Mix_3, Mix_4, DONE, Hold1, Hold2, Hold3, Hold4, Hold5} current, next;
	
	
	KeyExpansion myExpansion(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(keyschedule));
	InvAddRoundKey	addRounds(.state(msg), .key_schedule(keyschedule), .round(count), .out(outAdd));
	InvShiftRows 	myShift(.data_in(msg),.data_out(outShift));
	InvSubBytes		invsubBytes_0	(.clk(CLK), .in(msg[7:0]),    .out(outSub[7:0]));
	InvSubBytes		invsubBytes_1	(.clk(CLK), .in(msg[15:8]),   .out(outSub[15:8]));
	InvSubBytes		invsubBytes_2	(.clk(CLK), .in(msg[23:16]),   .out(outSub[23:16]));
	InvSubBytes		invsubBytes_3	(.clk(CLK), .in(msg[31:24]),  .out(outSub[31:24]));
	InvSubBytes		invsubBytes_4	(.clk(CLK), .in(msg[39:32]),  .out(outSub[39:32]));
	InvSubBytes		invsubBytes_5	(.clk(CLK), .in(msg[47:40]),  .out(outSub[47:40]));
	InvSubBytes		invsubBytes_6	(.clk(CLK), .in(msg[55:48]),  .out(outSub[55:48]));
	InvSubBytes		invsubBytes_7	(.clk(CLK), .in(msg[63:56]),  .out(outSub[63:56]));
	InvSubBytes		invsubBytes_8	(.clk(CLK), .in(msg[71:64]),  .out(outSub[71:64]));
	InvSubBytes		invsubBytes_9	(.clk(CLK), .in(msg[79:72]),  .out(outSub[79:72]));
	InvSubBytes		invsubBytes_10	(.clk(CLK), .in(msg[87:80]),  .out(outSub[87:80]));
	InvSubBytes		invsubBytes_11 (.clk(CLK), .in(msg[96:88]),  .out(outSub[96:88]));
	InvSubBytes		invsubBytes_12	(.clk(CLK), .in(msg[103:96]), .out(outSub[103:96]));
	InvSubBytes		invsubBytes_13	(.clk(CLK), .in(msg[111:104]),.out(outSub[111:104]));
	InvSubBytes		invsubBytes_14	(.clk(CLK), .in(msg[119:112]),.out(outSub[119:112]));
	InvSubBytes		invsubBytes_15	(.clk(CLK), .in(msg[127:120]),.out(outSub[127:120]));
	InvMixColumns  myMix(.in(inMix),.out(outMix));
	
	mux32 mux_col(.in0(msg[127:96]), .in1(msg[95:64]), .in2(msg[63:32]), .in3(msg[31:0]), .select(mix_mux_select), .out(inMix));
	mux128 reg_mux(.in0(outShift), .in1(outSub), .in2(outAdd), .in3(outMix), .orig(msg), .select(mux_select), .out(reg_mux_out));
//	msg_register myReg(.CLK(CLK), .in(reg_mux_out), .load(load), .out(AES_MSG_DEC));
	
	//State Machine 
	
		always_ff @ (posedge CLK) begin
			if(RESET) begin
				current <= WAIT;
				count <= 4'b0;
				
			end
			else begin
				current <= next;
				count <= count1;
				if(load) 
					msg <= AES_MSG_ENC;
				else 
					msg <= reg_mux_out;
			end
		end
		
		
	
	//Sequential FSM Logic
		
		always_comb begin
		AES_DONE = 1'b0;
		
			next = current;
			unique case (current)
				
					WAIT : if(AES_START) 
								next = INIT;
					
					INIT : if(AES_START)
								next = Add1;
					
					Add1 : next = Hold1;
					
					Hold1 : next = Shift;
					
					Shift : next = Hold2;
					
					Hold2	: next = Sub;
					
					Sub 	: next = Hold3;
					
					Hold3	: next = Add2;
					
					Add2	: if(count == 4'b1010)
									next = DONE;
								else
									next = Hold4;
									
					Hold4	: next = Mix_1;
									
					Mix_1 : next = Mix_2;
					
					Mix_2	: next = Mix_3;
					
					Mix_3 : next = Mix_4;
					
					Mix_4 : next = Hold5;
					
					Hold5: next = Shift;
					
					DONE 	: if(AES_START)
								next = WAIT;
								
			endcase
			
			
			mux_select = 3'b100;
			count1 = count;
			mix_mux_select = 2'b00;
			load = 1'b0;
			
			
			case(current)
					
					WAIT: count1 = 4'd0;
					
					INIT : ;
					
					Shift : mux_select = 3'b000;
					
					
					Sub 	: mux_select = 3'b001;
					
					Add1	: begin
									mux_select = 3'b010;
									count1 = count + 4'b1;
								end
					
					Add2 	: mux_select = 3'b010;
					
					Mix_1 : mix_mux_select = 2'b00;
					
					Mix_2 : mix_mux_select = 2'b01;
					
					Mix_3 : mix_mux_select = 2'b10;
					
					Mix_4 : mix_mux_select = 2'b11;
					
					DONE 	: AES_DONE = 1'b1;
					
					Hold1, Hold2, Hold3, Hold4, Hold5 : load = 1'b1;
					
					
				endcase
		end
		
		
	endmodule
				
	
	
	
		