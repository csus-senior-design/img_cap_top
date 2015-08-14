/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

General Debounce Module
Authors:	Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	This module debounces a 1 bit wide input signal for 20 milliseconds by
	default, but it can be overridden upon instantiation. The default value
	that the output is set to can also be overridden.
*/

module debounce #(
	parameter
		TIME = 7'd20,
		DEF_VAL = 1'b1
)(
	input		clk,
	input		rst,
	input		sig_in,
	input		ms_tck,
	output	reg	sig_out = DEF_VAL		// Default to 1 for active low signals,
										// and 0 for active high signals
);

	reg	[6:0]	cnt = 7'd0;
	reg			cnt_rst = 1'd0;
	reg			ff1 = 1'd0;
	reg			ff2 = 1'd0;

	// Two flops are used to prevent metastability
	always @(posedge clk)
		if (rst) begin
			ff1 <= 1'b0;
			ff2 <= 1'b0;
			sig_out <= DEF_VAL;
			cnt_rst <= 1'b1;
		end else if (cnt == TIME) begin
			cnt_rst <= 1'b1;
			sig_out <= ff2;
		end else begin
			cnt_rst <= 1'b0;
			ff1 <= sig_in;
			ff2 <= ff1;
		end

	// Counter
	always @(posedge clk)
		if (cnt_rst || ff1 != ff2)
			cnt <= 7'h0;
		else if (ms_tck)
			cnt <= cnt + 7'h1;
		
endmodule