onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/clk_50
add wave -noupdate -radix unsigned /testbench/index
add wave -noupdate -radix unsigned /testbench/VGA_X
add wave -noupdate -radix unsigned /testbench/VGA_Y
add wave -noupdate -radix unsigned /testbench/VGA_X_d2
add wave -noupdate -radix unsigned /testbench/VGA_Y_d2
add wave -noupdate /testbench/color_read_data
add wave -noupdate /testbench/color_data_valid
add wave -noupdate -radix unsigned /testbench/just_read_x
add wave -noupdate -radix unsigned /testbench/just_read_y
add wave -noupdate -divider color_hist
add wave -noupdate -radix unsigned /testbench/color_hist/read_x
add wave -noupdate -radix unsigned /testbench/color_hist/read_y
add wave -noupdate /testbench/color_hist/read_data
add wave -noupdate /testbench/color_hist/data_valid
add wave -noupdate /testbench/color_hist/just_read_x
add wave -noupdate /testbench/color_hist/just_read_y
add wave -noupdate /testbench/color_hist/test_read_x
add wave -noupdate /testbench/color_hist/test_read_y
add wave -noupdate -radix unsigned /testbench/color_hist/addr_a
add wave -noupdate -radix unsigned /testbench/color_hist/state
add wave -noupdate /testbench/color_hist/clear_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3200018313 ps} 0}
configure wave -namecolwidth 149
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
WaveRestoreZoom {3200010098 ps} {3200049902 ps}
