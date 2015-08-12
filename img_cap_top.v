/*
--------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team Honeybadger (Team 11)
California State University, Sacramento
Spring 2015 / Fall 2015
--------------------------------------------------

Stereoscopic Image Capture Top Level Module
Authors: Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	This is the final top level design for the stereoscopic image capture system.
*/

`timescale 1 ps / 1 ps

module img_cap_top (
	input					CLOCK_50_B5B,
							CLOCK_50_B6A,
							CLOCK_50_B7A,
							CLOCK_50_B8A,
							//reset,
	output	[9:0]		LEDR,
	output	[7:0]		LEDG,
	output	[9:0]		mem_ca,
	output	[0:0]		mem_ck,
	output	[0:0]		mem_ck_n,
	output	[0:0]		mem_cke,
	output	[0:0]		mem_cs_n,
	output	[3:0]		mem_dm,
	inout		[31:0]	mem_dq,
	inout		[3:0]		mem_dqs,
	inout		[3:0]		mem_dqs_n,
	input					oct_rzqin
);

	/* Pull down the LEDs */
	assign LEDR = 10'h0;
	assign LEDG = 8'h0;

	/* Declare assertion parameters */
	localparam
		ASSERT_H = 1'b1,
		DEASSERT_H = 1'b0,
		ASSERT_L = 1'b0,
		DEASSERT_L = 1'b1;

	/* Declare the required test signals */
	parameter		TST_PATT = 24'hFFFFFF;
	wire				wr_en_in0,
						rd_en_in0;
	reg 				pass,
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
	
	/* Instantiate In-System Sources and Probes */
	wire reset;
	ISSP ISSP_inst(
		.source_clk(clk_25_2m),
		.source({wr_en_in0, rd_en_in0, reset}),
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
	wire				wr_rdy0,
						rd_rdy0,
						wr_en0,
						rd_en0;
						
	wire				rd_data_valid;
	
	wire				full;
	
	wire				clk_25_2m;
	wire				pll_locked;
	
	/* Instantiate the required subsystems */
  
  	/* Instantiate extra PLL */
	PLL pll_inst (
		.refclk(CLOCK_50_B6A),
		.rst(1'b0),
		.outclk_0(clk_25_2m),
		.locked(pll_locked)
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

endmodule