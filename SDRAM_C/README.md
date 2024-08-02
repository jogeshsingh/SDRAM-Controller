## SDRAM Controller

> This Repository Contains a SDRAM Controller Verilog HDL Code for Interfacing SDRAM(Reading from and Writing to `SDRAM`)
  mounted on `ARTIX-A7 FPGA Board`


## FSM Controller For SDRAM



## Simulation Details


   - `Burst - 8 - on incrementing addresses`

    ![SIM_BURST_8](sim_img/sim_burst_8_continuous.jpg)  


## Implementation Details

  - Single Mode Acess
  
    - This section describes the timing for `reading` and `writing` from/to single array location in `SDRAM`



    - **Single Write Access**




    - **Single Read Access**






  - Burst Mode access

    - This section describes the timing for `reading` and `writing` from/to multiple array location in `SDRAM` using `burst mode`

       **NOTE**

      - `Write burst`  is on `sdr_dq_out` 
       
      - `Read burst` is  on `sdr_dq_in`
      
    - **BURST of 2 data (Write and read Access)**

       `Write burst`

       ![burst_2_w](sim_img/burst_2.jpg)
     
      `Read burst`

      ![burst_2_r](sim_img/burst_2_read.jpg)
   
    
     - **BURST of 4 data (Write and read Access)**
 
       `Write burst`

       ![burst_2_w](sim_img/burst_4_w.jpg)
     
       `Read burst`

       ![burst_2_r](sim_img/burst_4_rd.jpg)


     - **BURST of 8 data (Write and read Access)**

       `Write burst`

       ![burst_2_w](sim_img/burst_8_w.jpg)
     
       `Read burst`

       ![burst_2_r](sim_img/burst_8_rd.jpg)
   

 

  - Full page access