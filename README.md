# FPGA_Demo

fpga flow
support project mode
no-project mode
win os flow
linux os flow

1.$cd vivado_flow

2.$vivado -source vivado_flow_pr.tcl(this will generate project in project folder)

if you want to run in no-project mode,$vivado -source vivado_flow_nopr.tcl

3.$cd sim

4.$make compile,$make run,$make verdi(VCS and Verdi should install)

if you need to sim Vivado IP,you should compile Vivado IP,but this flow
do not support now
