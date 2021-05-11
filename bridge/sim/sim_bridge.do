# create the Library working directory
vlib work

# compile the src and tb files along with the includes and options
vlog -work work -vopt +incdir+../include -nocovercells "../IO.v"
vlog -work work -vopt +incdir+../include -nocovercells "../Mem.v"
vlog -work work -vopt +incdir+../include -nocovercells "../TestIO3.v"

# simulate the top file(testbench)
vsim -t 1ns -voptargs=+acc work.testIO2

# add the signals into waveform
add wave -r *

#run the simulation
run -all
