/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC
);
//avalon_aes_interface decrypt(.CLK(CLK), .RESET(RESET), .*);
				
	logic [7:0] inSub, outSub;
	logic [31:0] inMix, outMix;
	logic [127:0] key, msg, inShift, outShift, inAdd, outAdd;
	logic [1407:0] keyschedule;
	logic [127:0] tempmsg;


enum logic [7:0] {WAIT, INIT, KE_1, ARK_0,
				   ISR_1, ISB_1_1, ISB_1_2, ISB_1_3, ISB_1_4, ISB_1_5, ISB_1_6, ISB_1_7, ISB_1_8, ISB_1_9, ISB_1_10, ISB_1_11, ISB_1_12, ISB_1_13, ISB_1_14, ISB_1_15, ISB_1_16,
					ARK_1, IMC_1_1, IMC_1_2, IMC_1_3, IMC_1_4, ISR_2, ISB_2_1, ISB_2_2, ISB_2_3, ISB_2_4, ISB_2_5, ISB_2_6, ISB_2_7, ISB_2_8, ISB_2_9, ISB_2_10, ISB_2_11, ISB_2_12, ISB_2_13, ISB_2_14, ISB_2_15, ISB_2_16,
					ARK_2,IMC_2_1, IMC_2_2, IMC_2_3, IMC_2_4, ISR_3, ISB_3_1, ISB_3_2, ISB_3_3, ISB_3_4, ISB_3_5, ISB_3_6, ISB_3_7, ISB_3_8, ISB_3_9, ISB_3_10, ISB_3_11, ISB_3_12, ISB_3_13, ISB_3_14, ISB_3_15, ISB_3_16,
					ARK_3, IMC_3_1, IMC_3_2, IMC_3_3, IMC_3_4, IMC_3_5,
					  ISR_4, ISB_4_1, ISB_4_2, ISB_4_3, ISB_4_4, ISB_4_5, ISB_4_6, ISB_4_7, ISB_4_8, ISB_4_9, ISB_4_10, ISB_4_11, ISB_4_12, ISB_4_13, ISB_4_14, ISB_4_15, ISB_4_16, 
					  ARK_4, IMC_4_1, IMC_4_2, IMC_4_3, IMC_4_4,
					  ISR_5, ISB_5_1, ISB_5_2, ISB_5_3, ISB_5_4, ISB_5_5, ISB_5_6, ISB_5_7, ISB_5_8, ISB_5_9, ISB_5_10, ISB_5_11, ISB_5_12, ISB_5_13, ISB_5_14, ISB_5_15, ISB_5_16,
					  ARK_5, IMC_5_1, IMC_5_2, IMC_5_3, IMC_5_4,
					  ISR_6, ISB_6_1, ISB_6_2, ISB_6_3, ISB_6_4, ISB_6_5, ISB_6_6, ISB_6_7, ISB_6_8, ISB_6_9, ISB_6_10, ISB_6_11, ISB_6_12, ISB_6_13, ISB_6_14, ISB_6_15, ISB_6_16,
					  ARK_6, IMC_6_1, IMC_6_2, IMC_6_3, IMC_6_4,
					  ISR_7, ISB_7_1, ISB_7_2, ISB_7_3, ISB_7_4, ISB_7_5, ISB_7_6, ISB_7_7, ISB_7_8, ISB_7_9, ISB_7_10, ISB_7_11, ISB_7_12, ISB_7_13, ISB_7_14, ISB_7_15, ISB_7_16,
					  ARK_7, IMC_7_1, IMC_7_2, IMC_7_3, IMC_7_4, 
					  ISR_8, ISB_8_1, ISB_8_2, ISB_8_3, ISB_8_4, ISB_8_5, ISB_8_6, ISB_8_7, ISB_8_8, ISB_8_9, ISB_8_10, ISB_8_11, ISB_8_12, ISB_8_13, ISB_8_14, ISB_8_15, ISB_8_16,
					  ARK_8, IMC_8_1, IMC_8_2, IMC_8_3, IMC_8_4, 
					  ISR_9, ISB_9_1, ISB_9_2, ISB_9_3, ISB_9_4, ISB_9_5, ISB_9_6, ISB_9_7, ISB_9_8, ISB_9_9, ISB_9_10, ISB_9_11, ISB_9_12, ISB_9_13, ISB_9_14, ISB_9_15, ISB_9_16,
					  ARK_9, IMC_9_1, IMC_9_2, IMC_9_3, IMC_9_4, ISR_10, ISB_10_1, ISB_10_2, ISB_10_3, ISB_10_4, ISB_10_5, ISB_10_6, ISB_10_7, ISB_10_8, ISB_10_9, ISB_10_10, ISB_10_11, ISB_10_12, ISB_10_13, ISB_10_14, ISB_10_15, ISB_10_16,
					  ARK_10, DONE1, DONE2} current, next;
					  
