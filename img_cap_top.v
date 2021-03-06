/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Stereoscopic Image Capture Top Level Module
Authors:    Padraic Hagerty (guitarisrockin@hotmail.com)
            Greg M. Crist, Jr. (gmcrist@gmail.com)

Description:
    This is the final top level design for the stereoscopic image capture
    system.
*/

`timescale 1 ns / 1 ns

module img_cap_top #(
    parameter   CAM1_CHIP_ADDR = 8'hCD,
                CAM2_CHIP_ADDR = 8'hCD,
                ADV7513_CHIP_ADDR = 7'h39,
                ADV7513_I2C_CLKDIV = 12'd63     // Gives a 100kHz clock
                                                // based on a 25.2MHz clock
)(
	// Clocks (obviously)
	(*
		chip_pin = "R20",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input           	CLOCK_50_B5B,
	(*
		chip_pin = "N20",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input           	CLOCK_50_B6A,

	// Reset (super obvious)
	(*
		chip_pin = "AB24",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	input           	CPU_RESET_n,

	// HDMI-TX via ADV7513
	(*
		chip_pin = "Y25",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output          	HDMI_TX_CLK,
	(*
		chip_pin = "Y26",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output          	HDMI_TX_DE,
	(*
		chip_pin = "U26",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output          	HDMI_TX_HS,
	(*
		chip_pin = "U25",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output          	HDMI_TX_VS,
	(*
		chip_pin = "AD25, AC25, AB25, AA24, AB26, R26, R24, P21, P26, N25, P23, P22, R25, R23, T26, T24, T23, U24, V25, V24, W26, W25, AA26, V23",
		altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
	*)
	output		[23:0]  HDMI_TX_D,
	(*
		chip_pin = "T12",
		altera_attribute = "-name IO_STANDARD \"1.2 V\""
	*)
	input           	HDMI_TX_INT,

	// External I2C bus for HDMI-TX
	(*
		chip_pin = "B7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	inout           	I2C_SCL,
	(*
		chip_pin = "G11",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	inout           	I2C_SDA,

	// Status LEDs
	(*
		chip_pin = "J10, H7, K8, K10, J7, J8, G7, G6, F6, F7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	output  	[9:0]   LEDR,
	(*
		chip_pin = "H9, H8, B6, A5, E9, D8, K6, L7",
		altera_attribute = "-name IO_STANDARD \"2.5 V\""
	*)
	output  	[7:0]   LEDG,

	// Debounced push buttons
	(*
		chip_pin = "Y16, Y15, P12, P11",
		altera_attribute = "-name IO_STANDARD \"1.2 V\""
	*)
	input   	[3:0]   KEY,

    // Switches
    (*
        chip_pin = "AE19, Y11, AC10, V10, AB10, W11, AC8, AD13, AE10, AC9",
        altera_attribute = "-name IO_STANDARD \"1.2V\""
    *)
    input       [9:0]   SW,

    // Camera Interfaces
    // Camera 1
    (*
        chip_pin = "P8",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM1_SIOC,   // Cam 1 SIOC (GPIO 12)

    (*
        chip_pin = "U19",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    inout               CAM1_SIOD,   // Cam 1 SIOD (GPIO 10)

    (*
        chip_pin = "R8",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM1_VSYNC,  // Cam 1 VSYNC (GPIO 13)

    (*
        chip_pin = "U22",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM1_HREF,   // Cam 1 HREF (GPIO 11)

    (*
        chip_pin = "T21",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM1_PCLK,   // Cam 1 PCLK (GPIO 0)

    (*
        chip_pin = "F26",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM1_XCLK,   // Cam 1 XCLK (GPIO 16)

    (*
        chip_pin = "R9",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM1_RESET,  // Cam 1 RESET (GPIO 14)

    (*
        chip_pin = "R10",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM1_PWDN,   // Cam 1 PWDN (GPIO 15)

    (*
        chip_pin = "T19, P20, T22, M26, M21, E26, K26, D26",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input       [7:0]   CAM1_DATA,   // Cam 1 Data (GPIO 9, 7, 8, 6, 5, 4, 3, 2, 1)


    // Camera 2
    (*
        chip_pin = "AD7",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM2_SIOC,   // Cam 2 SIOC (GPIO 22)

    (*
        chip_pin = "AA7",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    inout               CAM2_SIOD,   // Cam 2 SIOD (GPIO 20)

    (*
        chip_pin = "AD6",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM2_VSYNC,  // Cam 2 VSYNC (GPIO 23)

    (*
        chip_pin = "V22",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM2_HREF,   // Cam 2 HREF (GPIO 25)

    (*
        chip_pin = "K25",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input               CAM2_PCLK,   // Cam 2 PCLK (GPIO 2)

    (*
        chip_pin = "G26",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM2_XCLK,   // Cam 2 XCLK (GPIO 18)

    (*
        chip_pin = "U20",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM2_RESET,  // Cam 2 RESET (GPIO 24)

    (*
        chip_pin = "AA6",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    output              CAM2_PWDN,   // Cam 2 PWDN (GPIO 21)

    (*
        chip_pin = "AC22, AC24, Y23, AA23, W20, V20, W21",
        altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
    *)
    input       [7:0]   CAM2_DATA,   // Cam 2 Data (GPIO 35, 33, 30, 31, 28, 29, 26, 27)


	// Memory ports
	output  [9:0]   mem_ca,
	output  [0:0]   mem_ck,
	output  [0:0]   mem_ck_n,
	output  [0:0]   mem_cke,
	output  [0:0]   mem_cs_n,
	output  [3:0]   mem_dm,
	inout   [31:0]  mem_dq,
	inout   [3:0]   mem_dqs,
	inout   [3:0]   mem_dqs_n,
	input           oct_rzqin
);

    /* Pull down the LEDs for now (will use in control later) */
    assign LEDR[9:0] = 10'h0;
    assign LEDG[7:0] = 8'h0;

    /* Declare assertion parameters */
    localparam
        ASSERT_H = 1'b1,
        DEASSERT_H = 1'b0,
        ASSERT_L = 1'b0,
        DEASSERT_L = 1'b1;

    /* Declare the required interconnections */
    wire            reset;

	reg		[31:0]	fb_data_in;
    wire    [31:0]  fb_data_out,
                    rd_data_0,
                    rd_data_1,
                    wr_data_2,
                    rd_data_2,
                    wr_data_3,
                    rd_data_3;
    wire    [28:0]  avl_addr_0,
                    avl_addr_1,
                    avl_addr_2,
                    avl_addr_3;
    wire            ram_rdy,
                    avl_ready_0,
                    avl_ready_1,
                    avl_ready_2,
                    avl_ready_3,
                    avl_write_req_0,
                    avl_write_req_1,
                    avl_write_req_2,
                    avl_write_req_3,
                    avl_read_req_0,
                    avl_read_req_1,
                    avl_read_req_2,
                    avl_read_req_3;
    wire            rd_data_valid_0,
					rd_data_valid_1,
					rd_data_valid_2,
					rd_data_valid_3;

    wire            full_0,
					full_1,
					rd_done_0,
					rd_done_1,
					wr_en_0,
					wr_en_1,
					rd_en_0,
					rd_en_1;

    wire            clk_50_4m,
					clk_25_2m,
                    pll_locked,
                    us_tck,
                    ms_tck;
	
	wire	[23:0]	adv_fifo_q,
					cam_fifo_q;
	wire			wrreq_adv,
					wrreq_cam,
					rdreq_adv,
					rdreq_cam,
					wrfull_adv,
					wrfull_cam,
					rdempty_adv,
					rdempty_cam,
					fb_sel,
					fb_rst;
	
	wire	[1:0]	wr_cnt;


    /* Instantiate the required subsystems */
    assign reset = KEY[3];
	

	//=========================================================================
	// Clocks (25.2MHz domain)
	//=========================================================================
    clocks clock_block (
        .clk(CLOCK_50_B6A),
        .rst(reset),
        .pll_outclk_0(clk_50_4m),
        .pll_outclk_1(clk_25_2m),
        .us_tck(us_tck),
        .ms_tck(ms_tck)
    );
	
	
	//=========================================================================
	// ADV7513 signals (25.2MHz domain)
	//=========================================================================
	localparam VIDEO_FORMAT = 8'd1; // Format 1 (640 x 480p @ 60Hz)
	
	/* ********************* */
	wire INTERLACED;
	wire [11:0] V_TOTAL_0;
	wire [11:0] V_FP_0;
	wire [11:0] V_BP_0;
	wire [11:0] V_SYNC_0;
	wire [11:0] V_TOTAL_1;
	wire [11:0] V_FP_1;
	wire [11:0] V_BP_1;
	wire [11:0] V_SYNC_1;
	wire [11:0] H_TOTAL;
	wire [11:0] H_FP;
	wire [11:0] H_BP;
	wire [11:0] H_SYNC;
	wire [11:0] HV_OFFSET_0;
	wire [11:0] HV_OFFSET_1;
	wire [19:0] PATTERN_RAMP_STEP;
	wire [11:0] x_out;
	wire [12:0] y_out;
	wire field = 1'b0;
	
	/* Send the pixel clock to the ADV7513 */
    assign HDMI_TX_CLK = clk_25_2m;

	format_vg format_vg (
		.FORMAT(VIDEO_FORMAT),
		.INTERLACED(INTERLACED),
		.V_TOTAL_0(V_TOTAL_0),
		.V_FP_0(V_FP_0),
		.V_BP_0(V_BP_0),
		.V_SYNC_0(V_SYNC_0),
		.V_TOTAL_1(V_TOTAL_1),
		.V_FP_1(V_FP_1),
		.V_BP_1(V_BP_1),
		.V_SYNC_1(V_SYNC_1),
		.H_TOTAL(H_TOTAL),
		.H_FP(H_FP),
		.H_BP(H_BP),
		.H_SYNC(H_SYNC),
		.HV_OFFSET_0(HV_OFFSET_0),
		.HV_OFFSET_1(HV_OFFSET_1),
		.PATTERN_RAMP_STEP(PATTERN_RAMP_STEP)
	);

	sync_vg #(.X_BITS(12), .Y_BITS(12)) sync_vg (
		.clk(clk_25_2m),
		.reset(init_done),
		.interlaced(INTERLACED),
		.clk_out(), // inverted output clock - unconnected
		.v_total_0(V_TOTAL_0),
		.v_fp_0(V_FP_0),
		.v_bp_0(V_BP_0),
		.v_sync_0(V_SYNC_0),
		.v_total_1(V_TOTAL_1),
		.v_fp_1(V_FP_1),
		.v_bp_1(V_BP_1),
		.v_sync_1(V_SYNC_1),
		.h_total(H_TOTAL),
		.h_fp(H_FP),
		.h_bp(H_BP),
		.h_sync(H_SYNC),
		.hv_offset_0(HV_OFFSET_0),
		.hv_offset_1(HV_OFFSET_1),
		.de_out(de),
		.vs_out(vs),
		.v_count_out(),
		.h_count_out(),
		.x_out(x_out),
		.y_out(y_out),
		.hs_out(hs),
		.field_out(field)
	);
	/*always @(posedge clk_25_2m)
		if (~reset)
			HDMI_TX_D <= 24'd0;
		else if (rdreq_adv)
			HDMI_TX_D <= adv_fifo_q;*/
	assign HDMI_TX_D = adv_fifo_q;

	//=========================================================================
	// FIFO between frame buffers and ADV7513 (25.2MHz above, 50.4MHz below)
	//=========================================================================
	reg		[31:0]	valid_rd_data_0,
					valid_rd_data_1;
	
	ADV_FIFO adv_fifo (
		.data(fb_data_out),
		.rdclk(clk_25_2m),
		.rdreq(rdreq_adv),
		.wrclk(clk_50_4m),
		.wrreq(wrreq_adv),
		.q(adv_fifo_q),
		.rdempty(rdempty_adv),
		.wrfull(wrfull_adv),
		.aclr(~reset | ~fb_rst)
	);
	assign fb_data_out = (fb_sel) ? valid_rd_data_1 : valid_rd_data_0;
	
	always @(posedge clk_50_4m) begin
		if (rd_data_valid_0)
			valid_rd_data_0 <= rd_data_0;
		if (rd_data_valid_1)
			valid_rd_data_1 <= rd_data_1;
	end

	//=========================================================================
	// Frame buffers and memory interface logic (50.4MHz domain)
	//=========================================================================
    frame_buf_alt frame_buf_0 (
        .clk(clk_50_4m),
        .reset(reset & fb_rst),
        .wr_en(wr_en_0),
        .rd_en(rd_en_0),
        .ram_rdy(ram_rdy),
        .avl_ready(avl_ready_0),
        .avl_write_req(avl_write_req_0),
        .avl_read_req(avl_read_req_0),
        .full(full_0),
		.rd_done(rd_done_0),
        .wr_addr(),
        .rd_addr(),
        .avl_addr(avl_addr_0)
    );
	frame_buf_alt #(
		.BASE_ADDR(308000)
	) frame_buf_1 (
        .clk(clk_50_4m),
        .reset(reset & fb_rst),
        .wr_en(wr_en_1),
        .rd_en(rd_en_1),
        .ram_rdy(ram_rdy),
        .avl_ready(avl_ready_1),
        .avl_write_req(avl_write_req_1),
        .avl_read_req(avl_read_req_1),
        .full(full_1),
		.rd_done(rd_done_1),
        .wr_addr(),
        .rd_addr(),
        .avl_addr(avl_addr_1)
    );

    ram_int_4p mem_int (
        .wr_data_0(cam_fifo_q),
        .wr_data_1(cam_fifo_q),
        .wr_data_2(),
        .wr_data_3(),
        .clk_50m(CLOCK_50_B5B),
        .clk(clk_50_4m),
        .reset(reset),
        .avl_write_req_0(avl_write_req_0),
        .avl_read_req_0(avl_read_req_0),
        .avl_write_req_1(avl_write_req_1),
        .avl_read_req_1(avl_read_req_1),
        .avl_write_req_2(),
        .avl_read_req_2(),
        .avl_write_req_3(),
        .avl_read_req_3(),
        .rd_data_valid_0(rd_data_valid_0),
		.rd_data_valid_1(rd_data_valid_1),
		.rd_data_valid_2(),
		.rd_data_valid_3(),
        .ram_rdy(ram_rdy),
        .avl_ready_0_fl(avl_ready_0),
        .avl_ready_1_fl(avl_ready_1),
        .avl_ready_2_fl(),
        .avl_ready_3_fl(),
        .avl_addr_0(avl_addr_0),
        .avl_addr_1(avl_addr_1),
        .avl_addr_2(),
        .avl_addr_3(),
        .rd_data_0(rd_data_0),
        .rd_data_1(rd_data_1),
        .rd_data_2(),
        .rd_data_3(),
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
	/*always @(posedge clk_50_4m)
		if (~reset)
			fb_data_in <= 32'd0;
		else if (rdreq_cam)
			fb_data_in <= cam_fifo_q;*/

	//=========================================================================
	// FIFO between camera and frame buffers (50.4MHz above, 25.2MHz below)
	//=========================================================================
	
	CAM_FIFO cam_fifo (
		.data(SW[0] ? CAM1_CAP_DATA : cam_data_tst),
		.rdclk(clk_50_4m),
		.rdreq(rdreq_cam),
		.wrclk(clk_25_2m),
		.wrreq(wrreq_cam),
		.q(cam_fifo_q),
		.rdempty(rdempty_cam),
		.wrfull(wrfull_cam),
		.aclr(~reset | ~fb_rst)
	);
	//assign wrreq_cam = CAM1_CAP_WRITE_EN;
	//assign wrreq_cam = cam_wr_en_tst & ~wrfull_cam;
	assign wrreq_cam = SW[0] ? CAM1_CAP_WRITE_EN : (HDMI_TX_DE & ~wrfull_cam);

    //=========================================================================
	// Camera capture interfaces (25.2MHz domain, pixels come in at 12.6MHz)
	//=========================================================================
    assign CAM1_XCLK = clk_25_2m;
    assign CAM2_XCLK = clk_25_2m;

    assign CAM1_RESET = reset;
    assign CAM2_RESET = reset;

    wire [18:0] CAM1_CAP_ADDRESS;
    wire [23:0] CAM1_CAP_DATA;
    wire CAM1_CAP_WRITE_EN;

    wire [18:0] CAM2_CAP_ADDRESS;
    wire [23:0] CAM2_CAP_DATA;
    wire CAM2_CAP_WRITE_EN;

    ov_7670_capture capture_cam1 (
        .pclk(CAM1_PCLK),
        .vsync(CAM1_VSYNC),
        .href(CAM1_HREF),
        .data(CAM1_DATA),
        .addr(CAM1_CAP_ADDRESS),
        .data_out(CAM1_CAP_DATA),
        .write_en(CAM1_CAP_WRITE_EN)
    );

    ov_7670_capture capture_cam2 (
        .pclk(CAM2_PCLK),
        .vsync(CAM2_VSYNC),
        .href(CAM2_HREF),
        .data(CAM2_DATA),
        .addr(CAM2_CAP_ADDRESS),
        .data_out(CAM2_CAP_DATA),
        .write_en(CAM2_CAP_WRITE_EN)
    );

    // Top-level Control Modules
    wire init_start;
    wire init_done;

    // To do: generate a 100kHz clock signal for this
    wire clk_sccb;

    sys_init #(
        .CAM1_CHIP_ADDR(CAM1_CHIP_ADDR),
        .CAM2_CHIP_ADDR(CAM2_CHIP_ADDR),
        .ADV7513_CHIP_ADDR(ADV7513_CHIP_ADDR),
        .ADV7513_I2C_CLKDIV(ADV7513_I2C_CLKDIV)
    ) sys_init (
        .clk(clk_25_2m),
        .clk_sccb(clk_sccb),
        .reset(reset),
        .start(init_start),
        .done(init_done),

        // SCCB for Camera 1 Initialization
        .cam1_pwdn(CAM1_PWDN),
        .cam1_sio_d(CAM1_SIOD),
        .cam1_sio_c(CAM1_SIOC),

        // SCCB for Camera 2 Initialization
        .cam2_pwdn(CAM2_PWDN),
        .cam2_sio_c(CAM2_SIOD),
        .cam2_sio_d(CAM2_SIOC),

        // I2C for ADV7513 Initialization
        .i2c_scl(I2C_SCL),
        .i2c_sda(I2C_SDA),

        // Memory init done input
        .mem_init_done(ram_rdy)
    );

    img_cap_ctrl img_cap_ctrl (
		.clk_fst(clk_50_4m),
        .clk(clk_25_2m),
        .reset(reset),
        .init_start(init_start),
        .init_done(init_done),
		.full_0(full_0),
		.full_1(full_1),
		.rd_done_0(rd_done_0),
		.rd_done_1(rd_done_1),
		.avl_ready_0(avl_ready_0),
		.avl_ready_1(avl_ready_1),
		.wrfull_adv(wrfull_adv),
		.wrfull_cam(wrfull_cam),
		.rdempty_adv(rdempty_adv),
		.rdempty_cam(rdempty_cam),
		.HDMI_TX_DE(HDMI_TX_DE),
		.rd_data_valid_0(rd_data_valid_0),
		.rd_data_valid_1(rd_data_valid_1),
		.avl_read_req_0(avl_read_req_0),
		.avl_read_req_1(avl_read_req_1),
		.avl_write_req_0(avl_write_req_0),
		.avl_write_req_1(avl_write_req_1),
		.wr_en_0(wr_en_0),
		.wr_en_1(wr_en_1),
		.rd_en_0(rd_en_0),
		.rd_en_1(rd_en_1),
		.wrreq_adv(wrreq_adv),
		.rdreq_adv(rdreq_adv),
		.rdreq_cam(rdreq_cam),
		.fb_sel(fb_sel),
		.wr_cnt(wr_cnt),
		.fb_rst(fb_rst)
    );
	

    pattern_vg #(
        .B(8), // Bits per channel
        .X_BITS(12),
        .Y_BITS(12),
        .FRACTIONAL_BITS(12)) // Number of fractional bits for ramp pattern
    pattern_vg (
        .reset(reset),
        .clk_in(HDMI_TX_CLK),
        .x(x_out),
        .y(y_out[11:0]),
        .vn_in(vs),
        .hn_in(hs),
        .dn_in(de),
        .r_in(8'h0), // default red channel value
        .g_in(8'h0), // default green channel value
        .b_in(8'h0), // default blue channel value
        .vn_out(vs_out),
        .hn_out(hs_out),
        .den_out(de_out),
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out),
        .total_active_pix(H_TOTAL - (H_FP + H_BP + H_SYNC)), // (1920) // h_total - (h_fp+h_bp+h_sync)
        .total_active_lines(INTERLACED ?
            (V_TOTAL_0 - (V_FP_0 + V_BP_0 + V_SYNC_0)) + (V_TOTAL_1 - (V_FP_1 + V_BP_1 + V_SYNC_1)) :
            (V_TOTAL_0 - (V_FP_0 + V_BP_0 + V_SYNC_0)) - 1), // originally: 13'd480
        .pattern(8'd6),
        .ramp_step(PATTERN_RAMP_STEP)
    );


    wire	[23:0]	cam_data_tst;
    wire	[7:0]	r_out;
    wire	[7:0]	g_out;
    wire	[7:0]	b_out;
    wire			de;
    wire			vs;
    wire			hs;
    wire			vs_out;
    wire			hs_out;
    wire			de_out;

    assign cam_data_tst = {r_out, g_out, b_out};
    assign HDMI_TX_DE = de_out;
    assign HDMI_TX_HS = hs_out;
    assign HDMI_TX_VS = vs_out;
endmodule
