set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root project cpu_stage1.xpr]
set_property top tb_cpu_twelve [get_filesets sim_1]
set_property xsim.simulate.runtime 30us [get_filesets sim_1]
launch_simulation
close_sim
close_project