//Wait : if(AES_START == 1)
//			current = INIT;

	




		KeyExpansion keyExp(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule(keyschedule));
		InvShiftRows invshiftrows(.data_in(inShift),.data_out(outShift));
		InvSubBytes  invsubbytes(.clk(CLK),.in(inSub),.out(outSub));
		InvMixColumns invmixcols(.in(inMix),.out(outMix));
		InvAddRoundKey		addRounds(.in(inAdd), .key(key), .out(outAdd));
		

always_ff @ (posedge CLK)
begin
	if(RESET)
		current <= WAIT;
	else
		current <= next;
end

	
always_comb
begin
	key = 128'b0;
	msg = 128'b0;
	inShift = 128'b0;
	inSub = 128'b0;
	inMix = 128'b0;
	inAdd = 128'b0;
	AES_DONE = 1'b0;
   AES_MSG_DEC = 1'b0;
	// AES_START = 1'b0;
	next = current;	
   unique case (current) 
			WAIT   	  : if(AES_START) 
									next = INIT;
			INIT       : next = ARK_0;
			//KE_1    	  : next = ARK_0   ;
			ARK_0   	  : next = ISR_1   ;
		   ISR_1   	  : next = ISB_1_1   ;
			ISB_1_1    : next = ISB_1_2   ;
			ISB_1_2    : next = ISB_1_3   ;
			ISB_1_3    : next = ISB_1_4   ;
			ISB_1_4    : next = ISB_1_5   ;
			ISB_1_5    : next = ISB_1_6   ;
			ISB_1_6    : next = ISB_1_7   ;
			ISB_1_7    : next = ISB_1_8   ;
			ISB_1_8    : next = ISB_1_9   ;
			ISB_1_9    : next = ISB_1_10   ;
			ISB_1_10   : next = ISB_1_11  ;
			ISB_1_11   : next = ISB_1_12  ;
			ISB_1_12   : next = ISB_1_13  ;
			ISB_1_13   : next = ISB_1_14  ;
			ISB_1_14   : next = ISB_1_15  ;
			ISB_1_15   : next = ISB_1_16  ;
			ISB_1_16   : next = ARK_1   ;
		
			ARK_1  	  : next = IMC_1_1 ;
			IMC_1_1	  : next = IMC_1_2 ;
			IMC_1_2	  : next = IMC_1_3 ;
			IMC_1_3	  : next = IMC_1_4 ;
			IMC_1_4	  : next = ISR_2 ;
			//IMC_1_5	  : next = ISR_2   ;
			ISR_2  	  : next = ISB_2_1   ;
			ISB_2_1    : next = ISB_2_2   ;
			ISB_2_2    : next = ISB_2_3   ;
			ISB_2_3    : next = ISB_2_4   ;
			ISB_2_4    : next = ISB_2_5   ;
			ISB_2_5    : next = ISB_2_6   ;
			ISB_2_6    : next = ISB_2_7   ;
			ISB_2_7    : next = ISB_2_8   ;
			ISB_2_8    : next = ISB_2_9   ;
			ISB_2_9    : next = ISB_2_10   ;
			ISB_2_10   : next = ISB_2_11  ;
			ISB_2_11   : next = ISB_2_12  ;
			ISB_2_12   : next = ISB_2_13  ;
			ISB_2_13   : next = ISB_2_14  ;
			ISB_2_14   : next = ISB_2_15  ;
			ISB_2_15   : next = ISB_2_16  ;
			ISB_2_16   : next = ARK_2   ;
			ARK_2  	  : next = IMC_2_1 ;
			IMC_2_1	  : next = IMC_2_2 ;
			IMC_2_2	  : next = IMC_2_3 ;
			IMC_2_3	  : next = IMC_2_4 ;
			IMC_2_4	  : next = ISR_3 ;
		//	IMC_2_5	  : next = ISR_3   ;
			ISR_3  	  : next = ISB_3_1   ;
			ISB_3_1    : next = ISB_3_2   ;
			ISB_3_2    : next = ISB_3_3   ;
			ISB_3_3    : next = ISB_3_4   ;
			ISB_3_4    : next = ISB_3_5   ;
			ISB_3_5    : next = ISB_3_6   ;
			ISB_3_6    : next = ISB_3_7   ;
			ISB_3_7    : next = ISB_3_8   ;
			ISB_3_8    : next = ISB_3_9   ;
			ISB_3_9    : next = ISB_3_10   ;
			ISB_3_10   : next = ISB_3_11  ;
			ISB_3_11   : next = ISB_3_12  ;
			ISB_3_12   : next = ISB_3_13  ;
			ISB_3_13   : next = ISB_3_14  ;
			ISB_3_14   : next = ISB_3_15  ;
			ISB_3_15   : next = ISB_3_16  ;
			ISB_3_16   : next = ARK_3   ;
			ARK_3   : next = IMC_3_1 ;
			IMC_3_1 : next = IMC_3_2 ;
			IMC_3_2 : next = IMC_3_3 ;
			IMC_3_3 : next = IMC_3_4 ;
			IMC_3_4 : next = ISR_4 ;
		//	IMC_3_5 : next = ISR_4   ;
			ISR_4   : next = ISB_4_1   ;
			ISB_4_1   :  next = ISB_4_2   ;
			ISB_4_2    : next = ISB_4_3   ;
			ISB_4_3    : next = ISB_4_4   ;
			ISB_4_4    : next = ISB_4_5   ;
			ISB_4_5    : next = ISB_4_6   ;
			ISB_4_6    : next = ISB_4_7   ;
			ISB_4_7    : next = ISB_4_8   ;
			ISB_4_8    : next = ISB_4_9   ;
			ISB_4_9    : next = ISB_4_10   ;
			ISB_4_10   : next = ISB_4_11  ;
			ISB_4_11   : next = ISB_4_12  ;
			ISB_4_12   : next = ISB_4_13  ;
			ISB_4_13   : next = ISB_4_14  ;
			ISB_4_14   : next = ISB_4_15  ;
			ISB_4_15   : next = ISB_4_16  ;
			ISB_4_16   : next = ARK_4   ;
			ARK_4   : next = IMC_4_1 ;
			IMC_4_1 : next = IMC_4_2 ;
			IMC_4_2 : next = IMC_4_3 ;
			IMC_4_3 : next = IMC_4_4 ;
			IMC_4_4 : next = ISR_5 ;
		//	IMC_4_5 : next = ISR_5   ;
			ISR_5   : next = ISB_5_1   ;
			ISB_5_1   :  next = ISB_5_2   ;
			ISB_5_2    : next = ISB_5_3   ;
			ISB_5_3    : next = ISB_5_4   ;
			ISB_5_4    : next = ISB_5_5   ;
			ISB_5_5    : next = ISB_5_6   ;
			ISB_5_6    : next = ISB_5_7   ;
			ISB_5_7    : next = ISB_5_8   ;
			ISB_5_8    : next = ISB_5_9   ;
			ISB_5_9    : next = ISB_5_10   ;
			ISB_5_10   : next = ISB_5_11  ;
			ISB_5_11   : next = ISB_5_12  ;
			ISB_5_12   : next = ISB_5_13  ;
			ISB_5_13   : next = ISB_5_14  ;
			ISB_5_14   : next = ISB_5_15  ;
			ISB_5_15   : next = ISB_5_16  ;
			ISB_5_16   : next = ARK_5   ;
			ARK_5      : next = IMC_5_1 ;
		   IMC_5_1    : next = IMC_5_2 ;
			IMC_5_2    : next = IMC_5_3 ;
			IMC_5_3    : next = IMC_5_4 ;
			IMC_5_4    : next = ISR_6 ;
		//	IMC_5_5    : next = ISR_6   ;
			ISR_6      : next = ISB_6_1   ;
			ISB_6_1    : next = ISB_6_2   ;
			ISB_6_2    : next = ISB_6_3   ;
			ISB_6_3    : next = ISB_6_4   ;
			ISB_6_4    : next = ISB_6_5   ;
			ISB_6_5    : next = ISB_6_6   ;
			ISB_6_6    : next = ISB_6_7   ;
			ISB_6_7    : next = ISB_6_8   ;
			ISB_6_8    : next = ISB_6_9   ;
			ISB_6_9    : next = ISB_6_10   ;
			ISB_6_10   : next = ISB_6_11  ;
			ISB_6_11   : next = ISB_6_12  ;
			ISB_6_12   : next = ISB_6_13  ;
			ISB_6_13   : next = ISB_6_14  ;
			ISB_6_14   : next = ISB_6_15  ;
			ISB_6_15   : next = ISB_6_16  ;
			ISB_6_16   : next = ARK_6   ;
			ARK_6      : next = IMC_6_1 ;
			IMC_6_1    : next = IMC_6_2 ;
			IMC_6_2    : next = IMC_6_3 ;
			IMC_6_3    : next = IMC_6_4 ;
			IMC_6_4    : next = ISR_7 ;
		//	IMC_6_5    : next = ISR_7   ;
			ISR_7      : next = ISB_7_1   ;
			ISB_7_1    : next = ISB_7_2   ;
			ISB_7_2    : next = ISB_7_3   ;
			ISB_7_3    : next = ISB_7_4   ;
			ISB_7_4    : next = ISB_7_5   ;
			ISB_7_5    : next = ISB_7_6   ;
			ISB_7_6    : next = ISB_7_7   ;
			ISB_7_7    : next = ISB_7_8   ;
			ISB_7_8    : next = ISB_7_9   ;
			ISB_7_9    : next = ISB_7_10   ;
			ISB_7_10   : next = ISB_7_11  ;
			ISB_7_11   : next = ISB_7_12  ;
			ISB_7_12   : next = ISB_7_13  ;
			ISB_7_13   : next = ISB_7_14  ;
			ISB_7_14   : next = ISB_7_15  ;
			ISB_7_15   : next = ISB_7_16  ;
			ISB_7_16   : next = ARK_7   ;
			ARK_7      : next = IMC_7_1 ;
			IMC_7_1    : next = IMC_7_2 ;
			IMC_7_2    : next = IMC_7_3 ;
			IMC_7_3    : next = IMC_7_4 ;
			IMC_7_4    : next = ISR_8 ;
		//	IMC_7_5    : next = ISR_8   ;
			ISR_8      : next = ISB_8_1   ;
			ISB_8_1    : next = ISB_8_2   ;
			ISB_8_2    : next = ISB_8_3   ;
			ISB_8_3    : next = ISB_8_4   ;
			ISB_8_4    : next = ISB_8_5   ;
			ISB_8_5    : next = ISB_8_6   ;
			ISB_8_6    : next = ISB_8_7   ;
			ISB_8_7    : next = ISB_8_8   ;
			ISB_8_8    : next = ISB_8_9   ;
			ISB_8_9    : next = ISB_8_10  ;
			ISB_8_10   : next = ISB_8_11  ;
			ISB_8_11   : next = ISB_8_12  ;
			ISB_8_12   : next = ISB_8_13  ;
			ISB_8_13   : next = ISB_8_14  ;
			ISB_8_14   : next = ISB_8_15  ;
			ISB_8_15   : next = ISB_8_16  ;
			ISB_8_16   : next = ARK_8     ;
			ARK_8      : next = IMC_8_1   ;
			IMC_8_1    : next = IMC_8_2   ;
			IMC_8_2    : next = IMC_8_3   ;
			IMC_8_3    : next = IMC_8_4   ;
			IMC_8_4    : next = ISR_9   ;
	//		IMC_8_5    : next = ISR_9     ;
			ISR_9      : next = ISB_9_1   ;
			ISB_9_1    : next = ISB_9_2   ;
			ISB_9_2    : next = ISB_9_3   ;
			ISB_9_3    : next = ISB_9_4   ;
			ISB_9_4    : next = ISB_9_5   ;
			ISB_9_5    : next = ISB_9_6   ;
			ISB_9_6    : next = ISB_9_7   ;
			ISB_9_7    : next = ISB_9_8   ;
			ISB_9_8    : next = ISB_9_9   ;
			ISB_9_9    : next = ISB_9_10   ;
			ISB_9_10   : next = ISB_9_11  ;
			ISB_9_11   : next = ISB_9_12  ;
			ISB_9_12   : next = ISB_9_13  ;
			ISB_9_13   : next = ISB_9_14  ;
			ISB_9_14   : next = ISB_9_15  ;
			ISB_9_15   : next = ISB_9_16  ;
			ISB_9_16   : next = ARK_9   ;
			ARK_9   : next = IMC_9_1 ;
			IMC_9_1 : next = IMC_9_2 ;
			IMC_9_2 : next = IMC_9_3 ;
			IMC_9_3 : next = IMC_9_4 ;
			IMC_9_4 : next = ISR_10 ;
	//		IMC_9_5 : next = ISR_10  ;
			ISR_10  : next = ISB_10_1  ;
			ISB_10_1   :  next = ISB_10_2   ;
			ISB_10_2    : next = ISB_10_3   ;
			ISB_10_3    : next = ISB_10_4   ;
			ISB_10_4    : next = ISB_10_5   ;
			ISB_10_5    : next = ISB_10_6   ;
			ISB_10_6    : next = ISB_10_7   ;
			ISB_10_7    : next = ISB_10_8   ;
			ISB_10_8    : next = ISB_10_9   ;
			ISB_10_9    : next = ISB_10_10  ;
			ISB_10_10   : next = ISB_10_11  ;
			ISB_10_11   : next = ISB_10_12  ;
			ISB_10_12   : next = ISB_10_13  ;
			ISB_10_13   : next = ISB_10_14  ;
			ISB_10_14   : next = ISB_10_15  ;
			ISB_10_15   : next = ISB_10_16  ;
			ISB_10_16   : next = ARK_10     ;
			ARK_10  		: next =  DONE1     ;
			DONE1 		: next = DONE2			;
			DONE2			: if(!AES_START)
									next = WAIT;
									
									
	endcase
	
	
	case(current)
		WAIT : begin
					AES_DONE = 1'b0;
				 end
				 
		INIT : begin
					key = keyschedule[127:0];
					end
		
	//KE_1 : begin 
	//			key = keyschedule[1407:1280];
	//			msg = AES_MSG_ENC ^ key;
	//		 end
				 
		ARK_0 : begin
					key = keyschedule[127:0];
					msg = AES_MSG_ENC ^ key;
					//tempmsg = msg;
					//inAdd = msg;
					//msg = outAdd;
				  end
		ISR_1   	: begin
						//msg = tempmsg;
						inShift = msg;
						msg = outShift;
					  end
						
		ISB_1_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
						
		ISB_1_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
						
		ISB_1_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
		ISB_1_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
		ISB_1_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
		ISB_1_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_1_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_1_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_1_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_1_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_1_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_1_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_1_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_1_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_1_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_1_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
      ARK_1  	: begin
						key = keyschedule[255:128];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_1_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_1_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_1_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_1_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end
    //  IMC_1_5	: begin
