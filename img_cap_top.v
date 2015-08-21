/*
-------------------------------------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team 11
California State University, Sacramento
Spring 2015 / Fall 2015
-------------------------------------------------------------------------------

Stereoscopic Image Capture Top Level Module
Authors:	Padraic Hagerty (guitarisrockin@hotmail.com)
			Greg M. Crist, Jr. (gmcrist@gmail.com)

Description:
	This is the final top level design for the stereoscopic image capture
	system.
*/

`timescale 1 ns / 1 ns

module img_cap_top #(
        parameter  CAM1_CHIP_ADDR = 8'hCD,
                   CAM2_CHIP_ADDR = 8'hCD,
                   ADV7513_CHIP_ADDR = 7'h39,
                   ADV7513_I2C_CLKDIV = 12'd125
    )(
        // Clocks (obviously)
        (*
            chip_pin = "R20",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CLOCK_50_B5B,
        (*
            chip_pin = "N20",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CLOCK_50_B6A,

        // Reset (super obvious)
        (*
            chip_pin = "AB24",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CPU_RESET_n,

        // HDMI-TX via ADV7513
        (*
            chip_pin = "Y25",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          HDMI_TX_CLK,
        (*
            chip_pin = "Y26",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          HDMI_TX_DE,
        (*
            chip_pin = "U26",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          HDMI_TX_HS,
        (*
            chip_pin = "U25",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          HDMI_TX_VS,
        (*
            chip_pin = "AD25, AC25, AB25, AA24, AB26, R26, R24, P21, P26, N25, P23, P22, R25, R23, T26, T24, T23, U24, V25, V24, W26, W25, AA26, V23",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output  [23:0]  HDMI_TX_D,
        (*
            chip_pin = "T12",
            altera_attribute = "-name IO_STANDARD \"1.2 V\""
        *)
        input           HDMI_TX_INT,

        // External I2C bus for HDMI-TX
        (*
            chip_pin = "B7",
            altera_attribute = "-name IO_STANDARD \"2.5 V\""
        *)
        inout           I2C_SCL,
        (*
            chip_pin = "G11",
            altera_attribute = "-name IO_STANDARD \"2.5 V\""
        *)
        inout           I2C_SDA,

        // Status LEDs
        (*
            chip_pin = "J10, H7, K8, K10, J7, J8, G7, G6, F6, F7",
            altera_attribute = "-name IO_STANDARD \"2.5 V\""
        *)
        output  [9:0]   LEDR,
        (*
            chip_pin = "H9, H8, B6, A5, E9, D8, K6, L7",
            altera_attribute = "-name IO_STANDARD \"2.5 V\""
        *)
        output  [7:0]   LEDG,

        // Debounced push buttons
        (*
            chip_pin = "Y16, Y15, P12, P11",
            altera_attribute = "-name IO_STANDARD \"1.2 V\""
        *)
        input   [3:0]   KEY,


        // Camera Interfaces

        // Shared Pins
        (*
            chip_pin = "F26",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          CAM_XCLK,   // Cam 1 & 2 XCLK (GPIO 16)

        (*
            chip_pin = "W20",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          CAM_RESET,  // Cam 1 & 2 RESET (GPIO 28)

        (*
            chip_pin = "G26",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          CAM_PWDN,   // Cam 1 & 2 PWDN (GPIO 18)

        // CAM 1 Pins
        (*
            chip_pin = "T21",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM1_PCLK,  // Cam 1 PCLK (GPIO 0)

        (*
            chip_pin = "U19",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM1_HREF,  // Cam 1 HREF (GPIO 10)

        (*
            chip_pin = "U22",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM1_VSYNC, // Cam 1 VSYNC (GPIO 11)

        (*
            chip_pin = "T19",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          CAM1_SDIOC, // Cam 1 SDIOC (GPIO 9)

        (*
            chip_pin = "P8",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        inout           CAM1_SDIOD, // Cam 1 SDIOD (GPIO 12)

        (*
            chip_pin = "P20, R9, M26, T22, E26, M21, D26, K26",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input   [7:0]   CAM1_DATA,      // Cam 1 Data (GPIO 7, 14, 5, 8, 3, 6, 1, 4)


        // CAM 2 Pins
        (*
            chip_pin = "K25",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM2_PCLK,  // Cam 2 PCLK (GPIO 2)

        (*
            chip_pin = "V20",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM2_HREF,  // Cam 2 HREF (GPIO 26)

        (*
            chip_pin = "R8",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input           CAM2_VSYNC, // Cam 2 VSYNC (GPIO 13)

        (*
            chip_pin = "R10",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        output          CAM2_SDIOC, // Cam 2 SDIOC (GPIO 15)

        (*
            chip_pin = "W21",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        inout           CAM2_SDIOD, // Cam 2 SDIOD (GPIO 27)

        (*
            chip_pin = "V22, AA7, AD6, AD7, AA6, U20, Y8, Y9",
            altera_attribute = "-name IO_STANDARD \"3.3-V LVTTL\""
        *)
        input   [7:0]   CAM2_DATA,  // Cam 2 Data (GPIO 25, 20, 23, 22, 21, 24, 19, 17)


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
	assign LEDR[9:1] = 9'h0;
	assign LEDG[7:1] = 7'h0;
	assign LEDG[0] = pass;
	assign LEDR[0] = fail;

	/* Declare assertion parameters */
	localparam
		ASSERT_H = 1'b1,
		DEASSERT_H = 1'b0,
		ASSERT_L = 1'b0,
		DEASSERT_L = 1'b1;

	/* Declare the required test signals */
	parameter   	TST_PATT = 24'hFFFFFF;
	wire        	wr_en_in0,
					rd_en_in0;
	reg         	pass,
					fail;
	reg 	[31:0]  valid_rd_data,
					rd_cnt;
	wire	[28:0]	wr_addr0,
					rd_addr0;

	/* Test block for determining pass or failure */
	always @(posedge clk_25_2m)
		if (~reset) begin
			fail <= DEASSERT_H;
			pass <= DEASSERT_H;
		end else if ((valid_rd_data[23:0] != TST_PATT && rd_cnt != 0) || rd_cnt > 6)
			fail <= ASSERT_H;
		else if (rd_addr0 == 29'd2 && rd_cnt == 6)
			pass <= ASSERT_H;

	/* Assign the test pattern to the write data signal */
	assign wr_data0 = TST_PATT;

	/* Latch the read data when it's valid */
	always @(posedge clk_25_2m)
		if (~reset)
			rd_cnt <= 32'h0;
		else if (rd_data_valid) begin
			valid_rd_data <= rd_data0;
			rd_cnt <= rd_cnt + 1;
		end

	/* Send the pixel clock to the ADV7513 */
	assign HDMI_TX_CLK = clk_25_2m;

	/* Instantiate In-System Sources and Probes */
	/*ISSP ISSP_inst(
		.source_clk(clk_25_2m),
		.source({wr_en_in0, rd_en_in0, reset}),
		.probe({pass, fail})
	);*/

	/* Declare the required interconnections */
	wire            reset;

	wire    [31:0]  wr_data0,
					rd_data0,
					wr_data1,
					rd_data1,
					wr_data2,
					rd_data2,
					wr_data3,
					rd_data3;
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
	wire            rd_data_valid;

	wire            full;

	wire            clk_25_2m,
					pll_locked,
					us_tck,
					ms_tck;

	/* Assign IO pins to interconnection nets */


	/* Instantiate the required subsystems */

	/*debounce debounce_dat_ass (
		.clk(clk_25_2m),
		.rst(1'b0),
		.sig_in(CPU_RESET_n),
		.sig_out(reset)
	);*/
	assign reset = KEY[3];


	clocks cocks (
		.clk(CLOCK_50_B6A),
		.rst(reset),
		.pll_locked(pll_locked),
		.pll_outclk_0(clk_25_2m),
		.us_tck(us_tck),
		.ms_tck(ms_tck)
	);
	/*PLL pll_inst (
		.refclk(CLOCK_50_B6A),
		.rst(1'b0),
		.outclk_0(clk_25_2m),   // 25.2MHz for 640x480p @60Hz, 74.25MHz
								// for 1280x720p
		.locked(pll_locked)
	);*/

	frame_buf_alt
	#(
		.BUF_SIZE(5)
	) frame_buf0 (
		.wr_clk(clk_25_2m),
		.rd_clk(clk_25_2m),
		.reset(reset),
		.wr_en(KEY[1]),
		.rd_en(KEY[0]),
		.ram_rdy(ram_rdy),
		.avl_ready(avl_ready_0),
		.avl_write_req(avl_write_req_0),
		.avl_read_req(avl_read_req_0),
		.full(full),
		.wr_addr(wr_addr0),
		.rd_addr(rd_addr0),
		.avl_addr(avl_addr_0)
	);

	ram_int_4p mem_int (
		.wr_data0(wr_data0),
		.wr_data1(),
		.wr_data2(),
		.wr_data3(),
		.clk_50m(CLOCK_50_B5B),
		.clk(clk_25_2m),
		.reset(reset),
		.avl_write_req_0(),
		.avl_read_req_0(),
		.avl_write_req_1(),
		.avl_read_req_1(),
		.avl_write_req_2(),
		.avl_read_req_2(),
		.avl_write_req_3(),
		.avl_read_req_3(),
		.rd_data_valid0(rd_data_valid),
		.ram_rdy(ram_rdy),
		.avl_ready_0_fl(avl_ready_0),
		.avl_ready_1_fl(),
		.avl_ready_2_fl(),
		.avl_ready_3_fl(),
		.avl_addr_0(avl_addr_0),
		.avl_addr_1(),
		.avl_addr_2(),
		.avl_addr_3(),
		.rd_data0(rd_data0),
		.rd_data1(),
		.rd_data2(),
		.rd_data3(),
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

	img_cap_hdmi hdmi (
		.pix_clk(clk_25_2m),
		.reset(reset),
		.HDMI_TX_DE(HDMI_TX_DE),
		.HDMI_TX_HS(HDMI_TX_HS),
		.HDMI_TX_VS(HDMI_TX_VS),
		.I2C_SCL(I2C_SCL),
		.I2C_SDA(I2C_SDA),
		.i2c_reg_read(1'b0),
		.i2c_reg_addr(8'b0),
		.i2c_reg_data()
	);


    // Cameras Capture Interfaces

    assign CAM_XCLK = clk_25_2m;
    assign CAM_RESET = 1'b1;    // To do: Move to controller
    assign CAM_PWDN = 1'b0;     // To do: Move to controller

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
    wire cam1_pwdn;
    wire cam2_pwdn;
    
    wire init_start;
    wire init_done;
    
    // To do: generate a 100kHz clock signal for this
    wire clk_sccb;
    
    // To do: should we change this to AND?
    assign CAM_PWDN = cam1_pwdn || cam2_pwdn;
    
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
        .cam1_pwdn(cam1_pwdn),
        .cam1_sio_d(CAM1_SDIOD),
        .cam1_sio_c(CAM1_SDIOC),
        
        // SCCB for Camera 2 Initialization 
        .cam2_pwdn(cam2_pwdn),
        .cam2_sio_c(CAM2_SDIOD),
        .cam2_sio_d(CAM2_SDIOC),

        // I2C for ADV7513 Initialization
        .i2c_scl(I2C_SCL),
        .i2c_sda(I2C_SDA),

        // Memory init done input
        .mem_init_done(ram_rdy)
    );
    
    img_cap_ctrl img_cap_ctrl (
        .clk(clk_25_2m),
        .reset(reset),
        .init_start(init_start),
        .init_done(init_done)
    );
endmodule