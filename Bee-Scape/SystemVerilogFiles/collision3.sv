module collision2 (input Reset, frame_clk,
					input [9:0]  BallX, BallY, BallWidth, BallHeight,
					output  S);

logic strt;

always_ff @ (posedge Reset or posedge frame_clk )
begin:Ball
		if (Reset)
			begin
			strt = 1;
			end
		else if (BallX >= 40)
			strt = 0;
		else
			begin
			strt= 1;
			end
end
	assign S = strt;
endmodule 