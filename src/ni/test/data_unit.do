delete wave *
restart -f


##########################################################
# Setup waves
##########################################################

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate data_unit/clk
add wave -noupdate data_unit/reset
add wave -noupdate -radix hexadecimal data_unit/spm
add wave -noupdate -radix hexadecimal data_unit/irq_fifo_data
add wave -noupdate data_unit/irq_fifo_data_valid
add wave -noupdate -radix hexadecimal data_unit/pkt_in

wave refresh

##########################################################
# Force signals
##########################################################

force data_unit/clk 0 0ns , 1 5ns -repeat 10ns
force data_unit/reset 1 0ns , 0 40 ns

# Initial value
force data_unit/pkt_in "00000000000000000000000000000000000" 0ns

# Two non-data packets / trash
force data_unit/pkt_in "11010000000000000000000000000000000" 50 ns, "11011000000000000000000000000000000" 60 ns

# Data packet [1 word] [last packet]
# Address = 2AAA
# Data = BBBBBBBBEEEEEEEE
force data_unit/pkt_in "11001101010101010101111111111111111" 70 ns, "10010111011101110111011101110111011" 80 ns, "10111101110111011101110111011101110" 90 ns

# Data packet [1 word] [last packet]
# Address = 1535
# Data = 2492492411111111
force data_unit/pkt_in "11001010101001101011111111111111111" 100 ns, "10000100100100100100100100100100100" 110 ns, "10100010001000100010001000100010001" 120 ns

# Three non-data packets / trash
force data_unit/pkt_in "11011010101001101011111111111111111" 130 ns, "10001100100100100100100100100100100" 140 ns, "10101010001000100010001000100010001" 150 ns

# Data packet [4 words] [non-last packet]
# Address = 0000
# Data = 1111111122222222
# Address = 0001
# Data = 3333333344444444
# Address = 0002
# Data = 5555555566666666
# Address = 0003
# Data = 7777777788888888
force data_unit/pkt_in "11000000000000000001111111111111111" 160 ns, "10000010001000100010001000100010001" 170 ns, "10000100010001000100010001000100010" 180 ns, "10000110011001100110011001100110011" 190 ns, "10001000100010001000100010001000100" 200 ns, "10001010101010101010101010101010101" 210 ns, "10001100110011001100110011001100110" 220 ns, "10001110111011101110111011101110111" 230 ns, "10110001000100010001000100010001000" 240 ns

# Three non-data packets / trash
force data_unit/pkt_in "11011010101001101011111111111111111" 250 ns, "10001100100100100100100100100100100" 260 ns, "10101010001000100010001000100010001" 270 ns

# Data packet [4 words] [last packet]
# Address = 0000
# Data = 1111111122222222
# Address = 0001
# Data = 3333333344444444
# Address = 0002
# Data = 5555555566666666
# Address = 0003
# Data = 7777777788888888
force data_unit/pkt_in "11001000000000000001111111111111111" 280 ns, "10000010001000100010001000100010001" 290 ns, "10000100010001000100010001000100010" 300 ns, "10000110011001100110011001100110011" 310 ns, "10001000100010001000100010001000100" 320 ns, "10001010101010101010101010101010101" 330 ns, "10001100110011001100110011001100110" 340 ns, "10001110111011101110111011101110111" 350 ns, "10110001000100010001000100010001000" 360 ns

# Data packet [1 word] [non-last packet]
# Address = 1535
# Data = 2492492411111111
force data_unit/pkt_in "11000010101001101011111111111111111" 370 ns, "10000100100100100100100100100100100" 380 ns, "10100010001000100010001000100010001" 390 ns

run 1000ns
