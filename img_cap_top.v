/*
--------------------------------------------------
Stereoscopic Vision System
Senior Design Project - Team Honeybadger (Team 11)
California State University, Sacramento
Spring 2015 / Fall 2015
--------------------------------------------------

Stereoscopic Image Capture Top Level Module
Authors: Padraic Hagerty (guitarisrockin@hotmail.com)

Description:
  The final top level design for the stereoscopic image capture system.
*/

`ifndef ASSERT_L
`define ASSERT_L 1'b0
`define DEASSERT_L 1'b1
`endif
`ifndef ASSERT_H
`define ASSERT_H 1'b1
`define DEASSERT_H 1'b0
`endif

`timescale 1 ps / 1 ps

module img_cap_top(
  input CLOCK_50_B5B, CLOCK_50_B7A, CLOCK_125_p,// reset,
  output  [9:0]   mem_ca,
  output          mem_ck,
  output          mem_ck_n,
  output          mem_cke,
  output          mem_cs_n,
  output  [3:0]   mem_dm,
  inout   [31:0]  mem_dq,
  inout   [3:0]   mem_dqs,
  inout   [3:0]   mem_dqs_n,
  input           oct_rzqin
);

  /* Declare the required test signals */
  parameter     TST_PATT = 32'hFFFFFFFF;
  wire          wr_en_in0, rd_en_in0;
  reg           pass, fail;
  
  /* Test block for determining pass or failure */
  always @(posedge CLOCK_125_p)
    if (reset == `ASSERT_L) begin
      fail <= `DEASSERT_H;
      pass <= `DEASSERT_H;
    end else if (rd_data0 != TST_PATT && rd_data_valid == `ASSERT_H)
      fail <= `ASSERT_H;
    else if (rd_addr0 == 29'd502)
      pass <= `ASSERT_H;

  
  /* Declare the required internal signals */
  wire  [31:0]  wr_data0, rd_data0, wr_data1, rd_data1, wr_data2, rd_data2,
                wr_data3, rd_data3;
  wire  [23:0]  wr_addr0, rd_addr0, wr_addr1, rd_addr1, wr_addr2, rd_addr2,
                wr_addr3, rd_addr3;
  wire          wr_rdy0, rd_rdy0, wr_en0, rd_en0;
  wire          rd_data_valid;
  
  /* Instantiate the required subsystems */
  frame_buf_alt frame_buf0
    (
      .wr_clk(CLOCK_125_p),
      .rd_clk(CLOCK_125_p),
      .reset(reset),
      .wr_en_in(wr_en_in0),
      .rd_en_in(rd_en_in0),
      .wr_rdy(wr_rdy0),
      .rd_rdy(rd_rdy0),
      .wr_en(wr_en0),
      .rd_en(rd_en0),
      .wr_addr(wr_addr0),
      .rd_addr(rd_addr0)
    );
              
  ram_int_4p mem_int
    (
      .wr_addr0(wr_addr0),
      .rd_addr0(rd_addr0),
      .wr_addr1(),
      .rd_addr1(),
      .wr_addr2(),
      .rd_addr2(),
      .wr_addr3(),
      .rd_addr3(),
      .wr_data0(wr_data0),
      .wr_data1(),
      .wr_data2(),
      .wr_data3(),
      .CLOCK_50_B5B(CLOCK_50_B5B),
      .CLOCK_50_B7A(CLOCK_50_B7A),
      .wr_en0(wr_en0),
      .wr_en1(),
      .wr_en2(),
      .wr_en3(),
      .rd_en0(rd_en0),
      .rd_en1(),
      .rd_en2(),
      .rd_en3(),
      .reset(reset),
      .rd_data_valid(rd_data_valid),
      .wr_rdy0(wr_rdy0),
      .rd_rdy0(rd_rdy0),
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
 
endmodule