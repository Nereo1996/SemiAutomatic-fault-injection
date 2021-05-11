
############################### SENZA CICLO ##############################


# create the Library working directory
#vlib work

# compile the src and tb files along with the includes and options
#vlog -work work -vopt +incdir+../include -nocovercells "../TestCC.v"

# simulate the top file(testbench)
#vsim -t 1ns -voptargs=+acc work.CC_bench

# add the signals into waveform
#add wave -r *

#run the simulation
#run -all



############################### CON CICLO ##############################



# create the Library working directory
vlib work

# compile the src and tb files along with the includes and options
vlog -work work -vopt +incdir+../include -nocovercells "../CC.v"
vlog -work work -vopt +incdir+../include -nocovercells "../TestCC.v"

# simulate the top file(testbench)
vsim -t 1ns -voptargs=+acc work.CC_bench

# add the signals into waveform
add wave -r *


for {set i 0} {$i<3} {incr i} {

	# modifico fp 
	set data "`DEFINE FP $i"
	set filename "../fp.v"
	set fileId [open $filename "w"]
	puts $fileId $data 
	close $fileId

	if { $i == 0 } {
		#apro vcd
		vcd file "../VCD/noForce.vcd" 
		vcd add *
	   			
		#simulo il design
		run -all 	
		vcd flush
	} else {
		#apro vcd
		vcd file "../VCD/force_num_$i.vcd" 
	   	vcd add  * 
	   			
		#simulo il design
		run -all 	
		vcd flush 
	}

    #run -all

	#RESET DELLA SIMULAZIONE
	if { $i < 2 } {
		restart -f 
	}
	
}

