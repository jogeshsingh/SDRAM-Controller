`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: top_sdram_controller
//////////////////////////////////////////////////////////////////////////////////


module top_sdram_controller
#(
   ///////////////////////////////////////////
   //////////////////////////////////////////
   // write and read burst length in count              
   // BL          = 000 ,     = 1 burst of data
   // for BL      = 001 ,     = 2 burst of data
   // for BL      = 010 ,     = 4 burst of data
   // for BL      = 011 ,     = 8 burst of data
   parameter BL                      =  3'b000  , 
   //    BURST_ACCESS_TYPE = 2'b00 , -> burst type ->  2, 4, 8 
   //    BURST_ACCESS_TYPE = 2'b01 , -> burst type -> 1 or single access location
   //    BURST_ACCESS_TYPE = 2'b10 , -> burts type -> continuous burst  
   parameter BURST_ACCESS_TYPE = 2'b01 ,
   
   // for load mode register - 
   // Operation mode setting (set here to A9(BURST_OR_SINGLE_ACCESS_A9)=0, ie burst read / burst write)  
   // (set A9(BURST_OR_SINGLE_ACCESS_A9) = 1, for single location access)
   parameter BURST_OR_SINGLE_ACCESS_A9 =1'b1 , 
   // BURST LENGTH , Load mode register parameters
    // for BL = 000 , {wr_burst_len,rd_burst_len} => 1 burst of data 
   // for BL = 001 , {wr_burst_len,rd_burst_len} => 2 burst of data
   // for BL = 010 , {wr_burst_len,rd_burst_len} => 4 burst of data 
   // for BL = 011 , {wr_burst_len,rd_burst_len} => 8 burst of data
   
   parameter wr_burst_len  = 1 , 
   parameter rd_burst_len  = 1 , 
     
   // Timing Parameters
	parameter T_RP                    =  4,     // precharge command period
	parameter T_RC                    =  6,     // ACTIVE-to-ACTIVE command period
	parameter T_MRD                   =  6,     // LOAD MODE REGISTER command to ACTIVE or REFRESH command
	parameter T_RCD                   =  2,     // ACTIVE-to-READ or WRITE delay
	parameter T_WR                    =  3,     // Write Recovery Time
	parameter CASn                    =  2,      // CAS Latency
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

	// SRAM signals
   output                            sdram_clk,         //sdram clock
	output                            sdram_cke,           //clock enable
	output                            sdram_cs_n,          //chip select
	output                            sdram_ras_n,         //row select
	output                            sdram_cas_n,         //column select
	output                            sdram_we_n,          //write enable
	output[SDR_BA_WIDTH-1:0]          sdram_ba,            //bank address
	output[SDR_ROW_WIDTH-1:0]         sdram_addr,          //address
	output[SDR_DQM_WIDTH-1:0]         sdram_dqm,           //data mask
	inout[SDR_DQ_WIDTH-1: 0]          sdram_dq  ,        //data
	
	// data received 
	output o_led_receive_done
	
    );
  
    	//read 
     //(*KEEP = "true"*)
      wire [SDR_DQ_WIDTH-1:0]          rd_burst_data ;     //  read data to internal
	  //(*KEEP = "true"*)
	   wire                             rd_burst_data_valid ;//  read data enable (valid)
      
      wire self_refresh_done_st               ; 
      wire wrt_done                           ;
      wire precharge_dn                       ;
      wire rd_dne                             ;
      wire wr_burst_data_req                  ;
      wire wr_burst_finish                    ;
      
      (*KEEP = "true"*)
      wire [SDR_DQ_WIDTH-1:0]    wr_data       ;
      wire [APP_ADDR_WIDTH-1:0 ] wr_burst_addr ;
      wire [APP_ADDR_WIDTH-1:0 ] rd_burst_addr ;
      wire wr_burst_req                        ;
    
      
    
     
     /////////////////////////////////////////////////
     
     assign o_led_receive_done  = (rd_burst_data !=0 && rd_burst_data_valid) ;
    
     wire clk_out1;
    
    clk_wiz_0 clk_wizard
    (
    // Clock out ports
    .clk_out1(clk_out1),     // output clk_out1
   // Clock in ports
    .clk_in1(clk)
     );      // input clk_in1

 
// 	 //sdram_clk(clk input to sdram) is 180 degrees lagging from main clock to solve the hold-setup time requirements of sdram
//	 ODDR2#(.DDR_ALIGNMENT("NONE"), .INIT(1'b0),.SRTYPE("SYNC")) oddr2_primitive
//	 (
//		.D0(1'b0), //1'b0
//		.D1(1'b1 ), //1'b1
//		.C0(clk_out1),
//		.C1(~clk_out1),
//		.CE(1'b1),
//		.R(1'b0),
//		.S(1'b0),
//		.Q(s_clk)
//	);
      ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_inst (
      .Q(sdram_clk),   // 1-bit DDR output
      .C(clk_out1),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b1), // 1-bit data input (positive edge)
      .D2(1'b0), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
 
 
 
 
    
     sdram_core
#
  (
	  .T_RP                    (T_RP                ) ,   
	  .T_RC                    (T_RC                ) ,   
	  .T_MRD                   (T_MRD               ) ,   
	  .T_RCD                   (T_RCD               ) ,   
	  .T_WR                    (T_WR                ) ,   
	  .CASn                    (CASn                ) ,   
	  .BL                      (BL                  ) ,      
	  .SDR_BA_WIDTH            (SDR_BA_WIDTH        ) ,   
	  .SDR_ROW_WIDTH           (SDR_ROW_WIDTH       ) ,   
	  .SDR_COL_WIDTH           (SDR_COL_WIDTH       ) ,   
	  .SDR_DQ_WIDTH            (SDR_DQ_WIDTH        ) ,   
	  .SDR_DQM_WIDTH           (SDR_DQM_WIDTH       ) ,   
	  .APP_ADDR_WIDTH          (APP_ADDR_WIDTH      ) ,   
	  .APP_BURST_WIDTH         (APP_BURST_WIDTH     ) , 
	  .BURST_OR_SINGLE_ACCESS_A9 (BURST_OR_SINGLE_ACCESS_A9)       // A9 = 0 , for read/write access , A9 = 1 , for single location access            
    
  )
  uo_sdram_controller(
	          .clk  (clk_out1),
	          .rst  (rst),                 //reset signal,high for reset
	//write
	          .wr_burst_req (wr_burst_req),        //  write request
	          .wr_burst_data(wr_data),       //  write data
	          .wr_burst_len (wr_burst_len),        //  write data length, ahead of wr_burst_req
	          .wr_burst_addr(wr_burst_addr),       //  write base address of sdram write buffer
	          .wr_burst_data_req(wr_burst_data_req),   //  wrtie data request, 1 clock ahead
	          .wr_burst_finish(wr_burst_finish),     //  write data is end
	          
	          .rd_burst_req  (rd_burst_req),        //  read request
	          .rd_burst_len  (rd_burst_len),        //  read data length, ahead of rd_burst_req
	          .rd_burst_addr (rd_burst_addr),       //  read base address of sdram read buffer
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
    #(.BURST_ACCESS_TYPE (BURST_ACCESS_TYPE), 
          //    BURST_ACCESS_TYPE = 2'b00 , -> burst type ->  2, 4, 8 
          //    BURST_ACCESS_TYPE = 2'b01 , -> burst type -> 1 or single access location
          //    BURST_ACCESS_TYPE = 2'b10 , -> burts type -> continuous burst  
     .BURST_LEN (BL)
           // BURST_LEN = 2'b00 -> 1 (single access location) 
           // BURST_LEN = 2'b01 -> 2 (burst of length - 2 )
           // BURST_LEN = 2'b10 -> 4 (burst of length - 4 )
           // BURST_LEN = 2'b11 -> 8 (burst of length - 8 )
     ) 
     uo_wr_fsm(
             .i_clk (clk_out1),
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
             .wr_burst_addr      (wr_burst_addr),
             .rd_burst_addr      (rd_burst_addr)
             );



endmodule
