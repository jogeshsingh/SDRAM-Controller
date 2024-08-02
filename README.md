## SDRAM Controller

 SDRAM -: `MT48LC16M16A2 – 4 Meg x 16 x 4 banks`

 [DOC](https://www.alldatasheet.com/datasheet-pdf/pdf/75870/MICRON/MT48LC16M4A2.html)




## Directories

  - There are mainly `2` directories for now -:

  - `SDRAM_C` and `SDRAM_BURST_ACCESS`

  - `SDRAM_C` -: 
   
    - It includes `single burst access` and `multiple_burst_access(2 , 4, 8)` with user parameterization and 
      incrementing addressing logic.

    - This code should be used for more accurate view of `incrementing` addresses in case of `single burst` , `multiple burst` 
      and `continuous burst`(`yet to be implemented`).

  - `SDRAM_BURST_ACCESS` -: 
              
    - It includes `multiple_burst_access(2 , 4, 8)` with `no`  incrementing addressing logic and it just sends 
      burst only once (means one burst of either `2` , `4` or `8`) as `FSM` is halted in `DONE` state.
              
    - `User` may have to implement incrementing addressing logic in this `as` included in  `SDRAM_C` folder





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
  