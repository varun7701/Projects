module obstacle(input Reset, frame_clk,
               output [9:0]  ObsX, ObsY, ObsS, ObsWidth, ObsHeight);
					
	logic [9:0] Obs_X_Pos, Obs_Y_Pos, Obs_Size;
	
    parameter [9:0] Obs_X_Center=240;  // Center position on the X axis
    parameter [9:0] Obs_Y_Center=242;  // Center position on the Y axis
	 assign Obs_Size = 34;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Obs_W = 50;
	 assign Obs_H = 30;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Obs_Y_Pos <= Obs_Y_Center;
		Obs_X_Pos <= Obs_X_Center;
    end
          	
	
	
	assign ObsX = Obs_X_Pos;
   
    assign ObsY = Obs_Y_Pos;
   
    assign ObsS = Obs_Size;
    
	 assign ObsWidth = Obs_W;
	 assign ObsHeight = Obs_H;
	 
endmodule