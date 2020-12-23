//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

module lab8 (

      ///////// Clocks /////////
      input              Clk,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);


logic L, W, S; //rdy, gameover, gamewin, lost, win;

logic Reset_h, vssig, blank, sync, VGA_Clk;
logic [9:0] BallWidth, BallHeight;
logic [9:0] ObsWidth, ObsHeight;
logic [9:0] ObsWidth1, ObsHeight1;
logic [9:0] ObsWidth2, ObsHeight2;
logic [9:0] ObsWidth3, ObsHeight3;
logic [9:0] HoneyWidth, HoneyHeight;
logic [9:0] FlagWidth, FlagHeight;
logic [9:0] StartX, StartY, StartS, StartWidth, StartHeight;
//sprite wires
logic [0:39][0:48][0:3] bee;
logic [0:39][0:30][0:3] obstacle;
logic [0:78][0:199][0:3] honeycomb;
logic [0:13][0:78][0:3] gameover_text;
logic [0:13][0:68][0:3] gamewin_text;
logic [0:39][0:30][0:3] obstacle1;
logic [0:39][0:30][0:3] obstacle3;
logic [0:39][0:30][0:3] obstacle2;
logic [0:39][0:39][0:3] flag;
logic [0:11][0:42][0:3] starting;
//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; 
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
	
	logic [9:0] gametextX, gametextY, gametextS, gametextWidth, gametextHeight;
	logic [9:0] gamewinX, gamewinY, gamewinS, gamewinWidth, gamewinHeight;
	logic [9:0] obsxsig, obsysig, obssizesig;
	logic [9:0] obsxsig1, obsysig1, obssizesig1;
	logic [9:0] obsxsig2, obsysig2, obssizesig2;
	logic [9:0] obsxsig3, obsysig3, obssizesig3;
	logic [9:0] honeyxsig, honeyysig, honeysizesig;
	logic [9:0] flagxsig, flagysig, flagsizesig;
	logic [7:0] Red, Blue, Green;
	logic [7:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
vga_controller VGA(.Clk(Clk), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), .blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));

ball ball1(.Reset(Reset_h), .frame_clk(VGA_VS), .keycode(keycode), .BallX(ballxsig), .BallY(ballysig), .BallWidth(BallWidth), .BallHeight(BallHeight), .BallS(ballsizesig));

obstacle obstacles(.Reset(Reset_h), .frame_clk(VGA_VS), .ObsX(obsxsig), .ObsY(obsysig), .ObsWidth(ObsWidth), .ObsHeight(ObsHeight), .ObsS(obssizesig));

//honeycomb honeycomb1(.Reset(Reset_h), .frame_clk(VGA_VS), .HoneyX(honeyxsig), .HoneyY(honeyysing), .HoneyWidth(HoneyWidth), .HoneyHeight(HoneyHeight), .HoneyS(honeysizesig));

obstacle1 obstaclez(.Reset(Reset_h), .frame_clk(VGA_VS), .ObsX1(obsxsig1), .ObsY1(obsysig1), .ObsWidth1(ObsWidth1), .ObsHeight1(ObsHeight1), .ObsS1(obssizesig1));

obstacle3 obstacleq(.Reset(Reset_h), .frame_clk(VGA_VS), .ObsX3(obsxsig3), .ObsY3(obsysig3), .ObsWidth3(ObsWidth3), .ObsHeight3(ObsHeight3), .ObsS3(obssizesig3));
obstacle2 obstaclew(.Reset(Reset_h), .frame_clk(VGA_VS), .ObsX2(obsxsig2), .ObsY2(obsysig2), .ObsWidth2(ObsWidth2), .ObsHeight2(ObsHeight2), .ObsS2(obssizesig2));

