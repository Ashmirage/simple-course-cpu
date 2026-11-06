set root [file normalize [file join [file dirname [info script]] ..]]
create_project cpu_a_stage1 [file join $root project] -part xc7a35tcsg324-1 -force
add_files [glob [file join $root rtl *.v]]
add_files [file join $root rtl cpu_defs.vh]
set_property include_dirs [list [file join $root rtl]] [get_filesets sources_1]
add_files -fileset constrs_1 [file join $root constraints ego1_a.xdc]
add_files -fileset sim_1 [glob [file join $root sim *.v]]
set_property top ego1_a_top [get_filesets sources_1]
set_property top tb_ego1_a_top [get_filesets sim_1]
set_property xsim.simulate.runtime 25us [get_filesets sim_1]
launch_simulation
close_sim
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {error "Build failed"}
open_run impl_1
report_timing_summary -file [file join $root timing_summary.rpt]
report_cdc -file [file join $root cdc.rpt]
puts "BUILD_BITSTREAM [file join $root project cpu_a_stage1.runs impl_1 ego1_a_top.bit]"
