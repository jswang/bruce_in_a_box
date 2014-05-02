onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/clk_50
add wave -noupdate /testbench/clk_VGA
add wave -noupdate /testbench/image_R
add wave -noupdate /testbench/image_G
add wave -noupdate /testbench/image_B
add wave -noupdate /testbench/draw_image
add wave -noupdate -divider arctan
add wave -noupdate /testbench/DUT/arctan/numer
add wave -noupdate /testbench/DUT/arctan/denom
add wave -noupdate -radix fpoint#8 /testbench/DUT/arctan/div_fp_abs_d0
add wave -noupdate -radix unsigned /testbench/DUT/arctan/lut_address
add wave -noupdate -radix fpoint#8 /testbench/DUT/arctan/lut_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10561472719 ps} 0}
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
WaveRestoreZoom {9883880986 ps} {11769353633 ps}
