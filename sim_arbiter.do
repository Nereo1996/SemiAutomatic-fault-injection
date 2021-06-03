# create the Library working directory
#vlib work

# compile the src and tb files along with the includes and options
#vlog -work work -vopt +incdir+../include -nocovercells "../rtl/arbiter.v"
#vlog -work work -vopt +incdir+../include -nocovercells "../tb/bfm_arbiter.v"
#vlog -work work -vopt +incdir+../include -nocovercells "../tb/tb_userinterface.v"

# simulate the top file(testbench)
#vsim -t 1ns -voptargs=+acc +dumpports+unique work.tb_userinterface

# add the signals into waveform
#add wave -r tb_userinterface
#add wave -r *
#vcd file arbiter.vcd
#vcd add -r *


#run the simulation
#run -all
#exit


############################### CON CICLO ##############################




touch "fp.v"
touch "../output1.txt"
touch "../output.txt"

for {set i 0} {$i<14} {incr i} {

	# modifico fp 
	set data "`define fp $i"
	set filename "fp.v"
	set fileId [open $filename "w"]
	puts $fileId $data 
	close $fileId

# create the Library working directory
vlib work

# compile the src and tb files along with the includes and options
vlog -work work -vopt +incdir+../include -nocovercells "../rtl/arbiter.v"
vlog -work work -vopt +incdir+../include -nocovercells "../tb/bfm_arbiter.v"
vlog -work work -vopt +incdir+../include -nocovercells "../tb/tb_userinterface.v"

# simulate the top file(testbench)
#vsim -t 1ns -voptargs=+acc +dumpports+unique work.tb_userinterface
vsim -t 1ns -voptargs=+acc work.tb_userinterface

# add the signals into waveform
add wave -r *

	if { $i == 0 } {
		#apro vcd
		vcd  add -file "../VCD/noForce.vcd" -r -out *
		#vcd add "Full_o"
	   			
		#simulo il design
		run -all 	
		vcd flush
	} else {
		#apro vcd
		vcd add -file "../VCD/fp_num_$i.vcd" -r -out *
	   	#vcd add "Full_o"
	   			
		#simulo il design
		run -all 	
		vcd flush 
	}

    #run -all

	#RESET DELLA SIMULAZIONE
	#if { $i < 1 } {
	#	restart -f 
	#}
	
}


sort -u "../output1.txt" > "../output.txt"
rm "../output1.txt"
rm "fp.v"