// ISSP.v

// Generated using ACDS version 14.1 190 at 2015.04.22.10:47:58

`timescale 1 ps / 1 ps
module ISSP (
		input  wire [1:0] probe,      //     probes.probe
		input  wire       source_clk, // source_clk.clk
		output wire [2:0] source      //    sources.source
	);

	altsource_probe #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("NONE"),
		.probe_width             (2),
		.source_width            (3),
		.source_initial_value    ("7"),
		.enable_metastability    ("YES")
	) in_system_sources_probes_0 (
		.source     (source),     //    sources.source
		.source_clk (source_clk), // source_clk.clk
		.probe      (probe)       //     probes.probe
	);

endmodule
