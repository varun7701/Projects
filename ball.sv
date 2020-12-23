//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------

module  ball ( input Reset, frame_clk, 
					input [7:0] keycode,
               output [9:0]  BallX, BallY, BallS, BallWidth, BallHeight,
					output gameover, gamewin);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 //logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	
    parameter [9:0] Ball_X_Center=30;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=270;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=4;      // Step size on the Y axis
	 parameter [9:0] Ball_Y_Jump=-2;
	 parameter [9:0] Ball_Y_honeycomb= 260;
    parameter [9:0] Ball_Y_honeycombtop= 127;
    
	 
    assign Ball_Size = 31;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
    assign Ball_W = 45;
	 assign Ball_H = 40;
	 int DistX, DistY, Size;
	 
	 always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball 
		if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center + 10;
				Ball_X_Pos <= Ball_X_Center;
        end
		  else
		  begin
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_honeycomb )  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= -1;  // 2's complement.
					  
				 else if ( (Ball_Y_Pos ) <= Ball_Y_honeycombtop )  // Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= Ball_Y_Step;
						
					  
				  else if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
					  Ball_X_Motion <= 10'd0;  // 2's complement.
					  
//				 else if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
//					  Ball_X_Motion <= Ball_X_Step;
//					  
				 else 
				 begin
					  Ball_Y_Motion <= Ball_Y_Step;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  Ball_X_Motion <= 0;
				 end
				 case (keycode)

							  
					8'h1A : begin//Up
					
					
					        Ball_Y_Motion <= Ball_Y_Jump;//W
							  Ball_X_Motion <= 3;
					end	  
					default;
//							begin
//								Ball_X_Motion <= 1;
//								Ball_Y_Motion <= Ball_Y_Step; 
//							end	
			   endcase
				 
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
				 end
			end
		assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
	 
    assign BallWidth = Ball_W;
	 
	 assign BallHeight = Ball_H;
	 
	
    


endmodule

