module obstacle2(input Reset, frame_clk,
               output [9:0]  ObsX2, ObsY2, ObsS2, ObsWidth2, ObsHeight2);
					
	logic [9:0] Obs_X_Pos, Obs_Y_Pos, Obs_Size;
	
    parameter [9:0] Obs_X_Center=350;  // Center position on the X axis
    parameter [9:0] Obs_Y_Center=242;  // Center position on the Y axis
	 
	 assign Obs_Size = 34;  // assigns the value 4 as a 20-digit binary number, ie "0000000200"
	 assign Obs_W = 50;
	 assign Obs_H = 40;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		Obs_Y_Pos <= Obs_Y_Center;
		Obs_X_Pos <= Obs_X_Center;
    end
          	
	
	
	assign ObsX2 = Obs_X_Pos;
   
    assign ObsY2 = Obs_Y_Pos;
   
    assign ObsS2 = Obs_Size;
    
	 assign ObsWidth2 = Obs_W;
	 assign ObsHeight2 = Obs_H;
	 
endmodule