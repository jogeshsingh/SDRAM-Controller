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

`define APP_ADDR_WIDTH 24
//`define BURST_LEN 2
 

module wr_rd_data_fsm
# (parameter BURST_ACCESS_TYPE = 2'b00, 
          // if BURST_ACCESS_TYPE = 2'b00 , -> burst type 
          //    BURST_ACCESS_TYPE = 2'b01 , -> single access location
          //    BURST_ACCESS_TYPE = 2'b10 , -> continuous burst  
   parameter BURST_LEN = 3'b000 
           // BURST_LEN = 3'b000 -> 1 (single access location) 
           // BURST_LEN = 3'b001 -> 2 (burst of length - 2 )
           // BURST_LEN = 3'b010 -> 4 (burst of length - 4 )
           // BURST_LEN = 3'b011 -> 8 (burst of length - 8 )
     )       
 (
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
 // data to be written to SDRAM through sdram controller fsm 
 output [15:0] wr_data , 
 // address to be provided to sdram controller fsm 
 output [`APP_ADDR_WIDTH-1:0] wr_burst_addr ,
 output [`APP_ADDR_WIDTH-1:0] rd_burst_addr  
 
    );


// read request sdram controller 
reg rd_req  = 0;

// write request to sdram controller 
reg wr_req  = 0;

// state register 
reg [3:0] p_state = 0;

/////////////////////////////////////////////
// fsm states
////////////////////////////////////////////

localparam  WAIT_DONE                 = 0 ;
localparam  WAIT_WR_BURST_SINGLE_REQ  = 1 ;
localparam  WAIT_WR_BURST_REQ         = 2 ;
localparam  WAIT_WR_DATA_SINGLE_BURST = 3 ;
localparam  WAIT_WR_DATA_BURST        = 4 ;
localparam  IDLE_WAIT                 = 5 ;
localparam  WAIT_PRECHRAGE            = 6 ;
localparam  RD_DATA                   = 7 ;
localparam  INCR_ROM_ADDR             = 8 ;

////////////////////////////////////////////
///////////////////////////////////////////

// data to be written into sdram memory
reg [15:0] data_write = 0;

reg [`APP_ADDR_WIDTH -1 :0] wr_sdram_addr = 0; 
reg [`APP_ADDR_WIDTH -1 :0] rd_sdram_addr = 0; 


// reg - check the column address boundary - 512
// increment counter has to be selected based upon burst type
// for burst len = 2 , +2
// for burst len = 4 , +4 
// for burst len = 8 , +8
// for burst len = 1 , +1 (single location access)
reg [9:0] addr_counter = 0;



// assign write and read addresses
assign wr_burst_addr  = wr_sdram_addr ;
assign rd_burst_addr  = rd_sdram_addr ;

// assign the data 
assign  wr_data  = data_write ;

// assign the write and read requests
assign o_wr_req  = wr_req ;
assign o_rd_req  = rd_req ;


////////////////////////// ////////  ////////////
//////            //////   ////       ////
///       fsm   /////       /////  ///   ////
/////////////////////// //////     ///    /////

