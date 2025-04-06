#---------------------------------------------------------------------------------------------------------
# '''''''''''''''''''''
# @Encoding: UTF-8
# @File    : timing_constraint.xdc
# @Time    : 2024/12/20 11:11:34
# @Author  : YIAN@DawnCarol 
# @Version : rel.1.0
# @Contact : flipped1314u@foxmail.com
# @License : Copyright (C) 2024-2025 DawnCarol, Inc. All rights reserved.
# @Desc    : None
# '''''''''''''''''''''
#---------------------------------------------------------------------------------------------------------



# Rising Edge System Synchronous Inputs
#
# A Single Data Rate (SDR) System Synchronous interface is
# an interface where the external device and the FPGA use
# the same clock, and a new data is captured one clock cycle
# after being launched
#
# input      __________            __________
# clock   __|          |__________|          |__
#           |
#           |------> (tco_min+trce_dly_min)
#           |------------> (tco_max+trce_dly_max)
#         __________      ________________    
# data    __________XXXXXX_____ Data _____XXXXXXX
#

##  set input_clock     sysclk;          # Name of input clock
##  set tco_max         5.000 ;          # Maximum clock to out delay (external device)
##  set tco_min         2.000 ;          # Minimum clock to out delay (external device)
##  set trce_dly_max    1.000 ;          # Maximum board trace delay
##  set trce_dly_min    1.000 ;          # Minimum board trace delay
##  
##  # Input Delay Constraint
##  set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports $input_ports];
##  set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports $input_ports];
##  
##  # Report Timing Template
##  # report_timing -from [get_ports $input_ports] -max_paths 20 -nworst 1 -delay_type min_max -name sys_sync_rise_in  -file sys_sync_rise_in.txt;		

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]

create_clock -period 5.000 [get_ports sys_clk_p]

set_property PACKAGE_PIN AK17 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]