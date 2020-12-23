module obstacle1(input Reset, frame_clk,
               output [9:0]  ObsX1, ObsY1, ObsS1, ObsWidth1, ObsHeight1);
					
	logic [9:0] Obs_X_Pos, Obs_Y_Pos, Obs_Size;
	
    parameter [9:0] Obs_X_Center=450;  // Center position on the X axis
    parameter [9:0] Obs_Y_Center=127;  // Center position on the Y axis

	 
	 assign Obs_Size = 34;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	 assign Obs_W = 50;
	 assign Obs_H = 40;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Obs_Y_Pos <= Obs_Y_Center;
		Obs_X_Pos <= Obs_X_Center;
    end
          	
	
	
	assign ObsX1 = Obs_X_Pos;
   
    assign ObsY1 = Obs_Y_Pos;
   
    assign ObsS1 = Obs_Size;
    
	 assign ObsWidth1 = Obs_W;
	 assign ObsHeight1 = Obs_H;
	 
endmodule