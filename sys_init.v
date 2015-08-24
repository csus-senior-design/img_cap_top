/*
----------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
----------------------------------------

Image Capture Controller
System Initialization

Authors:  Greg M. Crist, Jr. (gmcrist@gmail.com)

Description:
	Performs initialization of all of the components
	  - Camera 1
	  - Camera 2
	  - HDMI Output
	  - RAM / Framebuffers
*/
module sys_init #(
	parameter	CAM1_CHIP_ADDR = 8'hCD,
				CAM2_CHIP_ADDR = 8'hCD,
			   
				ADV7513_INIT_DELAY = 29'd12600000,	// 500ms with 25.2MHz clock
			   
				ADV7513_CHIP_ADDR = 7'h39,			// 0x72 >> 1
				ADV7513_I2C_CLKDIV = 12'd125
)(
	input  clk,
	input  clk_sccb,
	input  reset,
	input  start,
	output reg done,

	// SCCB for Camera 1 Initialization 
	output cam1_pwdn,
	inout  cam1_sio_d,
	inout  cam1_sio_c,

	// SCCB for Camera 2 Initialization 
	output cam2_pwdn,
	inout  cam2_sio_c,
	inout  cam2_sio_d,

	// I2C for ADV7513 Initialization
	inout  i2c_scl,
	inout  i2c_sda,

	input mem_init_done
);
			   
	localparam s_idle      = 0,
			   s_init      = 1,
			   s_init_wait = 2,
			   s_init_done = 3;
			   
	(* syn_encoding = "safe" *)
	reg [3:0] state;

	reg cam1_init_start;
	wire cam1_init_done;
	
	reg cam2_init_start;
	wire cam2_init_done;

	reg hdmi_init_start;
	wire hdmi_init_done;
	
	reg			delay_done;
	reg	[28:0]	delay_tick;

	
	// OV 7670 Camera Initialization (Camera 1)
	ov_7670_init #(
		.CHIP_ADDR(CAM1_CHIP_ADDR)
	) cam1_init (
		.clk(clk),
		.clk_sccb(clk_sccb),
		.reset(reset),
		.pwdn(cam1_pwdn),
		.sio_d(cam1_sio_d),
		.sio_c(cam1_sio_c),
		.start(cam1_init_start),
		.done(cam1_init_done)
	);

	// OV 7670 Camera Initialization (Camera 2)
	ov_7670_init #(
		.CHIP_ADDR(CAM2_CHIP_ADDR)
	) cam2_init (
		.clk(clk),
		.clk_sccb(clk_sccb),
		.reset(reset),
		.pwdn(cam2_pwdn),
		.sio_d(cam2_sio_d),
		.sio_c(cam2_sio_c),
		.start(cam2_init_start),
		.done(cam2_init_done)
	);

	// ADV7513 HDMI Driver Initialization
	adv7513_init #(
		.CHIP_ADDR(ADV7513_CHIP_ADDR),
		.I2C_CLKDIV(ADV7513_I2C_CLKDIV)
	) hdmi_init (
		.clk(clk),
		.reset(reset),
		.scl(i2c_scl),
		.sda(i2c_sda),
		.start(hdmi_init_start),
		.done(hdmi_init_done)
	);

	// Memory Initialization
	// Performed at the top-level
	
	always @ (posedge clk) begin
		if (~reset) begin
			delay_done <= 1'b0;
			delay_tick <= 29'd0;
		end
		else begin
			delay_done <= (
				(state == s_idle) ||
				(state == s_init) ||
				(state == s_init_wait && delay_tick == ADV7513_INIT_DELAY)
			) ? 1'b1 : 1'b0;

			delay_tick <= (delay_done == 1'b1) ? 29'd0 : delay_tick + 29'b1;
		end
	end
	
	// Controller State Machine
	always @ (posedge clk) begin
		if (~reset) begin
			state <= s_init;
			done  <= 1'b0;
			cam1_init_start <= 1'b0;
			cam2_init_start <= 1'b0;
			hdmi_init_start <= 1'b0;
		end
		else begin
			cam1_init_start <= 1'b0;
			cam2_init_start <= 1'b0;
			hdmi_init_start <= 1'b0;
			
			case (state)
				s_idle: begin
					state <= start ? s_init : s_idle;
				end
				
				s_init: begin
					state <= s_init_wait;
					
					cam1_init_start <= 1'b1;
					cam2_init_start <= 1'b1;
					hdmi_init_start <= 1'b1;
				end
				
				s_init_wait: begin
					state <= (delay_done) ? s_init_done : s_init_wait;

				end
				
				s_init_done: begin
					done  <= 1'b1;
					state <= s_idle;
				end
			endcase
		end
	end
endmodule