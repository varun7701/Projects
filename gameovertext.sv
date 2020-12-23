module gameover_t(input Reset, frame_clk,
					
               output [9:0]  gametextX, gametextY, gametextS, gametextWidth, gametextHeight);
					
	logic [9:0] gametext_X_Pos, gametext_Y_Pos, gametext_Size;

    parameter [9:0] gametext_X_Center=300;  
    parameter [9:0] gametext_Y_Center=100;  
	 assign gametext_Size = 99;  
	 assign gametext_W = 80;
	 assign gametext_H = 14;
	 				
	
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin  // Asynchronous Reset
		gametext_Y_Pos <= gametext_Y_Center;
		gametext_X_Pos <= gametext_X_Center;
		
    end
          	
	
	 
	assign gametextX = gametext_X_Pos;
   
    assign gametextY = gametext_Y_Pos;
   
    assign gametextS = gametext_Size;
    
	 assign gametextWidth = gametext_W;
	 assign gametextHeight = gametext_H;
	 
endmodule