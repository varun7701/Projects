module flag(input Reset, frame_clk,
               output [9:0]  FlagX, FlagY, FlagS, FlagWidth, FlagHeight);
					
	logic [9:0] Flag_X_Pos, Flag_Y_Pos, Flag_Size;
	
    parameter [9:0] Flag_X_Center=575;  // Center position on the X axis
    parameter [9:0] Flag_Y_Center=245;  // Center position on the Y axis
	 assign Flag_Size = 32;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Flag_W = 44;
	 assign Flag_H = 40;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Flag_Y_Pos <= Flag_Y_Center;
		Flag_X_Pos <= Flag_X_Center;
    end
          	
	
	
	assign FlagX = Flag_X_Pos;
   
    assign FlagY = Flag_Y_Pos;
   
    assign FlagS = Flag_Size;
    
	 assign FlagWidth = Flag_W;
	 assign FlagHeight = Flag_H;
	 
endmodule