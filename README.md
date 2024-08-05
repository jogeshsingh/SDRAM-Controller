## SDRAM Controller : Implementation for Writing and Reading Data to/from SDRAM in FPGA

 SDRAM -: `MT48LC16M16A2 – 4 Meg x 16 x 4 banks`

 [DOC](https://www.alldatasheet.com/datasheet-pdf/pdf/75870/MICRON/MT48LC16M4A2.html)


## Note -: 

   USER IS REQUIRED TO PAY CLOSE ATTENTION TO TOP LEVEL PARAMETERS IN RTL CODE as DESCRIBED FOLLOWING , FOR 

   CHOOSING THE `SINGLE_BURST_ACCESS` , `MULTIPLE_BURST_ACCESS(2, 4, 8)`


   ///////////////////////////////////////////
   //////////////////////////////////////////
   
   // write and read burst length in count              
   
   // BL          = 000 ,     = 1 burst of data
   
   // for BL      = 001 ,     = 2 burst of data
   
   // for BL      = 010 ,     = 4 burst of data
   
   // for BL      = 011 ,     = 8 burst of data
   
   `parameter BL                      =  3'b000`  , 
   
   //    BURST_ACCESS_TYPE = 2'b00 , -> burst type ->  2, 4, 8 
   
   //    BURST_ACCESS_TYPE = 2'b01 , -> burst type -> 1 or single access location
   
   //    BURST_ACCESS_TYPE = 2'b10 , -> burts type -> continuous burst  
   
   `parameter BURST_ACCESS_TYPE = 2'b01` ,
   
   // for load mode register - 
   
   // Operation mode setting (set here to A9(BURST_OR_SINGLE_ACCESS_A9)=0, ie burst read / burst write)  
   
   // (set A9(BURST_OR_SINGLE_ACCESS_A9) = 1, for single location access)
   
  `parameter BURST_OR_SINGLE_ACCESS_A9 =1'b1` , 
   
   // BURST LENGTH , Load mode register parameters
   
   // for BL = 000 , {wr_burst_len,rd_burst_len} => 1 burst of data 
   
   // for BL = 001 , {wr_burst_len,rd_burst_len} => 2 burst of data
   
   // for BL = 010 , {wr_burst_len,rd_burst_len} => 4 burst of data 
   
   // for BL = 011 , {wr_burst_len,rd_burst_len} => 8 burst of data
   
   // 100 = full page (`NOT YET IMPLEMENTED`)
   
   `parameter wr_burst_len  = 1` , 
   `parameter rd_burst_len  = 1` , 



## Directories

  - There are mainly `3` directories for now -:

  - `SDRAM_C`  , `SDRAM_BURST_ACCESS` and `SDRAM_VIVADO_PROJECT`

  - `SDRAM_C` -: 
   
    - It includes `single burst access` and `multiple_burst_access(2 , 4, 8)` with user parameterization and 
      incrementing addressing logic.

    - This code should be used for more accurate view of `incrementing` addresses in case of `single burst` , `multiple burst` 
      and `continuous burst`(`yet to be implemented`).

  - `SDRAM_BURST_ACCESS` -: 
              
    - It includes `multiple_burst_access(2 , 4, 8)` with `no`  incrementing addressing logic and it just sends 
      burst only once (means one burst of either `2` , `4` or `8`) as `FSM` is halted in `DONE` state.
              
    - `User` may have to implement incrementing addressing logic in this `as` included in  `SDRAM_C` folder

  - `SDRAM_VIVADO_PROJECT` -:

   - It includes the complete `VIVADO Project` for `single burst access` and `multiple_burst_access(2 , 4, 8)`

     **Note** -: *VIVADO_VERSION-: 2020.2*  


  - Directories 

    - `SDRAM_C`
    
      - `Constraints`
    
      - `rtl`
         
      - `sim`
         
      - `sim_img`
         
      - `README.md`

**Source files**

  - `rtl`

     - `Sdram_controller.v`

     -  `top_sdram_controller.v`

     -  `wr_rd_data_fsm.v`

  - `sim`

    -  `top_sdram_tb.v`
  