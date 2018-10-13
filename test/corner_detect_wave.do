onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/clk_50
add wave -noupdate -radix unsigned /testbench/index
add wave -noupdate /testbench/r
add wave -noupdate /testbench/g
add wave -noupdate /testbench/b
add wave -noupdate /testbench/corner
add wave -noupdate -divider DUt
add wave -noupdate -radix hexadecimal /testbench/DUT/r
add wave -noupdate -radix hexadecimal /testbench/DUT/g
add wave -noupdate -radix hexadecimal /testbench/DUT/b
add wave -noupdate /testbench/DUT/rgb_target
add wave -noupdate /testbench/DUT/threshold_in
add wave -noupdate /testbench/DUT/corner_detected
add wave -noupdate /testbench/DUT/threshold
add wave -noupdate /testbench/DUT/r_in
add wave -noupdate /testbench/DUT/g_in
add wave -noupdate /testbench/DUT/b_in
add wave -noupdate /testbench/DUT/r_target
add wave -noupdate /testbench/DUT/g_target
add wave -noupdate /testbench/DUT/b_target
add wave -noupdate /testbench/DUT/r_diff
add wave -noupdate /testbench/DUT/g_diff
add wave -noupdate /testbench/DUT/b_diff
add wave -noupdate /testbench/DUT/r_sqrd
add wave -noupdate /testbench/DUT/g_sqrd
add wave -noupdate /testbench/DUT/b_sqrd
add wave -noupdate /testbench/DUT/sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52724 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {262500 ps}
