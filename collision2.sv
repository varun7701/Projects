module collision1 (input Reset, frame_clk,
					input [9:0]  BallX, BallY, BallWidth, BallHeight,
					output W);
logic win;
parameter [9:0] Ball_X_Max= 550;
always_ff @ (posedge Reset or posedge frame_clk )
begin:Ball
		if (Reset)
			begin
			win = 0;
			end
		else if( (BallX + BallWidth) >= Ball_X_Max)
			win = 1;
		else
			begin
			win = 0;
			end
end
	assign W = win;
endmodule 