module ctrl #(
	parameter	DEF_VAL = 1'b0
)(
	input		clk,
				rst,
				start,
				full,
	output	reg	wr_en,
				reg	rd_en
);

