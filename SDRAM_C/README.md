## SDRAM Controller

> This Repository Contains a SDRAM Controller Verilog HDL Code for Interfacing SDRAM(Reading from and Writing to `SDRAM`)
  mounted on `ARTIX-A7 FPGA Board`


## FSM Controller For SDRAM



## Simulation Details


   - `Burst - 8 - on incrementing column addresses`

  ![SIM_BURST_8](sim_img/sim_burst_8_continuous.jpg)  

## Implementation Details  - Burst Mode - 8 

   - `IN ILA` - `Burst - 8 - on incrementing column addresses`
  
   ![W_1](sim_img/burst_8_cnt_1.jpg)
   
  

  - `Sdram_Address_r` [8:3] truncates to select the 4th[3] bit from `1000` in sdram controller logic , as you can see in 
  
    the second transaction(second burst) the address got `1` and so on it changes to `2` , `3` ... in consecutive 
  
    transactions. 

 - `Note` - that `1fff` in sdram_addr means every bit is high in address , that is considered like `don't care` when after 

   providing the `starting address` through `column address` for burst mode .

 - `for more info` -: check the data sheet in top `README file`


 - `Remember` -: In the **following** transaction through `ILA` , `sdr_dq_in` and `sdram_dq_obuf` are internal to
      
      `sdram controller` as , the sdram data is bidirectional , so `in` and `out` transactions are shown

      separately.
 
- `Let's take a Closer look at continuous read from different locations by writing the different data pattern`
  

  **First - burst of 8 bit - data being written through sdram_dq_OBUF**

  ![W_2](sim_img/burst_8_cnt_wr.jpg)

  **First - burst of 8 bit - data being read on sdr_dq_in**

  ![W_3](sim_img/burst_8_cnt_rd.jpg)

  **Second - burst of 8 bit - data being written through sdram_dq_OBUF**

  ![W_2](sim_img/burst_8_cnt_wr_2.jpg)

  **Second - burst of 8 bit - data being read on sdr_dq_in**

  ![W_3](sim_img/burst_8_cnt_rd_2.jpg)
   
 
 
  **Helpful note** 
     
     - `VIO` could be added by user to directly change the following parameters for 
                     accessing the different burst types -: 

     - `parameter BL` 
     
     - `parameter wr_burst_len` 
     
     - `parameter rd_burst_len` 

     - `parameter BURST_OR_SINGLE_ACCESS_A9 = 1'b0' - should be 0 for burst mode

     - `parameter BURST_ACCESS_TYPE = 2'b00` - should be 2'b00 for burst mode

 - `Leaving the above exercise for burst 2 & 4 for fellow learners`  


## Implementation Details - Single Mode access - burst - 1 

  - Below are the implemented design outputs -: `FPGA` to `SDRAM` & `SDRAM to FPGA` in `ILA` -: 

  - Single Mode Access

    **Simulation view**

    - `Wr_rd_data_fsm sim`

     ![wr_sim_single](sim_img/wr_fsm_single_access.jpg)


    - `sdram_controller sim for single access`

     ![sdram_single](sim_img/sdram_core_single_access_tb.jpg)  

    - This section describes the timing for `reading` and `writing` from/to single array location in `SDRAM`

  
    - `ILA view of reading and writing from/to sdram`

    ![ILA_S](sim_img/single_burst_ila.jpg)


    - **Single Write Access**

    - **First address**

     ![ILA_S_1](sim_img/single_burst_ila_w_1.jpg)

    - **Second address**

     ![ILA_S_2](sim_img/single_burst_ila_w_2.jpg) 

    - **Third address**

     ![ILA_S_3](sim_img/single_burst_ila_w_3.jpg) 
 


    - **Single Read Access**

    - **First address**

     ![ILA_SR_1](sim_img/single_burst_ila_r_1.jpg)

    - **Second address**

     ![ILA_SR_2](sim_img/single_burst_ila_r_2.jpg) 

    - **Third address**

     ![ILA_SR_3](sim_img/single_burst_ila_r_3.jpg) 
 





  
       

 

  - Full page access