/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Clock Generation Module
Authors:	Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	This module instantiates the PLL which generates the system's pixel clock.
	It also generates signals that indicate 1µs and 1ms intervals.
*/

`timescale 1ns / 1ns

module clocks #(
	parameter
		US = 6'd26,		// 1.032µs with a 25.2MHz clock
		MS = 16'd25200	// 1ms with a 25.2MHz clock
)(
	input		clk,			// 50MHz reference clock for PLL
								// (don't use CLOCK_50_B5B)
	input		rst,
	//output		pll_locked,
	output		pll_outclk_0,
	output		pll_outclk_1,
	output		pll_outclk_2,
	output	reg	us_tck = 1'b0,
	output	reg	ms_tck = 1'b0
);

	/* Declare counter used for generating us_tck and ms_tck */
	reg	[5:0]	us_cnt = 6'd0;
	reg	[15:0]	ms_cnt = 6'd0;

	`ifdef SIM
		reg pll_outclk_0 = 1'b0;
		assign pll_locked = 1'b1;
		always #10 pll_outclk_0 = ~pll_outclk_0;
	`else
		/* Instantiate the Altera PLL */
		PLL pll_inst (
			.refclk(clk),
			.rst(1'b0),
			.outclk_0(pll_outclk_0),	// 126MHz clock for memory interface
			.outclk_1(pll_outclk_1),	// 25.2MHz clock for camera interface
			.outclk_2(pll_outclk_2)		// 12.6MHz 
			//.locked(pll_locked)
		);
	`endif
	
	/* Logic for generating us_tck and ms_tck */
	always @(posedge pll_outclk_0) begin
		us_tck <= 1'b0;
		ms_tck <= 1'b0;
		
		if (~rst) begin
			us_cnt <= 6'd0;
			ms_cnt <= 16'd0;
		end else begin
			if (us_cnt == US) begin
				us_cnt <= 6'd0;
				us_tck <= 1'b1;
			end else
				us_cnt <= us_cnt + 6'd1;
				
			if (ms_cnt == MS) begin
				ms_cnt <= 16'd0;
				ms_tck <= 1'b1;
			end else
				ms_cnt <= ms_cnt + 16'd1;
		end
	end

endmodule