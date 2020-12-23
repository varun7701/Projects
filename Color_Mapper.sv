//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------
module  color_mapper ( input        [9:0] BallX, BallY, BallWidth, BallHeight, DrawX, DrawY, Ball_size,
							  input			[9:0] ObsX, ObsY, ObsWidth, ObsHeight, Obs_size,
							  input			[9:0] ObsX1, ObsY1, ObsWidth1, ObsHeight1, Obs_size1,
							  input			[9:0] ObsX3, ObsY3, ObsS3, ObsWidth3, ObsHeight3, Obs_size3,
							  input			[9:0] ObsX2, ObsY2, ObsS2, ObsWidth2, ObsHeight2, Obs_size2,
							  input        [9:0] FlagX, FlagY, Flag_size, FlagWidth, FlagHeight,
							  input        [9:0] gametextX, gametextY, gametextS, gametextWidth, gametextHeight,
							  input        [9:0] StartX, StartY, StartS, StartWidth, StartHeight,
							  input        [9:0] gamewinX, gamewinY, gamewinS, gamewinWidth, gamewinHeight,
							  input 			[9:0] HoneyX, HoneyY, HoneyWidth, HoneyHeight, Honey_size,
							  input Clk,
							  input  [0:39][0:30][0:3] obstacle1,
							  input  [0:39][0:48][0:3] bee,
							  input  [0:39][0:30][0:3] obstacle,
							  input  [0:11][0:42][0:3] starting,
							  input  [0:39][0:30][0:3] obstacle2,  
							  input  [0:39][0:30][0:3] obstacle3,
							  input  [0:39][0:39][0:3] flag,
							  input  [0:78][0:199][0:3] honeycomb,
							  input  [0:13][0:78][0:3] gameover_text,
							  input  [0:13][0:68][0:3] gamewin_text,
							  input L, W, S, 
                       output logic [7:0]  Red, Green, Blue );
    //signals for if sprite is to be drawn
	 
    logic ball_on;
	 logic [3:0] bee_on;
	 logic [3:0] obs_on;
	  logic [3:0] obs_on1;
	  logic [3:0] obs_on2;
	  logic [3:0] obs_on3;
	 logic [3:0] honey_on;
	 logic [3:0] gametext_on;
	 logic [3:0] gamewin_on;
	 logic [3:0] flag_on;
	logic [3:0] start_on;
		
		always_comb 
		begin: Ball_on_proc // draws Ball which is Bee
				 
			if ( !L && (DrawX >= BallX ) &&
				(DrawX <= BallX + (Ball_size )) &&
				(DrawY >= BallY) &&
				(DrawY <= BallY + (Ball_size)))
		 
				begin
					ball_on = 1'b1;
					bee_on = bee[DrawY-BallY][DrawX-BallX];
				end
			else
				begin
					ball_on = 1'b0;
					bee_on = 1'b0;
				end
		end
		// press start when be is in original position
		always_comb
		begin: Start_on_proc
			if (S && (DrawX >= StartX) &&
				(DrawX <= StartX + (StartS)) &&
				(DrawY >= StartY ) &&
				(DrawY <= StartY + (StartS)))
				begin
					start_on = starting[DrawY-StartY][DrawX-StartX];
				end
			else
			begin
				start_on = 1'b0;
				
			end
		end
		// draw gameover text when game is lost and not won
		always_comb
		begin: game_on_proc
			if (L && !W && (DrawX >= gametextX) &&
				(DrawX <= gametextX + (gametextS)) &&
				(DrawY >= gametextY ) &&
				(DrawY <= gametextY + (gametextS)))
				begin
					gametext_on = gameover_text[DrawY-gametextY][DrawX-gametextX];
				end
			else
			begin
				gametext_on = 1'b0;
				
			end
		end
		

		// draw obstacles
		always_comb
		begin: Obs_on_proc  //first lower spike
			if ( (DrawX >= ObsX) &&
				(DrawX <= ObsX + (Obs_size)) &&
				(DrawY >= ObsY ) &&
				(DrawY <= ObsY + (Obs_size)))
				begin
					obs_on = obstacle[DrawY-ObsY][DrawX-ObsX];
				end
			else
			begin
				obs_on = 1'b0;
			end
		end
		
		always_comb
		begin: Obs1_on_proc  //first upper spike
			if ( (DrawX >= ObsX1) &&
				(DrawX <= ObsX1 + (Obs_size1)) &&
				(DrawY >= ObsY1 ) &&
				(DrawY <= ObsY1 + (Obs_size1)))
				begin
					obs_on1 = obstacle1[DrawY-ObsY][DrawX-ObsX];
				end
			else
			begin
				obs_on1 = 1'b0;
			end
		end
		always_comb
		begin: Obs2_on_proc    //second lower spike
			if ((DrawX >= ObsX2) &&
				(DrawX <= ObsX2 + (Obs_size2)) &&
				(DrawY >= ObsY2 ) &&
				(DrawY <= ObsY2 + (Obs_size2)))
				begin
					obs_on2 = obstacle2[DrawY-ObsY2][DrawX-ObsX2];
				end
			else
			begin
				obs_on2 = 1'b0;
			end
		end
		always_comb
		begin: Obs3_on_proc  //second upper spike
			if ( (DrawX >= ObsX3) &&
				(DrawX <= ObsX3 + (Obs_size3)) &&
				(DrawY >= ObsY3 ) &&
				(DrawY <= ObsY3 + (Obs_size3)))
				begin
					obs_on3 = obstacle3[DrawY-ObsY3][DrawX-ObsX3];
				end
			else
			begin
				obs_on3 = 1'b0;
			end
		end
		// when game is won draw Flag
		always_comb
		begin: Flag_on_proc
			if ( W && (DrawX >= FlagX) &&
				(DrawX <= FlagX + (Flag_size)) &&
				(DrawY >= FlagY ) &&
				(DrawY <= FlagY + (Flag_size)))
				begin
					flag_on = flag[DrawY-FlagY][DrawX-FlagX];
				end
			else
			begin
				flag_on = 1'b0;
			end
		end
		
