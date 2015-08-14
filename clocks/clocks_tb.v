/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Clock Generation Module Testbench
Authors:	Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	This module instantiates the PLL which generates the system's pixel clock.
	It also generates signals that indicate 1µs and 1ms intervals.
*/

`include "clocks.v"
`timescale 1ns / 1ns

module clocks_tb;

	reg		clk,
			rst;
	wire	pll_locked,
			pll_outclk_0,
			us_tck,
			ms_tck;

	clocks #(
		.US(6'd5),
		.MS(16'd10)
	) uut (
		.clk(clk),
		.rst(rst),
		.pll_locked(pll_locked),
		.pll_outclk_0(pll_outclk_0),
		.us_tck(us_tck),
		.ms_tck(ms_tck)
	);
	
	initial begin
		$dumpfile("sim.vcd");
		$dumpvars();
	end
	
	always #10 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		rst = 1'b0;
		
		#20 rst = 1'b1;
		
		#420 $finish;
	end

endmodule