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

set_part $CHIP_PART
#create_project -force -part $CHIP_PART ../project/$TOP_MODULE

#---------------------------------------------------------------------------------------------------------
# STEP 2: Read RTL file list and constraints, and add PS IP if ZYNQ,but PS IP is not used in this flow
#---------------------------------------------------------------------------------------------------------
puts "Reading RTL file list and constraints..."
source ../rtl_flist/rtl_include.tcl
source ../rtl_flist/rtl_flist.tcl
read_xdc -unmanaged ../constraint/timing_constraint.xdc
read_xdc -unmanaged ../constraint/physical_constraint.xdc
#source ip_list.tcl
#source ip_bd.tcl
#set_property generate_synth_checkpoint false [get_files system.bd]
#generate_target all [get_files system.bd]
#---------------------------------------------------------------------------------------------------------
# STEP 3: Run synthesis and write synthesis DCP, and generate synthesis reports
puts "Running synthesis..."
synth_design -top $TOP_MODULE -part $CHIP_PART
write_checkpoint -force $outputDir/${TOP_MODULE}_syn.dcp
write_xdc -force $outputDir/${TOP_MODULE}_syn_edif.xdc
report_clocks -file $outputDir/${TOP_MODULE}_syn_clocks.rpt
report_timing_summary -file $outputDir/${TOP_MODULE}_syn_timing_summary.rpt
report_utilization -file $outputDir/${TOP_MODULE}_syn_util.rpt
report_cdc -file $outputDir/${TOP_MODULE}_syn_cdc.rpt -detail
report_power -file $outputDir/${TOP_MODULE}_syn_power.rpt
report_exceptions -file $outputDir/${TOP_MODULE}_syn_timing_exceptions.rpt -coverage
report_drc -file $outputDir/${TOP_MODULE}_syn_drc.rpt
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

#---------------------------------------------------------------------------------------------------------
# STEP 4: Run logic optimization, placement, and physical logic optimization
#---------------------------------------------------------------------------------------------------------
puts "Running logic optimization and placement..."
opt_design -directive ExploreWithRemap
place_design -directive ExtraTimingOpt
write_checkpoint -force $outputDir/${TOP_MODULE}_place.dcp
report_clock_utilization -file $outputDir/${TOP_MODULE}_place_clock_util.rpt
report_utilization -file $outputDir/${TOP_MODULE}_place_util.rpt
report_utilization -file $outputDir/${TOP_MODULE}_place_hier_util.rpt -hierarchical -hierarchical_depth 5
report_timing_summary -file $outputDir/${TOP_MODULE}_place_timing_summary.rpt -check_timing_verbose -report_unconstrained -verbose -slack_lesser_than 0
report_cdc -file $outputDir/${TOP_MODULE}_place_cdc.rpt -detail
report_exceptions -file $outputDir/${TOP_MODULE}_place_timing_exceptions.rpt -coverage
report_power -file $outputDir/${TOP_MODULE}_place_power.rpt
report_drc -file $outputDir/${TOP_MODULE}_place_drc.rpt
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]

#---------------------------------------------------------------------------------------------------------
# STEP 5: Run the router and write the post-route design checkpoint and report the routing
#---------------------------------------------------------------------------------------------------------
puts "Running routing..."
route_design
phys_opt_design -verbose -directive AggressiveExplore
write_verilog -force $outputDir/${TOP_MODULE}_impl_netlist.sv -mode timesim -sdf_anno true
write_checkpoint -force $outputDir/${TOP_MODULE}_route.dcp
report_route_status -file $outputDir/${TOP_MODULE}_route_status.rpt
report_drc -file $outputDir/${TOP_MODULE}_route_drc.rpt
report_utilization -file $outputDir/${TOP_MODULE}_route_util.rpt
report_utilization -file $outputDir/${TOP_MODULE}_route_hier_util.rpt -hierarchical -hierarchical_depth 5
report_timing_summary -file $outputDir/${TOP_MODULE}_route_timing_summary.rpt
report_cdc -file $outputDir/${TOP_MODULE}_route_cdc.rpt -detail
report_exceptions -file $outputDir/${TOP_MODULE}_route_timing_exceptions.rpt -coverage
report_power -file $outputDir/${TOP_MODULE}_route_power.rpt
report_drc -file $outputDir/${TOP_MODULE}_imp_drc.rpt
report_io -file $outputDir/${TOP_MODULE}_route_io.rpt
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
#---------------------------------------------------------------------------------------------------------
# STEP 6: Generate a bitstream
#---------------------------------------------------------------------------------------------------------
puts "Generating bitstream..."
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -verbose -force -bin_file $outputDir/${TOP_MODULE}.bit
write_debug_probes -force $outputDir/${TOP_MODULE}.ltx

#---------------------------------------------------------------------------------------------------------
# Generate MCS or BIN file based on the FPGA part
#---------------------------------------------------------------------------------------------------------
if {[string match "xcku*" $PART] || [string match "xc7k*" $PART]} {
    puts "Generating MCS file for $PART..."
    write_cfgmem -format mcs -size 32 -interface SPIx8 -loadbit "up 0x00000000 $outputDir/$TOP_MODULE.bit" -file $outputDir/$TOP_MODULE.mcs -checksum -force -disablebitswap
} elseif {[string match "xc7z*" $PART]} {
    # Save hardware platform for Vitis
    write_hw_platform -fixed -include_bit -force -file $outputDir/${TOP_MODULE}_hw_platform.xsa 
    puts "Generate hardware platform for vitis"
} else {
    puts "No need to generate MCS or XSA file for $PART"
}

#write_cfgmem -format mcs -size 32 -interface SPIx8 -loadbit "up 0x00000000 $outputDir/$TOP_MODULE.bit" -file $outputDir/$TOP_MODULE.mcs -checksum -force -disablebitswap