//						inMix = msg[31:0];
//						msg[31:0] = outMix;
	//					end
     
		ISR_2  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_2_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_2_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_2_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_2_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_2_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_2_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_2_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_2_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_2_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_2_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_2_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_2_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_2_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_2_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_2_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_2_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_2  	: begin
						key = keyschedule[383:256];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_2_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_2_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_2_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_2_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end				
						
		
		
		ISR_3  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_3_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_3_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_3_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_3_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_3_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_3_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_3_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_3_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_3_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_3_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_3_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_3_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_3_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_3_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_3_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_3_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_3  	: begin
						key = keyschedule[511:384];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_3_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_3_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_3_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_3_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end	
			


		ISR_4  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_4_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_4_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_4_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_4_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_4_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_4_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_4_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_4_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_4_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_4_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_4_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_4_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_4_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_4_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_4_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_4_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_4  	: begin
						key = keyschedule[639:512];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_4_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_4_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_4_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_4_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end				
						
						
						
		ISR_5  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_5_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_5_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_5_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_5_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_5_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_5_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_5_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_5_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_5_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_5_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_5_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_5_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_5_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_5_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_5_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_5_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_5  	: begin
						key = keyschedule[767:640];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_5_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_5_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_5_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_5_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end			
					
				
			
		
		ISR_6  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_6_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_6_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_6_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_6_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_6_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_6_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_6_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_6_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_6_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_6_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_6_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_6_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_6_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_6_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_6_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_6_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_6  	: begin
						key = keyschedule[895:768];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_6_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_6_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_6_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_6_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end		
				
		
		ISR_7  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_7_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_7_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_7_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_7_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_7_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_7_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_7_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_7_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_7_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_7_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_7_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_7_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_7_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_7_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_7_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_7_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_7  	: begin
						key = keyschedule[1023:896];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_7_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_7_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_7_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_7_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end				
						
		ISR_8  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_8_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_8_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_8_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_8_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_8_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_8_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_8_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_8_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_8_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_8_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_8_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_8_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_8_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_8_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_8_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_8_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_8  	: begin
						key = keyschedule[1151:1024];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_8_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_8_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_8_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_8_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end	
			

		ISR_9  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_9_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_9_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_9_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_9_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_9_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_9_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_9_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_9_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_9_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_9_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_9_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_9_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_9_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_9_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_9_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_9_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_9  	: begin
						key = keyschedule[1279:1152];
						inAdd = msg;
						msg = outAdd;
					  end
      IMC_9_1	: begin
						inMix = msg[31:0];
						msg[31:0] = outMix;
						end
      IMC_9_2	: begin
						inMix = msg[63:32];
						msg[63:32] = outMix;
						end
      IMC_9_3	: begin
						inMix = msg[95:64];
						msg[95:64] = outMix;
						end
      IMC_9_4	: begin
						inMix = msg[127:96];
						msg[127:96] = outMix;
						end				
						
						
						
		ISR_10  	: begin
						inShift = msg;
						msg = outShift;
						end
						
      ISB_10_1  : begin
						inSub = msg[7:0];
						msg[7:0] = outSub;
						end
      ISB_10_2  : begin
						inSub = msg[15:8];
						msg[15:8] = outSub;
						end
      ISB_10_3  : begin
						inSub = msg[23:16];
						msg[23:16] = outSub;
						end
      ISB_10_4  : begin
						inSub = msg[31:24];
						msg[31:24] = outSub;
						end
      ISB_10_5  : begin	
						inSub = msg[39:32];
						msg[39:32] = outSub;
						end
						
		ISB_10_6  : begin	
						inSub = msg[47:40];
						msg[47:40] = outSub;
						end
	   ISB_10_7  : begin
						inSub = msg[55:48];
						msg[55:48] = outSub;
						end
	   ISB_10_8  : begin
						inSub = msg[63:56];
						msg[63:56] = outSub;
						end
		ISB_10_9  : begin
						inSub = msg[71:64];
						msg[71:64] = outSub;
						end
      ISB_10_10 : begin
						inSub = msg[79:72];
						msg[79:72] = outSub;
						end
      ISB_10_11 : begin
						inSub = msg[87:80];
						msg[87:80] = outSub;
						end
      ISB_10_12 : begin
						inSub = msg[95:88];
						msg[95:88] = outSub;
						end
      ISB_10_13 : begin
						inSub = msg[103:96];
						msg[103:96] = outSub;
						end
      ISB_10_14 : begin
						inSub = msg[111:104];
						msg[111:104] = outSub;
						end
      ISB_10_15 : begin
						inSub = msg[119:112];
						msg[119:112] = outSub;
						end
      ISB_10_16 : begin
						inSub = msg[127:120];
						msg[127:120] = outSub;
						end
						
		
		ARK_10  	: begin
						key = keyschedule[1407:1279];
						inAdd = msg;
						msg = outAdd;
					  end
      
		DONE1 	: begin
						AES_MSG_DEC = msg;
						end
		DONE2		: begin
						AES_DONE = 1'b1;
						end
						
		
		endcase
	end

endmodule	