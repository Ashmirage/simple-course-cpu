# 100 MHz Ê±ÖÓ
set_property PACKAGE_PIN P17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

# ¸´Î»°´¼ü
set_property PACKAGE_PIN R11 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]

# LED0¡«LED7
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property PACKAGE_PIN K3 [get_ports {led[0]}]
set_property PACKAGE_PIN M1 [get_ports {led[1]}]
set_property PACKAGE_PIN L1 [get_ports {led[2]}]
set_property PACKAGE_PIN K6 [get_ports {led[3]}]
set_property PACKAGE_PIN J5 [get_ports {led[4]}]
set_property PACKAGE_PIN H5 [get_ports {led[5]}]
set_property PACKAGE_PIN H6 [get_ports {led[6]}]
set_property PACKAGE_PIN K1 [get_ports {led[7]}]


set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

