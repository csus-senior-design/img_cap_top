/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Image Capture Controller

Authors:	Greg M. Crist, Jr. (gmcrist@gmail.com)
			Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
	Top-Level Control State Machine and combinational logic
*/
module img_cap_ctrl #(
		parameter PLACEHOLDER = 0
	)(
		input		clk_fst,
					clk,
		input		reset,
		input		init_done,
		output	reg	init_start,
		input		full_0,
					full_1,
					rd_done_0,
					rd_done_1,
					avl_ready_0,
					avl_ready_1,
					wrfull_adv,
					wrfull_cam,
					rdempty_adv,
					rdempty_cam,
					HDMI_TX_DE,
					rd_data_valid_0,
					rd_data_valid_1,
		output	reg	wr_en_0 = DEASSERT_L,
					wr_en_1 = DEASSERT_L,
					rd_en_0 = DEASSERT_L,
					rd_en_1 = DEASSERT_L,
					wrreq_adv = DEASSERT_H,
					rdreq_adv = DEASSERT_H,
					rdreq_cam = DEASSERT_H,
					fb_sel = 1'b1
	);
	
	localparam
		ASSERT_L = 1'b0,
		DEASSERT_L = 1'b1,
		ASSERT_H = 1'b1,
		DEASSERT_H = 1'b0;

	localparam [3:0]
		s_idle = 0,
		s_reset = 1,
		s_init = 2,
		s_init_wait = 3,
		s_init_done = 4,
		s_fb_prefill = 5,
		s_fb_stream = 6;
			   
	(* syn_encoding = "safe" *)
	reg	[3:0]	state = s_init;
	reg			wr_fb = 1'b0;
	
	always @ (posedge clk) begin
		if (~reset) begin
			state <= s_reset;
			init_start <= 1'b0;
		end
		else begin
			case (state)
				// Placeholder for just chilling out
				s_idle: begin
				end

				// When put in a reset state, just jump straight to init
				s_reset: begin
					state <= s_init;
				end
				
				// Kickoff initialization of system components
				s_init: begin
					state <= s_init_wait;
					init_start <= 1'b1;
				end
				
				// Wait for system components to finish initializing
				s_init_wait: begin
					state <= init_done ? s_init_done : s_init_wait;
					init_start <= 1'b0;
				end
				
				// Transition from initialization to filling the framebuffers
				s_init_done: begin
					state <= s_fb_stream;
				end
				
				// Pre-fill the camera input framebuffers before pushing forward
				s_fb_prefill: begin
					state <= s_fb_stream;
				end
			   
				// Stream from the first framebuffer stage to the next and enable outputs
				s_fb_stream: begin
					state <= s_fb_stream;
				end
				
				default: state <= s_init;
			endcase
		end
	end
	
	// Frame buffer switching logic (50.4MHz domain)
	always @(posedge clk_fst)
		if (~reset) begin
			wr_fb = 1'b0;
			fb_sel = 1'b1;
		end else if (full_0 & rd_done_1) begin
			wr_fb = 1'b1;
			fb_sel = 1'b0;
		end else if (full_1 & rd_done_0) begin
			wr_fb = 1'b0;
			fb_sel = 1'b1;
		end
	
	// Control logic for all clock domains
	always @(*) begin
		if (state == s_fb_stream) begin
			// Cam to frame buffer FIFO
			if (wr_fb & ~rdempty_cam) begin
				wr_en_1 = ASSERT_L;
				wr_en_0 = DEASSERT_L;
				if (avl_ready_1)
					rdreq_cam = ASSERT_H;
			end else if (~wr_fb & ~rdempty_cam) begin
				wr_en_0 = ASSERT_L;
				wr_en_1 = DEASSERT_L;
				if (avl_ready_0)
					rdreq_cam = ASSERT_H;
			end else begin
				wr_en_0 = DEASSERT_L;
				wr_en_1 = DEASSERT_L;
				rdreq_cam = DEASSERT_H;
			end
			
			// Frame buffer switching logic
			/*if (full_0) begin
				wr_fb = 1'b1;
				fb_sel = 1'b0;
			end else if (full_1) begin
				wr_fb = 1'b0;
				fb_sel = 1'b1;
			end*/
			
			// Frame buffer to ADV FIFO
			if (fb_sel & ~wrfull_adv) begin
				rd_en_1 = ASSERT_L;
				rd_en_0 = DEASSERT_L;
				if (rd_data_valid_1)
					wrreq_adv = ASSERT_H;
				else
					wrreq_adv = DEASSERT_H;
			end else if (~fb_sel & ~wrfull_adv) begin
				rd_en_0 = ASSERT_L;
				rd_en_1 = DEASSERT_L;
				if (rd_data_valid_0)
					wrreq_adv = ASSERT_H;
				else
					wrreq_adv = DEASSERT_H;
				wrreq_adv = ASSERT_H;
			end else begin
				rd_en_0 = DEASSERT_L;
				rd_en_1 = DEASSERT_L;
				wrreq_adv = DEASSERT_H;
			end
			if (HDMI_TX_DE & ~rdempty_adv)
				rdreq_adv = ASSERT_H;
			else
				rdreq_adv = DEASSERT_H;
		end else begin
			wr_en_0 = DEASSERT_L;
			wr_en_1 = DEASSERT_L;
			rd_en_0 = DEASSERT_L;
			rd_en_1 = DEASSERT_L;
			wrreq_adv = DEASSERT_H;
			rdreq_adv = DEASSERT_H;
			rdreq_cam = DEASSERT_H;
		end
	end
	
endmodule