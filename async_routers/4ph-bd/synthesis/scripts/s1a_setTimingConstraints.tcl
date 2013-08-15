# Create User-Defined Variables
set CLK_PERIOD 0.4
#set CLK_SKEW 0.14
#set WC_OP_CONDS typ_0_1.98
#set WIRELOAD_MODEL 10KGATES
#set DRIVE_CELL buf1a6
#set DRIVE_PIN {Y}
#set MAX_OUTPUT_LOAD [load_of ssc_core/buf1a2/A]
#set INPUT_DELAY 2.0
#set OUTPUT_DELAY 0.5
#set MAX_AREA 380000



# C - elements
set_disable_timing *_in_latch/controller/gate/latch/C8/B

set_disable_timing *_hpu/token_latch/controller/gate/latch/C8/B

set_disable_timing xbar_with_latches/crossbar/c_sync_req/latch/C8/B

set_disable_timing xbar_with_latches/crossbar/c_sync_ack/latch/C8/B

set_disable_timing xbar_with_latches/ch_latch_*/controller/gate/latch/C8/B


# Delay Elements -matching HPU combinational logic
set_max_delay -from north_hpu/I_0/A -to north_hpu/I_1/Z 0.24
set_max_delay -from south_hpu/I_0/A -to south_hpu/I_1/Z 0.24
set_max_delay -from east_hpu/I_0/A -to east_hpu/I_1/Z 0.24
set_max_delay -from west_hpu/I_0/A -to west_hpu/I_1/Z 0.24
set_max_delay -from resource_hpu/I_0/A -to resource_hpu/I_1/Z 0.24

set_min_delay -from north_hpu/I_0/A -to north_hpu/I_1/Z 0.15
set_min_delay -from south_hpu/I_0/A -to south_hpu/I_1/Z 0.15
set_min_delay -from east_hpu/I_0/A -to east_hpu/I_1/Z 0.15
set_min_delay -from west_hpu/I_0/A -to west_hpu/I_1/Z 0.15
set_min_delay -from resource_hpu/I_0/A -to resource_hpu/I_1/Z 0.15

#break loop in CinA -checked
set_max_delay -from north_hpu/token_latch/controller/gate/a -to north_hpu/token_latch/controller/I_0/Z 0.47
set_max_delay -from south_hpu/token_latch/controller/gate/a -to south_hpu/token_latch/controller/I_0/Z 0.47
set_max_delay -from east_hpu/token_latch/controller/gate/a -to east_hpu/token_latch/controller/I_0/Z 0.47
set_max_delay -from west_hpu/token_latch/controller/gate/a -to west_hpu/token_latch/controller/I_0/Z 0.47
set_max_delay -from resource_hpu/token_latch/controller/gate/a -to resource_hpu/token_latch/controller/I_0/Z 0.47

#set_disable_timing *_hpu/token_latch/controller/gate/a

set_max_delay -to {*_hpu/hpu_combinatorial/sel_reg[*]/data_in} 0.4

#create_clocks
create_clock -name "clkM" -period $CLK_PERIOD -waveform {0.0 0.2} [get_pins { *_in_latch/controller/lt_en \
xbar_with_latches/ch_latch_*/controller/lt_en } ]

create_clock -name "clkS" -period $CLK_PERIOD -waveform {0.2 0.4} [get_pins *_hpu/token_latch/controller/lt_en]

#set_wire_load_model -name area_6Kto7K
write -hierarchy -format ddc -output /home/piraten/eit-eik/r4p/synthesis/db/unmapped_constrained.ddc


