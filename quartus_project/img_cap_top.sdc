#**************************************************************
# This .sdc file is created by Terasic Tool.
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
#create_clock -period 8 [get_ports CLOCK_125_p]
#create_clock -period 20 [get_ports CLOCK_50_B5B]
create_clock -period 20 [get_ports CLOCK_50_B6A]
#create_clock -period 20 [get_ports CLOCK_50_B7A]
#create_clock -period 20 [get_ports CLOCK_50_B8A]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************


#**************************************************************
# Set Multicycle Path
#**************************************************************
set_multicycle_path -setup -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_85 2
set_multicycle_path -hold -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_85 1
set_multicycle_path -setup -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_86 3
set_multicycle_path -hold -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_86 2
set_multicycle_path -setup -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_87 2
set_multicycle_path -hold -from mem_int|global_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_87 1

set_multicycle_path -setup -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_70 2
set_multicycle_path -hold -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_70 1
set_multicycle_path -setup -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_71 2
set_multicycle_path -hold -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_71 1
set_multicycle_path -setup -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_72 4
set_multicycle_path -hold -from mem_int|soft_reset_n -to mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_72 3

#set_multicycle_path -setup -from mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_39 -to mem_int|local_cal_success_fl 2
#set_multicycle_path -hold -from mem_int|lpddr2x32_4p_inst|lpddr2x32_4p_inst|p0|umemphy|hphy_inst~FF_39 -to mem_int|local_cal_success_fl 1


#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************