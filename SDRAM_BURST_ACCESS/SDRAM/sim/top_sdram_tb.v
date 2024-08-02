`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2024 10:11:55 PM
// Design Name: 
// Module Name: top_sdram_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_sdram_tb();
    
     // Parameters
  parameter T_RP = 4;
  parameter T_RC = 6;
  parameter T_MRD = 6;
  parameter T_RCD = 2;
  parameter T_WR = 3;
  parameter CASn = 3;
  parameter SDR_BA_WIDTH = 2;
  parameter SDR_ROW_WIDTH = 13;
  parameter SDR_COL_WIDTH = 9;
  parameter SDR_DQ_WIDTH = 16;
  parameter SDR_DQM_WIDTH = SDR_DQ_WIDTH / 8;
  parameter APP_ADDR_WIDTH = SDR_BA_WIDTH + SDR_ROW_WIDTH + SDR_COL_WIDTH;
  parameter APP_BURST_WIDTH = 10;

  // Inputs
  reg clk;
  reg rst;
//  reg wr_burst_req;
//  reg [SDR_DQ_WIDTH-1:0] wr_burst_data;
//  reg [APP_BURST_WIDTH-1:0] wr_burst_len;
//  reg [APP_ADDR_WIDTH-1:0] wr_burst_addr;
//  reg rd_burst_req;
//  reg [APP_BURST_WIDTH-1:0] rd_burst_len;
//  reg [APP_ADDR_WIDTH-1:0] rd_burst_addr;

  // Outputs
//  wire wr_burst_data_req;
//  wire wr_burst_finish;
  wire [SDR_DQ_WIDTH-1:0] rd_burst_data;
  wire rd_burst_data_valid;
//  wire rd_burst_finish;
  wire sdram_cke;
  wire sdram_cs_n;
  wire sdram_ras_n;
  wire sdram_cas_n;
  wire sdram_we_n;
  wire [SDR_BA_WIDTH-1:0] sdram_ba;
  wire [SDR_ROW_WIDTH-1:0] sdram_addr;
  wire [SDR_DQM_WIDTH-1:0] sdram_dqm;
  wire [SDR_DQ_WIDTH-1:0] sdram_dq;

  // Instantiate the Unit Under Test (UUT)
  top_sdram_controller #(
    .T_RP(T_RP),
    .T_RC(T_RC),
    .T_MRD(T_MRD),
    .T_RCD(T_RCD),
    .T_WR(T_WR),
    .CASn(CASn),
    .SDR_BA_WIDTH(SDR_BA_WIDTH),
    .SDR_ROW_WIDTH(SDR_ROW_WIDTH),
    .SDR_COL_WIDTH(SDR_COL_WIDTH),
    .SDR_DQ_WIDTH(SDR_DQ_WIDTH),
    .SDR_DQM_WIDTH(SDR_DQM_WIDTH),
    .APP_ADDR_WIDTH(APP_ADDR_WIDTH),
    .APP_BURST_WIDTH(APP_BURST_WIDTH)
  ) uut (
    .clk(clk),
    .rst(rst),
     
  //   .rd_burst_data(rd_burst_data),       //  read data to internal
   //  .rd_burst_data_valid(rd_burst_data_valid) ,//  read data enable (valid)
	
	
     
     
    .sdram_cke(sdram_cke),
    .sdram_cs_n(sdram_cs_n),
    .sdram_ras_n(sdram_ras_n),
    .sdram_cas_n(sdram_cas_n),
    .sdram_we_n(sdram_we_n),
    .sdram_ba(sdram_ba),
    .sdram_addr(sdram_addr),
    .sdram_dqm(sdram_dqm),
    .sdram_dq(sdram_dq),
    
    .o_led_receive_done()
  );


// Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk; // 20 MHz clock
  end


 initial begin
    // Initialize Inputs
    rst = 1;
    

    // Wait for global reset
    #100;
    rst = 0;
  end 


endmodule
