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
		parameter	WR_BURST_SIZE = 8,
					RD_BURST_SIZE = 8,
					LINE_PIX = 640,			// 640 pixels per line
					
					NUM_LINE = 480,			// Number of lines
					
					ADV_PREFILL_WAIT = 1,	// Number of lines to wait in
											// between ADV FIFO prefills
											// (divide by two for actual number
											//	of times)
					
					NUM_WR = 1,
					NUM_RD = 1				// Should be 2 for the camera
											// system, and 1 when the pattern
											// generator is connected
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
					avl_read_req_0,
					avl_read_req_1,
		output	reg	wr_en_0 = DEASSERT_L,
					wr_en_1 = DEASSERT_L,
					rd_en_0 = DEASSERT_L,
					rd_en_1 = DEASSERT_L,
					wrreq_adv = DEASSERT_H,
					rdreq_adv = DEASSERT_H,
					rdreq_cam = DEASSERT_H,
					fb_sel = 1'b1,
		output	reg	[1:0]	wr_cnt,
							rd_cnt,
		output	reg	[8:0]	row_cnt,
		output	reg	[8:0]	valid_line_cnt,
		output	reg	[9:0]	valid_rd_cnt,
		output	reg	[31:0]	frame_num
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
					state <= (init_done) ? s_init_done : s_init_wait;
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
	//reg		[1:0]	rd_cnt = 0,
	//				wr_cnt = 0;
	always @(posedge clk_fst) begin
		
		if (~reset) begin
			wr_fb <= 1'b0;
			fb_sel <= 1'b1;
		end else if (wr_cnt == NUM_WR && rd_cnt == NUM_RD && ~wr_fb) begin
			wr_fb <= 1'b1;
			fb_sel <= 1'b0;
			rd_cnt <= 0;
			wr_cnt <= 0;
		end else if (wr_cnt == NUM_WR && rd_cnt == NUM_RD && wr_fb) begin
			wr_fb <= 1'b0;
			fb_sel <= 1'b1;
			rd_cnt <= 0;
			wr_cnt <= 0;
		end
		
		if (~reset)
			rd_cnt <= 2'd0;
		else if ((rd_done_0 || rd_done_1) && rd_cnt < NUM_RD)
			rd_cnt <= rd_cnt + 1;
		
		if (~reset)
			wr_cnt <= 2'd0;
		else if ((full_0 || full_1) && wr_cnt < NUM_WR)
			wr_cnt <= wr_cnt + 1;
	end
		
	// Frame buffer burst logic (50.4MHz domain)
	reg				wr_brst,
					rd_brst;
	reg		[4:0]	wr_brst_cnt = 0,
					rd_brst_cnt = 0;
	always @(posedge clk_fst) begin
		if (~reset) begin
			wr_brst <= 1'b0;
			rd_brst <= 1'b1;
			wr_brst_cnt <= 5'd0;
			rd_brst_cnt <= 5'd0;
		end else begin
			if ((~wr_en_0 | ~wr_en_1 | rdempty_cam) & 
					wr_brst_cnt < WR_BURST_SIZE - 1 & wr_brst)
				wr_brst_cnt <= wr_brst_cnt + 1;
			else if (wr_brst_cnt == WR_BURST_SIZE - 1 | full_0 | full_1 |
						wr_cnt == NUM_WR) begin
				if (rd_cnt < NUM_RD) begin
					wr_brst <= ~wr_brst;
					rd_brst <= ~rd_brst;
				end
				wr_brst_cnt <= 0;
			end

			if ((~rd_en_0 | ~rd_en_1) & rd_brst_cnt < RD_BURST_SIZE - 1
					& rd_brst)
				rd_brst_cnt <= rd_brst_cnt + 1;
			else if (rd_brst_cnt == RD_BURST_SIZE - 1 | rd_done_0 |
						rd_done_1 | rd_cnt == NUM_RD) begin
				if (wr_cnt < NUM_WR & ~rdempty_cam) begin
					rd_brst <= ~rd_brst;
					wr_brst <= ~wr_brst;
				end
				rd_brst_cnt <= 0;
			end
		/*end else begin
			rd_brst <= 1'b1;
			wr_brst <= 1'b0;
			wr_brst_cnt <= 5'd0;
			rd_brst_cnt <= 5'd0;*/
		end
	end
	
	// Frame buffer read counter
	reg		[9:0]	rd_pix_cnt = 0;
	reg		[8:0]	row_cnt_fst = 0;
	reg				prep_row_cnt_fst = 0;
	always @(posedge clk_fst) begin
		if (~reset) begin
			rd_pix_cnt <= 10'd0;
			row_cnt_fst <= 9'd0;
			prep_row_cnt_fst <= 1'b0;
			valid_rd_cnt <= 10'd0;
			valid_line_cnt <= 9'd0;
		end else begin
			if ((avl_read_req_0 | avl_read_req_1) & rd_pix_cnt < LINE_PIX)
				rd_pix_cnt <= rd_pix_cnt + 1;
			
			if (hdmi_pix_cnt == LINE_PIX)
				prep_row_cnt_fst <= 1'b1;
			else
				prep_row_cnt_fst <= 1'b0;
			
			if (row_cnt == NUM_LINE | row_cnt_fst >= ADV_PREFILL_WAIT) begin
				rd_pix_cnt <= 10'd0;
				row_cnt_fst <= 9'd0;
			end else if (row_cnt_fst < ADV_PREFILL_WAIT &
							hdmi_pix_cnt == LINE_PIX & prep_row_cnt_fst) begin
				row_cnt_fst <= row_cnt_fst + 1;
			end
			
			if ((rd_data_valid_0 | rd_data_valid_1) & valid_rd_cnt < LINE_PIX)
				valid_rd_cnt <= valid_rd_cnt + 1;
			else if (hdmi_pix_cnt == LINE_PIX &
						valid_line_cnt < NUM_LINE) begin
				valid_rd_cnt <= 10'd0;
				valid_line_cnt <= valid_line_cnt + 1;
			end else if (valid_line_cnt == NUM_LINE) begin
				valid_rd_cnt <= 10'd0;
				valid_line_cnt <= 9'd0;
			end
		end
	end
	
	// Video timing counters (25.2MHz domain)
	reg		[9:0]	hdmi_pix_cnt = 0;
	//reg		[8:0]	row_cnt = 0;
	always @(posedge clk) begin
		if (~reset) begin
			hdmi_pix_cnt <= 10'd0;
			row_cnt <= 9'd0;
			frame_num <= 32'd0;
		end else begin
			if (HDMI_TX_DE)
				hdmi_pix_cnt <= hdmi_pix_cnt + 1;
			
			if (hdmi_pix_cnt == LINE_PIX) begin
				row_cnt <= row_cnt + 1;
				hdmi_pix_cnt <= 0;
			end
			
			if (row_cnt == NUM_LINE) begin
				row_cnt <= 0;
				frame_num <= frame_num + 1;
			end
		end
	end
			
	
	// Control logic for all clock domains
	always @(*) begin
		if (state == s_fb_stream) begin
			// Cam to frame buffer FIFO
			if (wr_fb & ~rdempty_cam & wr_brst & wr_cnt < NUM_WR &
					~full_1) begin
				wr_en_1 = ASSERT_L;
				wr_en_0 = DEASSERT_L;
				
				if (avl_ready_1)
					rdreq_cam = ASSERT_H;
				else
					rdreq_cam = DEASSERT_H;
			end else if (~wr_fb & ~rdempty_cam & wr_brst & wr_cnt < NUM_WR &
							~full_0) begin
				wr_en_0 = ASSERT_L;
				wr_en_1 = DEASSERT_L;
				
				if (avl_ready_0)
					rdreq_cam = ASSERT_H;
				else
					rdreq_cam = DEASSERT_H;
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
			if (fb_sel & ~wrfull_adv & rd_brst & rd_cnt < NUM_RD &
					~rd_done_1) begin
				if ((rd_pix_cnt < LINE_PIX & ~HDMI_TX_DE) | HDMI_TX_DE) begin
					rd_en_1 = ASSERT_L;
					rd_en_0 = DEASSERT_L;
				end else begin
					rd_en_1 = DEASSERT_L;
					rd_en_0 = DEASSERT_L;
				end
			end else if (~fb_sel & ~wrfull_adv & rd_brst & rd_cnt < NUM_RD &
							~rd_done_0) begin
				if ((rd_pix_cnt < LINE_PIX & ~HDMI_TX_DE) | HDMI_TX_DE) begin
					rd_en_0 = ASSERT_L;
					rd_en_1 = DEASSERT_L;
				end else begin
					rd_en_1 = DEASSERT_L;
					rd_en_0 = DEASSERT_L;
				end
			end else begin
				rd_en_0 = DEASSERT_L;
				rd_en_1 = DEASSERT_L;
			end
			
			// ADV FIFO writes
			if ((rd_data_valid_1 | rd_data_valid_0) & ~wrfull_adv)
					wrreq_adv = ASSERT_H;
			else
					wrreq_adv = DEASSERT_H;
			//if (rd_data_valid_0)
			//		wrreq_adv = ASSERT_H;
			//else
			//		wrreq_adv = DEASSERT_H;
			
			// ADV data input
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
	
	// Debugging stuff
	/*always @(posedge clk) begin
		if (~reset || pix == 307200)
			pix <= 19'd1;
		else if (HDMI_TX_DE)
			pix <= pix + 1;
	end*/

endmodule