color_mapper color(.Clk(Clk), 
						 .BallX(ballxsig), .L(L), .W(W), .S(S),
						 .BallY(ballysig), 
						 .BallWidth(BallWidth), .BallHeight(BallHeight),
						 .ObsX(obsxsig), .ObsY(obsysig), .ObsWidth(ObsWidth), .ObsHeight(ObsHeight), 
						 .ObsX1(obsxsig1), .ObsY1(obsysig1), .ObsWidth1(ObsWidth1), .ObsHeight1(ObsHeight1), .Obs_size1(obssizesig1),
						 .ObsX3(obsxsig3), .ObsY3(obsysig3), .ObsWidth3(ObsWidth3), .ObsHeight3(ObsHeight3), .Obs_size3(obssizesig3),
						 .ObsX2(obsxsig2), .ObsY2(obsysig2), .ObsWidth2(ObsWidth2), .ObsHeight2(ObsHeight2), .Obs_size2(obssizesig2),
						 .HoneyX(honeyxsig), .HoneyY(honeyysig), .HoneyWidth(HoneyWidth), .HoneyHeight(HoneyHeight), 
						 .DrawX(drawxsig), .DrawY(drawysig), .gametextX(gametextX), .gametextY(gametextY), .StartX(StartX), .StartY(StartY),
						 .StartS(StartS), .StartWidth(StartWidth), .StartHeight(StartHeight),
						 .gametextS(gametextS), .gametextWidth(gametextWidth), .gametextHeight(gametextHeight),
						 .FlagX(flagxsig), .FlagY(flagysig), .FlagWidth(FlagWidth), .FlagHeight(FlagHeight), .Flag_size(flagsizesig),
						  .gamewinX(gamewinX), .gamewinY(gamewinY), .starting(starting),
						 .gamewinS(gamewinS), .gamewinWidth(gamewinWidth), .gamewinHeight(gamewinHeight),
						 .Ball_size(ballsizesig), .Obs_size(obssizesig), .Honey_size(honeysizesig), .Red(Red), 
						 .Green(Green), .Blue(Blue), .obstacle1(obstacle1), .obstacle3(obstacle3), .obstacle2(obstacle2),
						 .bee(bee), .obstacle(obstacle), .flag(flag), .gamewin_text(gamewin_ttext), .gameover_text(gameover_text), .honeycomb(honeycomb));

sprite_decider sprites(.bee(bee), .starting(starting), .flag(flag), .gamewin_text(gamewin_text), .obstacle1(obstacle1), .gameover_text(gameover_text), .obstacle(obstacle), .obstacle2(obstacle2), .obstacle3(obstacle3));

flag flag1(.Reset(Reset_h), .frame_clk(VGA_VS), .FlagX(flagxsig), .FlagY(flagysig), .FlagWidth(FlagWidth), .FlagHeight(FlagHeight), .FlagS(flagsizesig));

startings startingz(.Reset(Reset_h), .frame_clk(VGA_VS), .StartX(StartX), .StartY(StartY), .StartS(StartS), .StartWidth(StartWidth), .StartHeight(StartHeight));

collision gameender( .Reset(Reset_h), .frame_clk(VGA_VS), .ObsX(obsxsig), .ObsY(obsysig), .ObsWidth(ObsWidth), .ObsHeight(ObsHeight), 
.ObsX1(obsxsig1), .ObsY1(obsysig1), .ObsWidth1(ObsWidth1), .ObsHeight1(ObsHeight1), 
.ObsX3(obsxsig3), .ObsY3(obsysig3), .ObsWidth3(ObsWidth3), .ObsHeight3(ObsHeight3), 
	.ObsX2(obsxsig2), .ObsY2(obsysig2), .ObsWidth2(ObsWidth2), .ObsHeight2(ObsHeight2), .BallX(ballxsig),  .BallY(ballysig), 
						 .BallWidth(BallWidth), .BallHeight(BallHeight), .L(L));
						 
collision1 gameender1( .Reset(Reset_h), .frame_clk(VGA_VS), .BallX(ballxsig),  .BallY(ballysig), 
						 .BallWidth(BallWidth), .BallHeight(BallHeight), .W(W));
						 
collision2 gameender2( .Reset(Reset_h), .frame_clk(VGA_VS), 
						 .BallX(ballxsig),  .BallY(ballysig), 
						 .BallWidth(BallWidth), .BallHeight(BallHeight), .S(S));		 

gameover_t games( .Reset(Reset_h), .frame_clk(VGA_VS), .gametextX(gametextX), .gametextY(gametextY), .gametextS(gametextS), .gametextWidth(gametextWidth), .gametextHeight(gametextHeight));

//gamewin_t  gamez( .Reset(Reset_h), .frame_clk(VGA_VS), .gamewinX(gamewinX), .gamewinY(gamewinY), .gamewinS(gamewinS), .gamewinWidth(gamewinWidth), .gamewinHeight(gamewinHeight));
	
	lab8_soc u0 (
		.clk_clk                           (Clk),            //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.clk_sdram_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode)
		
	 );
endmodule
