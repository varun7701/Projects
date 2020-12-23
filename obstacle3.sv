module obstacle3(input Reset, frame_clk,
               output [9:0]  ObsX3, ObsY3, ObsS3, ObsWidth3, ObsHeight3);
					
	logic [9:0] Obs_X_Pos, Obs_Y_Pos, Obs_Size;
	
    parameter [9:0] Obs_X_Center=100;  // Center position on the X axis
    parameter [9:0] Obs_Y_Center=127;  // Center position on the Y axis
	 
	 assign Obs_Size = 34;  // assigns the value 4 as a 30-digit binary number, ie "0000000300"
	 assign Obs_W = 50;
	 assign Obs_H = 40;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Obs_Y_Pos <= Obs_Y_Center;
		Obs_X_Pos <= Obs_X_Center;
    end
          	
	
	
	assign ObsX3 = Obs_X_Pos;
   
    assign ObsY3 = Obs_Y_Pos;
   
    assign ObsS3 = Obs_Size;
    
	 assign ObsWidth3 = Obs_W;
	 assign ObsHeight3 = Obs_H;
	 
endmodule