/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

General Debounce Module Simulation
Authors:	Padraic Hagerty    (guitarisrockin@hotmail.com)

Description:
	Simulates the debounce module
*/

`include "debounce.v"
`timescale 1ns / 1ns

// Define standard assertion and deassertion values for control signals

module debounce_tb;

reg	clk,
		rst,
		sig_in,
		ms_tck;
wire	sig_out;

always #10 clk = ~clk;

reg [5:0] cnt;
always @(posedge clk) begin
  cnt <= cnt + 1;
  
  if (cnt == 16'd2) begin
	ms_tck <= 1'b1;
	cnt <= 6'h0;
  end else
	ms_tck <= 1'b0;
end

initial begin
	$dumpfile("sim.vcd");
	$dumpvars();
end

initial begin
	cnt = 6'h0;
	ms_tck = 1'b0;
	clk = 1'b0;
	rst = 1'b1;
	sig_in = 1'b1;
	
	#20 rst = 1'b0;
	
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	
	#435 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	#5 sig_in = ~sig_in;
	
	#525 $finish;
end

debounce #(
	.TIME(7'h5)
) uut(
	.clk(clk),
	.rst(1'b0),
	.sig_in(sig_in),
	.ms_tck(ms_tck),
	.sig_out(sig_out)
);

endmodule