`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2024 07:45:40 PM
// Design Name: 
// Module Name: top_design
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


module top_design
#(

	parameter T_RP                    =  4,     // precharge command period
	parameter T_RC                    =  6,     // ACTIVE-to-ACTIVE command period
	parameter T_MRD                   =  6,     // LOAD MODE REGISTER command to ACTIVE or REFRESH command
	parameter T_RCD                   =  2,     // ACTIVE-to-READ or WRITE delay
	parameter T_WR                    =  3,     // Write Recovery Time
	parameter CASn                    =  3,    
	parameter SDR_BA_WIDTH            =  2,       // SDRAM Bus Address width
	parameter SDR_ROW_WIDTH           =  13,      // SDRAM Row Address width
	parameter SDR_COL_WIDTH           =  9,      // SDRAM Column Address width
	parameter SDR_DQ_WIDTH            =  16,      //   // SDRAM Data In/Out width
	parameter SDR_DQM_WIDTH           =  SDR_DQ_WIDTH/8,    //DQM is sampled HIGH and is an input mask signal for write accesses and an output enable signal for read accesses.
	parameter APP_ADDR_WIDTH          =  SDR_BA_WIDTH + SDR_ROW_WIDTH + SDR_COL_WIDTH,
	parameter APP_BURST_WIDTH         =  10  
    )
    (
    
   input                             clk,
	input                             rst,                 //reset signal,high for reset
	
	//read 
   output[SDR_DQ_WIDTH-1:0]          rd_burst_data,       //  read data to internal
	output                            rd_burst_data_valid ,//  read data enable (valid)
	
	
	// SRAM signals
	output                            sdram_cke,           //clock enable
	output                            sdram_cs_n,          //chip select
	output                            sdram_ras_n,         //row select
	output                            sdram_cas_n,         //column select
	output                            sdram_we_n,          //write enable
	output[SDR_BA_WIDTH-1:0]          sdram_ba,            //bank address
	output[SDR_ROW_WIDTH-1:0]         sdram_addr,          //address
	output[SDR_DQM_WIDTH-1:0]         sdram_dqm,           //data mask
	inout[SDR_DQ_WIDTH-1: 0]          sdram_dq             //data
	
	
    );
  
    
      wire self_refresh_done_st ; 
      wire wrt_done             ;
      wire precharge_dn         ;
      wire rd_dne               ;
      wire wr_burst_data_req    ;
      wire wr_burst_finish      ;
      
      
     wire [SDR_DQ_WIDTH-1:0] wr_data;
     wire [APP_ADDR_WIDTH-1:0 ] wr_burst_addr ;
    
     wire wr_burst_req  ;
    
     localparam wr_burst_len  = 3;
     localparam rd_burst_len  = 3;
    
     sdram_core
#
  (
	  .T_RP                    (T_RP                ) ,   
	  .T_RC                    (T_RC                ) ,   
	  .T_MRD                   (T_MRD               ) ,   
	  .T_RCD                   (T_RCD               ) ,   
	  .T_WR                    (T_WR                ) ,   
	  .CASn                    (CASn                ) ,   
	  .SDR_BA_WIDTH            (SDR_BA_WIDTH        ) ,   
	  .SDR_ROW_WIDTH           (SDR_ROW_WIDTH       ) ,   
	  .SDR_COL_WIDTH           (SDR_COL_WIDTH       ) ,   
	  .SDR_DQ_WIDTH            (SDR_DQ_WIDTH        ) ,   
	  .SDR_DQM_WIDTH           (SDR_DQM_WIDTH       ) ,   
	  .APP_ADDR_WIDTH          (APP_ADDR_WIDTH      ) ,   
	  .APP_BURST_WIDTH         (APP_BURST_WIDTH     )    
  )
  uo_sdram_controller(
	          .clk  (clk),
	          .rst  (rst),                 //reset signal,high for reset
	//write
	          .wr_burst_req (wr_burst_req),        //  write request
	          .wr_burst_data(wr_data),       //  write data
	          .wr_burst_len (wr_burst_len),        //  write data length, ahead of wr_burst_req
	          .wr_burst_addr(0),       //  write base address of sdram write buffer
	          .wr_burst_data_req(wr_burst_data_req),   //  wrtie data request, 1 clock ahead
	          .wr_burst_finish(wr_burst_finish),     //  write data is end
	          
	          .rd_burst_req  (rd_burst_req),        //  read request
	          .rd_burst_len  (rd_burst_len),        //  read data length, ahead of rd_burst_req
	          .rd_burst_addr (0),       //  read base address of sdram read buffer
	          .rd_burst_data (rd_burst_data),       //  read data to internal
	          .rd_burst_data_valid(rd_burst_data_valid), //  read data enable (valid)
	          .rd_burst_finish(),     //  read data is end
	
	
            .self_refresh_done_st(self_refresh_done_st   ) ,    
            .wrt_done            (  wrt_done             ) ,  
            .precharge_dn        (  precharge_dn         ) ,  
            .rd_dne              (  rd_dne               ) ,  
	
	         //sdram  signals
	         .sdram_cke           (sdram_cke  ),           //clock enable
	         .sdram_cs_n          (sdram_cs_n ),          //chip select
	         .sdram_ras_n         (sdram_ras_n),         //row select
	         .sdram_cas_n         (sdram_cas_n),         //column select
	         .sdram_we_n          (sdram_we_n ),          //write enable
	         .sdram_ba            (sdram_ba   ),            //bank address
	         .sdram_addr          (sdram_addr ),          //address
	         .sdram_dqm           (sdram_dqm  ),           //data mask
	         .sdram_dq            (sdram_dq   )         //data
);

 
 
   wr_rd_data_fsm
     uo_wr_fsm(
             .i_clk (clk),
             .i_rst (rst), 
             .i_self_refresh_done(self_refresh_done_st) , 
             .wr_burst_data_req_0(wr_burst_data_req) , 
             .wr_burst_finish    (wr_burst_finish) , 
             .i_wr_done          (wrt_done          ) , 
             .precharge_done     (precharge_dn     ) , 
             .i_rd_done          (rd_dne        ) , 
             .o_wr_req           (wr_burst_req) , 
             .o_rd_req           (rd_burst_req) , 
             .wr_data            (wr_data)  , 
             .wr_burst_addr      ()
             );



endmodule
