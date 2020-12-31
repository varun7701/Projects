/************************************************************************
Lab 9 Quartus Project Top Level

Xinying Wang,  Summer 2020
Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module lab9 (
	input  logic        CLOCK_50,
	input  logic [1:0]  KEY,
	//output logic [7:0]  LED,
	output logic [9:0] LEDR,
	output logic [6:0]  HEX0,
	output logic [6:0]  HEX1,
	output logic [6:0]  HEX2,
	output logic [6:0]  HEX3,
	output logic [6:0]  HEX4,
	output logic [6:0]  HEX5,

	output logic [12:0] DRAM_ADDR,
	output logic [1:0]  DRAM_BA,
	output logic        DRAM_CAS_N,
	output logic        DRAM_CKE,
	output logic        DRAM_CS_N,
	inout  logic [15:0] DRAM_DQ,
	output logic [1:0]  DRAM_DQM,
	output logic        DRAM_RAS_N,
	output logic        DRAM_WE_N,
	output logic        DRAM_CLK
);

// Exported data to show on Hex displays
logic [31:0] EXPORT_DATA;



//instantiation of avalon_aes_interface.sv
//avalon_aes_interface avalon_interface(.CLK(CLOCK_50), .EXPORT_DATA(EXPORT_DATA));


// Instantiation of Qsys design
lab9_soc lab9_qsystem (
	.clk_clk(CLOCK_50),								// Clock input
	.reset_reset_n(KEY[0]),							// Reset key
	.aes_export_export_data(EXPORT_DATA),	// Exported data
	.sdram_wire_addr(DRAM_ADDR),					// sdram_wire.addr
	.sdram_wire_ba(DRAM_BA),						// sdram_wire.ba
	.sdram_wire_cas_n(DRAM_CAS_N),				// sdram_wire.cas_n
	.sdram_wire_cke(DRAM_CKE),						// sdram_wire.cke
	.sdram_wire_cs_n(DRAM_CS_N),					// sdram.cs_n
	.sdram_wire_dq(DRAM_DQ),						// sdram.dq
	.sdram_wire_dqm(DRAM_DQM),						// sdram.dqm
	.sdram_wire_ras_n(DRAM_RAS_N),				// sdram.ras_n
	.sdram_wire_we_n(DRAM_WE_N),					// sdram.we_n
	.sdram_clk_clk(DRAM_CLK)						// Clock out to SDRAM
);

// Display the first 4 and the last 4 hex values of the received message
HexDriver hexdrv0 (
	.In(EXPORT_DATA[3:0]),
   .Out(HEX0)
);
HexDriver hexdrv1 (
	.In(EXPORT_DATA[7:4]),
   .Out(HEX1)
);
HexDriver hexdrv2 (
	.In(EXPORT_DATA[19:16]),
   .Out(HEX2)
);
HexDriver hexdrv3 (
	.In(EXPORT_DATA[23:20]),
   .Out(HEX3)
);
HexDriver hexdrv4 (
	.In(EXPORT_DATA[27:24]),
   .Out(HEX4)
);
HexDriver hexdrv5 (
	.In(EXPORT_DATA[31:28]),
   .Out(HEX5)
);



endmodule