//		always_comb
//		begin: Honeycomb_on_proc
//			if ((DrawX >= HoneyX ) &&
//				(DrawX <= HoneyX + (HoneyWidth)) &&
//				(DrawY >= HoneyY ) &&
//				(DrawY <= HoneyY + (HoneyHeight)))
//				begin
//					honey_on = honeycomb[DrawY-HoneyY][DrawX-HoneyX];
//				end
//			else
//			begin
//				honey_on = 1'b0;
//			end
//		end
//		
		
				
		always_comb
		begin: RGB_Display
			if(ball_on == 1'b1 && bee_on == 4'b0001)
			begin
				Red = 8'h0;
				Green = 8'h0;
				Blue = 8'hFF;
			end
//			else if(ball_on == 1'b1 && bee_on == 4'b0010)
//			begin
//				Red = 8'h0;
//				Green = 8'h0;
//				Blue = 8'h0;
//			end	
			else if (ball_on == 1'b1 && bee_on == 4'b0010)
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
		 	 end
			 else if (ball_on == 1'b1 && bee_on == 4'b0011)
			 begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'hFF;
			end
			
			 else if (ball_on == 1'b1 && bee_on == 4'b0100)
			 begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'h00;
			end
			
			else if (obs_on == 4'b0001)
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			
			else if ( obs_on == 4'b0100)
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'h00;
			end
			else if (obs_on1 == 4'b0001)
			begin
				Red = 8'h0;
				Green = 8'h0;
				Blue = 8'h0;
			end
			
			else if ( obs_on1 == 4'b0010)
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'h00;
				end
			else if (obs_on3 == 4'b0001)
			begin
				Red = 8'h0;
				Green = 8'h0;
				Blue = 8'h0;
			end
			
			else if ( obs_on3 == 4'b0010)
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'h00;
				end
			else if (obs_on2 == 4'b0001)
			begin
				Red = 8'h0;
				Green = 8'h0;
				Blue = 8'h0;
			end
			
			else if ( obs_on2 == 4'b0100)
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'h00;
				end
				
			else if ( gametext_on == 4'b0001 )
			begin
				Red = 8'hFF;
				Green = 8'h00;
				Blue = 8'h00;
				end
			else if ( gametext_on == 4'b0010 )
			begin
				Red = 8'h00;
				Green = 8'hFF;
				Blue = 8'h00;
				end
			else if ( gamewin_on == 4'b0001)
			begin
				Red = 8'hFF;
				Green = 8'h00;
				Blue = 8'h00;
				end
			else if ( gamewin_on == 4'b0010)
			begin
				Red = 8'h00;
				Green = 8'hFF;
				Blue = 8'h00;
				end
			else if (flag_on == 4'b0001)
			begin
				Red = 8'hFF;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else if(flag_on == 4'b0010)
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
			else if (start_on == 4'b0001)
			begin
				Red = 8'hFF;
				Green = 8'hFF;
				Blue = 8'hFF;
			end
			else if(start_on == 4'b0010)
			begin
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
				end
			//else if (ball_on == 4'b0000 && obs_on ==4'b0000 && obs_on1 == 4'b0000 && obs_on2 == 4'b0000 && obs_on3 == 4'b000 && gamewin_on == 4'b0000 && gametext_on == 4'b0000)
			else
			begin
				Red = 8'h8A - DrawY[9:1];
				//Red = 8'h00;
            Green = 8'h8A- DrawY[9:1];
            Blue = 8'hFF- DrawY[9:1];;
         end

		end
			

endmodule
