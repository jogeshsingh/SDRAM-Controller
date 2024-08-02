`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2024 07:23:03 PM
// Design Name: 
// Module Name: wr_rd_data_fsm
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

`define RAM_ADDR_W 24
//`define BURST_LEN 2
`define DQ_WIDTH 16

module wr_rd_data_fsm(
 input i_clk ,
 input i_rst , 
 
 input i_self_refresh_done , 
 input wr_burst_data_req_0 , 
 input wr_burst_finish ,
 input i_wr_done , 
 input precharge_done , 
 input i_rd_done , 
 
 output o_wr_req  , 
 output o_rd_req  , 
 output [`DQ_WIDTH-1:0] wr_data , 
 
 output [`RAM_ADDR_W-1:0] wr_burst_addr 
 
    );


// read request sdram controller 
reg rd_req  = 0;

// write request to sdram controller 
reg wr_req  = 0;

// state register 
reg [2:0] p_state = 0;

/////////////////////////////////////////////
// fsm states
////////////////////////////////////////////

parameter WAIT_DONE          = 0 ;
parameter WAIT_WR_BURST_REQ  = 1 ;
parameter WAIT_WR_DATA_BURST = 2 ;
parameter IDLE_WAIT          = 3 ;
parameter WAIT_PRECHRAGE     = 4 ;
parameter RD_DATA            = 5 ;
parameter DONE               = 6 ;

////////////////////////////////////////////
///////////////////////////////////////////

// data to be written into sdram memory
reg [`DQ_WIDTH-1:0] data_write = 0;

reg [`RAM_ADDR_W -1 :0] col_sdram_addr = 0; 

assign wr_burst_addr  = col_sdram_addr ;

assign  wr_data  = data_write ;

assign o_wr_req  = wr_req ;
assign o_rd_req  = rd_req ;


////////////////////////// ////////  ////////////
//////            //////   ////       ////
///       fsm   /////       /////  ///   ////
/////////////////////// //////     ///    /////

always @(posedge i_clk) begin
  if (i_rst == 1'b1) begin
     p_state = 0;
     rd_req  = 0;
     wr_req  = 0;
    // burst_cnt  = 0;
     data_write = 0;
  end 
  else
    begin
              case (p_state)
        
      WAIT_DONE : begin
                       if (i_self_refresh_done) begin
                         p_state <= WAIT_WR_BURST_REQ ;
                         wr_req     <= 1'b1;
                       end 
                       else                    
                         p_state <= WAIT_DONE ;
                  end 
      
      
      
      WAIT_WR_BURST_REQ : begin
                             wr_req <= 1'b0;
                            if (wr_burst_data_req_0)
                              begin
                               data_write <= data_write + 16'b10 ;
                               p_state    <= WAIT_WR_DATA_BURST ;
                           end 
                           else
                               p_state    <= WAIT_WR_BURST_REQ ;                             
                         end 
                        
      WAIT_WR_DATA_BURST : begin
                                if (wr_burst_finish) begin
                                  data_write <= 0;
                                  p_state <= IDLE_WAIT ;
                               end 
                               else
                                 begin
                                   data_write <= data_write + 16'b10 ;
                                   p_state    <= WAIT_WR_DATA_BURST ;
                                  end 
                              end 

                                         
                        
      IDLE_WAIT :  begin
                       if(i_wr_done)begin
                           p_state <= WAIT_PRECHRAGE ;
                         end 
                       else
                          p_state <= IDLE_WAIT ;
                      end  
         
       WAIT_PRECHRAGE : begin
                          if (precharge_done) begin
                              rd_req <= 1'b1 ;
                              p_state <= RD_DATA ;
                          end 
                          else
                              p_state <= WAIT_PRECHRAGE ;
                         end                     
      RD_DATA : begin
                          if (i_rd_done)begin
                              rd_req <= 1'b0 ;
                              p_state <= DONE ;
                          end 
                          else
                             p_state  <= RD_DATA ;
                     end 
           
        DONE : p_state <= DONE ;
       default : p_state <= WAIT_DONE ;
       endcase
       end 
      end 
                                            
                                    
                            
                          
             
              
              
              
     




endmodule
