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
add wave -noupdate /testbench/DUT/r
add wave -noupdate /testbench/DUT/g
add wave -noupdate /testbench/DUT/b
add wave -noupdate /testbench/DUT/rgb_target
add wave -noupdate /testbench/DUT/threshold_in
add wave -noupdate /testbench/DUT/corner_detected
add wave -noupdate /testbench/DUT/hue
add wave -noupdate /testbench/DUT/saturation
add wave -noupdate /testbench/DUT/lightness
add wave -noupdate -divider rgbtoHSL
add wave -noupdate /testbench/DUT/RGB_to_HSL/clk
add wave -noupdate /testbench/DUT/RGB_to_HSL/iRed
add wave -noupdate /testbench/DUT/RGB_to_HSL/iGreen
add wave -noupdate /testbench/DUT/RGB_to_HSL/iBlue
add wave -noupdate /testbench/DUT/RGB_to_HSL/oHue
add wave -noupdate /testbench/DUT/RGB_to_HSL/oSaturation
add wave -noupdate /testbench/DUT/RGB_to_HSL/oLightness
add wave -noupdate /testbench/DUT/RGB_to_HSL/iR
add wave -noupdate /testbench/DUT/RGB_to_HSL/iG
add wave -noupdate /testbench/DUT/RGB_to_HSL/iB
add wave -noupdate /testbench/DUT/RGB_to_HSL/tempR
add wave -noupdate /testbench/DUT/RGB_to_HSL/tempG
add wave -noupdate /testbench/DUT/RGB_to_HSL/tempB
add wave -noupdate /testbench/DUT/RGB_to_HSL/negR
add wave -noupdate /testbench/DUT/RGB_to_HSL/negG
add wave -noupdate /testbench/DUT/RGB_to_HSL/negB
add wave -noupdate /testbench/DUT/RGB_to_HSL/max
add wave -noupdate /testbench/DUT/RGB_to_HSL/min
add wave -noupdate /testbench/DUT/RGB_to_HSL/maxMmin
add wave -noupdate /testbench/DUT/RGB_to_HSL/twoMmaxMmin
add wave -noupdate /testbench/DUT/RGB_to_HSL/maxPmin
add wave -noupdate /testbench/DUT/RGB_to_HSL/s1
add wave -noupdate /testbench/DUT/RGB_to_HSL/s2
add wave -noupdate /testbench/DUT/RGB_to_HSL/r1
add wave -noupdate /testbench/DUT/RGB_to_HSL/g1
add wave -noupdate /testbench/DUT/RGB_to_HSL/b1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {243429 ps} 0}
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
WaveRestoreZoom {0 ps} {525 ns}