always @(posedge i_clk) begin
  if (i_rst == 1'b1) begin
     p_state       <= 0;
     rd_req        <= 0;
     wr_req        <= 0;
     wr_sdram_addr <= 0;
     rd_sdram_addr <= 0;
     data_write    <= 0;
     addr_counter  <= 0;
  end 
  else
    begin
              case (p_state)
        
         WAIT_DONE : begin
                          if (i_self_refresh_done) begin
                                   wr_req <= 1'b1;
                                case (BURST_ACCESS_TYPE)
                                2'b00 : p_state <= WAIT_WR_BURST_REQ ;
                                2'b01 : p_state <= WAIT_WR_BURST_SINGLE_REQ ;
                               // 2'b10 : p_state <=
                                default : p_state <= WAIT_DONE ;
                               endcase
                          end 
                          else                    
                            p_state    <= WAIT_DONE        ;
                     end 
 
        WAIT_WR_BURST_SINGLE_REQ : begin
                                       wr_req <= 1'b0;
                                    if (wr_burst_data_req_0)begin
                                      data_write <= data_write + 16'b10 ;
                                      p_state    <= WAIT_WR_DATA_SINGLE_BURST ;
                                    end 
                                   else
                                     p_state     <= WAIT_WR_BURST_SINGLE_REQ ; 
                                  end 
         
         WAIT_WR_BURST_REQ : begin
                                  wr_req     <= 1'b0                ;
                               if (wr_burst_data_req_0)
                                 begin
                                  data_write <= data_write + 16'b10 ;
                                  p_state    <= WAIT_WR_DATA_BURST  ;
                              end 
                              else
                                  p_state    <= WAIT_WR_BURST_REQ   ;                             
                             end 
        
         WAIT_WR_DATA_SINGLE_BURST : begin
                                       data_write   <= data_write            ;
                                   if (wr_burst_finish && BURST_ACCESS_TYPE) begin
                                      wr_sdram_addr <=  wr_sdram_addr + 1'b1 ;
                                      p_state       <= IDLE_WAIT             ;
                                   end 
                               end  
                        
         WAIT_WR_DATA_BURST : begin
         
                                   if (wr_burst_finish) begin
                                               data_write     <= data_write              ;
                                               p_state        <= IDLE_WAIT               ;                                   
                                     case (BURST_LEN)
                                       3'b001 : wr_sdram_addr  <= wr_sdram_addr + 24'b010  ;  // 2
                                       3'b010 : wr_sdram_addr  <= wr_sdram_addr + 24'b100  ;  // 4
                                       3'b011 : wr_sdram_addr  <= wr_sdram_addr + 24'b1000 ;  // 8
                                     default : wr_sdram_addr  <= 0                       ;
                                      endcase                                
                                  end 
                                  else
                                    begin
                                      data_write <= data_write + 16'b10 ;
                                      p_state    <= WAIT_WR_DATA_BURST ;
                                     end 
                                 end 
                           
         IDLE_WAIT :      begin
                                wr_sdram_addr <= wr_sdram_addr ;
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
                                    
                                    case (BURST_LEN)
                                      3'b000   : addr_counter  <= addr_counter + 10'b001  ;  // 1
                                      3'b001   : addr_counter  <= addr_counter + 10'b010  ;  // 2
                                      3'b010   : addr_counter  <= addr_counter + 10'b100  ;  // 4
                                      3'b011   : addr_counter  <= addr_counter + 10'b1000 ; // 8
                                      default : addr_counter  <= 0                       ;
                                    endcase
                                  
                                   case (BURST_LEN)
                                       3'b000 : rd_sdram_addr  <= rd_sdram_addr + 24'b001  ;  // 1
                                       3'b001 : rd_sdram_addr  <= rd_sdram_addr + 24'b010  ;  // 2
                                       3'b010 : rd_sdram_addr  <= rd_sdram_addr + 24'b100  ;  // 4
                                       3'b011 : rd_sdram_addr  <= rd_sdram_addr + 24'b1000 ;  // 8
                                     default : rd_sdram_addr  <= 0                       ;
                                      endcase    
                                  
                                 if ( addr_counter == 10'd512)    // if column address has reached a 0-511 (512) locations , then increment the row address
                                       p_state <= INCR_ROM_ADDR ;
                                    else
                                       p_state <= WAIT_DONE ;
                             end 
                                else
                                     p_state  <= RD_DATA ;
                           end
                       
         INCR_ROM_ADDR : p_state <= INCR_ROM_ADDR ;
        
           
        default : p_state <= WAIT_DONE ;
       endcase
       end 
      end 
                                            
                                    
                            
                          
             
              
              
              
     




endmodule
