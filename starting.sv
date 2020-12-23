module startings(input Reset, frame_clk,
               output [9:0]  StartX, StartY, StartS, StartWidth, StartHeight);
					
	logic [9:0] Start_X_Pos, Start_Y_Pos, Start_Size;
	
    parameter [9:0] Start_X_Center=320;  // Center position on the X axis
    parameter [9:0] Start_Y_Center=50;  // Center position on the Y axis
	 assign Start_Size = 41;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Start_W = 80;
	 assign Start_H = 1;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Start_Y_Pos <= Start_Y_Center;
		Start_X_Pos <= Start_X_Center;
    end
          	
	
	
	assign StartX = Start_X_Pos;
   
    assign StartY = Start_Y_Pos;
   
    assign StartS = Start_Size;
    
	 assign StartWidth = Start_W;
	 assign StartHeight = Start_H;
	 
endmodule