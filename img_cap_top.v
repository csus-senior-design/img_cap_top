/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Stereoscopic Image Capture Top Level Module
Authors: Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	This is the final top level design for the stereoscopic image capture
	system.
*/

`timescale 1 ns / 1 ns

module img_cap_top (
	// Clocks (obviously)
	(*
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input					CLOCK_50_B5B,
	(*
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input					CLOCK_50_B6A,
	
	// Reset (super obvious)
	(*
		chip_pin = "AB24",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input					CPU_RESET_n,

	// HDMI-TX via ADV7513
	(*
		chip_pin = "Y25",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output				HDMI_TX_CLK,
	(*
		chip_pin = "Y26",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output				HDMI_TX_DE,
	(*
		chip_pin = "U26",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output				HDMI_TX_HS,
	(*
		chip_pin = "U25",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output				HDMI_TX_VS,
	(*
		chip_pin = "AD25, AC25, AB25, AA24, AB26, R26, R24, P21, P26, N25, P23, P22, R25, R23, T26, T24, T23, U24, V25, V24, W26, W25, AA26, V23",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output	[23:0]	HDMI_TX_D,
	(*
		chip_pin = "T12",
		altera_attribute = "-name IO_STANDARD \"1.2 V\""
	*)
	input   				HDMI_TX_INT,
	
	// External I2C bus for HDMI-TX
	(*
		chip_pin = "B7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	inout					I2C_SCL,
	(*
		chip_pin = "G11",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	inout					I2C_SDA,
	
	// Status LEDs
	(*
		chip_pin = "J10, H7, K8, K10, J7, J8, G7, G6, F6, F7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	output	[9:0]		LEDR,
	(*
		chip_pin = "H9, H8, B6, A5, E9, D8, K6, L7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	output	[7:0]		LEDG,
	
	// GPIO pins for camera control and data
	(*
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input		[15:0]	GPIO,
	
	// Memory ports
	output	[9:0]	mem_ca,
	output	[0:0]	mem_ck,
	output	[0:0]	mem_ck_n,
	output	[0:0]	mem_cke,
	output	[0:0]	mem_cs_n,
	output	[3:0]	mem_dm,
	inout	[31:0]	mem_dq,
	inout	[3:0]	mem_dqs,
	inout	[3:0]	mem_dqs_n,
	input			oct_rzqin
);

	/* Pull down the LEDs for now (will use in control later) */
	assign LEDR = 10'h0;
	assign LEDG = 8'h0;

	/* Declare assertion parameters */
	localparam
		ASSERT_H = 1'b1,
		DEASSERT_H = 1'b0,
		ASSERT_L = 1'b0,
		DEASSERT_L = 1'b1;

	/* Declare the required test signals */
	parameter	TST_PATT = 24'hFFFFFF;
	wire		wr_en_in0,
				rd_en_in0;
	reg 		pass,
				fail;
	reg	[31:0]	valid_rd_data,
				rd_cnt;
	
	/* Test block for determining pass or failure */
	always @(posedge clk_25_2m)
		if (~reset) begin
			fail <= DEASSERT_H;
			pass <= DEASSERT_H;
		end else if ((valid_rd_data[23:0] != TST_PATT && rd_cnt != 0) || rd_cnt > 6)
			fail <= ASSERT_H;
		else if (rd_addr0 == 29'd2 && rd_cnt == 6)
			pass <= ASSERT_H;
	
	/* Assign the test pattern to the write data signal */
	assign wr_data0 = TST_PATT;
	
	/* Latch the read data when it's valid */
	always @(posedge clk_25_2m)
		if (~reset)
			rd_cnt <= 32'h0;
		else if (rd_data_valid) begin
			valid_rd_data <= rd_data0;
			rd_cnt <= rd_cnt + 1;
		end
		
	/* Send the pixel clock to the ADV7513 */
	assign HDMI_TX_CLK = clk_25_2m;
	
	/* Instantiate In-System Sources and Probes */
	wire reset;
	ISSP ISSP_inst(
		.source_clk(clk_25_2m),
		.source({wr_en_in0, rd_en_in0/*, reset*/}),
		.probe({pass, fail})
	);
	
	/* Declare the required interconnections */
	wire	[31:0]	wr_data0,
					rd_data0,
					wr_data1,
					rd_data1,
					wr_data2,
					rd_data2,
					wr_data3,
					rd_data3;
	wire	[23:0]	wr_addr0,
					rd_addr0,
					wr_addr1,
					rd_addr1,
					wr_addr2,
					rd_addr2,
					wr_addr3,
					rd_addr3;
	wire			wr_rdy0,
					rd_rdy0,
					wr_en0,
					rd_en0;
	wire			rd_data_valid;
	
	wire			full;
	
	wire			clk_25_2m,
					pll_locked,
					us_tck,
					ms_tck;
	
	
	/* Instantiate the required subsystems */
	
	debounce debounce_dat_ass (
		.clk(clk_25_2m),
		.rst(1'b0),
		.sig_in(CPU_RESET_n),
		.ms_tck(ms_tck),
		.sig_out(reset)
	);
	
	clocks cocks (
		.clk(CLOCK_50_B6A),
		.rst(reset),
		.pll_locked(pll_locked),
		.pll_outclk_0(clk_25_2m),
		.us_tck(us_tck),
		.ms_tck(ms_tck)
	);
	
	frame_buf_alt
	#(
		.BUF_SIZE(5)
	) frame_buf0 (
		.wr_clk(clk_25_2m),
		.rd_clk(clk_25_2m),
		.reset(reset),
		.wr_en_in(wr_en_in0),
		.rd_en_in(rd_en_in0),
		.wr_rdy(wr_rdy0),
		.rd_rdy(rd_rdy0),
		.wr_en(wr_en0),
		.rd_en(rd_en0),
		.full(full),
		.wr_addr(wr_addr0),
		.rd_addr(rd_addr0)
	);
	
	ram_int_4p mem_int (
		.wr_addr0(wr_addr0),
		.rd_addr0(rd_addr0),
		.wr_addr1(),
		.rd_addr1(),
		.wr_addr2(),
		.rd_addr2(),
		.wr_addr3(),
		.rd_addr3(),
		.wr_data0(wr_data0),
		.wr_data1(),
		.wr_data2(),
		.wr_data3(),
		.clk_50m(CLOCK_50_B5B),
		.clk(clk_25_2m),
		.wr_en0(wr_en0),
		.wr_en1(),
		.wr_en2(),
		.wr_en3(),
		.rd_en0(rd_en0),
		.rd_en1(),
		.rd_en2(),
		.rd_en3(),
		.reset(reset),
		.rd_data_valid0(rd_data_valid),
		.wr_rdy0(wr_rdy0),
		.rd_rdy0(rd_rdy0),
		.rd_data0(rd_data0),
		.rd_data1(),
		.rd_data2(),
		.rd_data3(),
		.mem_ca(mem_ca),
		.mem_ck(mem_ck),
		.mem_ck_n(mem_ck_n),
		.mem_cke(mem_cke),
		.mem_cs_n(mem_cs_n),
		.mem_dm(mem_dm),
		.mem_dq(mem_dq),
		.mem_dqs(mem_dqs),
		.mem_dqs_n(mem_dqs_n),
		.oct_rzqin(oct_rzqin)
	);
	
	img_cap_hdmi hdmi (
		.pix_clk(clk_25_2m),
		.reset(reset),
		.HDMI_TX_DE(HDMI_TX_DE),
		.HDMI_TX_HS(HDMI_TX_HS),
		.HDMI_TX_VS(HDMI_TX_VS),
		.I2C_SCL(I2C_SCL),
		.I2C_SDA(I2C_SDA),
		.i2c_reg_read(1'b0),
		.i2c_reg_addr(8'b0),
		.i2c_reg_data()
	);

endmodule