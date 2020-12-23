module collision (input Reset, frame_clk,
               input [9:0]  ObsX3, ObsY3, ObsWidth3, ObsHeight3,
					 input [9:0]  ObsX, ObsY, ObsWidth, ObsHeight,
					 input [9:0]  ObsX1, ObsY1, ObsWidth1, ObsHeight1,
					input [9:0]  BallX, BallY, BallWidth, BallHeight,
					input [9:0]  ObsX2, ObsY2, ObsWidth2, ObsHeight2,
					output L);
logic boop; // boop is when Bee hits any obsticle, then game is lost

parameter [9:0] Ball_Y_honeycomb= 260;
parameter [9:0] Ball_Y_honeycombtop= 127;

always_ff @ (posedge Reset or posedge frame_clk )
begin:Ball
		if (Reset)
			begin
			boop = 0;
			
			end

		else if(((BallY) > (215)) && ((BallX) >= 200) && ((BallX ) <= 260))
			boop = 1;
		else if(((BallY) > (215)) && ((BallX ) >= 315) && ((BallX ) <= 370))
			boop = 1;

		else if(((BallY) < (150)) && ((BallX ) >= 405) && ((BallX ) <= 505))
			boop = 1;
		else
			begin
			boop = 0;
			
			end
end
	
	assign L = boop;
endmodule 