#---------------------------------------------------------------------------------------------------------
# ''''''''''''''''''''' 
# @Encoding: UTF-8
# @File    : vivado_flow_nonpr.tcl
# @Time    : 2024/12/18 15:08:03
# @Author  : YIAN@DawnCarol 
# @Version : rel.1.0
# @Contact : flipped1314u@foxmail.com
# @License : Copyright (C) 2024-2025 DawnCarol, Inc. All rights reserved.
# @Desc    : This script automates the FPGA design flow using Vivado, including synthesis, implementation,
#            and bitstream generation. It supports various FPGA parts and generates appropriate configuration
#            files (MCS or BIN) based on the target FPGA part.
# ''''''''''''''''''''' 
#---------------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------------
# Supported FPGA parts
#---------------------------------------------------------------------------------------------------------
# Zynq-7000 Series: xc7z020clg400-2, xc7z020clg484-2
# Kintex-7 Series: xc7k325tffg900-2, xc7k410tffg900-2
# Kintex UltraScale Series: xcku040-ffva1156-2-i, xcku060-ffva1156-2-i, xcku3p-ffvb676-2-i, xcku5p-ffvb676-2-i, xcku15p-ffve1517-2-i
# Virtex UltraScale+ Series: xcvu9p-flgb2104-2-i, xcvu11p-flgb2104-2-i, xcvu13p-fhgb2104-2-i

#---------------------------------------------------------------------------------------------------------
# Environment Check，check the Vivado version
#---------------------------------------------------------------------------------------------------------
#
#puts "Checking Vivado version..."
#regexp {([0-9]+)\.([0-9]+)} [eval version -short] full_ver ver_major ver_minor
#if {($ver_major < 2024) || ($ver_major == 2024 && $ver_minor < 2)} {
#    puts "Vivado version is $full_ver, which is lower than the required version 2024.2"
#    exit 1
#} else {
#    puts "Vivado version is $full_ver and meets the requirement"
#}

#---------------------------------------------------------------------------------------------------------
# STEP 1: Define output directory, top module, and chip part, and set the maximum number of threads
#---------------------------------------------------------------------------------------------------------

puts "Defining output directory, top module, and chip part..."
set TOP_MODULE dawncarol_led
set PART xcku060
set PACKAGE -ffva1156
set SPEED_GRADE -2-i
set CHIP_PART $PART$PACKAGE$SPEED_GRADE
set outputDir ../outputDir

# Detect the maximum number of threads supported by the machine
set max_threads 32
puts "Detected maximum threads: $max_threads"
set_param general.maxThreads $max_threads


create_project -force -part $CHIP_PART ../project/$TOP_MODULE

#---------------------------------------------------------------------------------------------------------
# STEP 2: Read RTL file list and constraints, and add PS IP if ZYNQ,but PS IP is not used in this flow
#---------------------------------------------------------------------------------------------------------
puts "Reading RTL file list and constraints..."
source ../rtl_flist/rtl_include.tcl
source ../rtl_flist/rtl_flist.tcl
read_xdc -unmanaged ../constraint/timing_constraint.xdc
read_xdc -unmanaged ../constraint/physical_constraint.xdc
#source ip_bd.tcl
#set_property generate_synth_checkpoint false [get_files system.bd]
#generate_target all [get_files system.bd]
#---------------------------------------------------------------------------------------------------------
# STEP 3: Run synthesis and write synthesis DCP, and generate synthesis reports
#
#puts "Running synthesis..."
#launch_runs synth_1
#wait_on_run synth_1
#launch_runs impl_1 -to_step write_bitstream
#wait_on_runs impl_1
