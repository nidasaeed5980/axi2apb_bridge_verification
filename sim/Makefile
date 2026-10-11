TEST ?= axi2apb_smoke_test

# Compile testbench
compile:
	vcs -sverilog -f build.flist -ntb_opts uvm-1.2 -timescale=1ns/1ps -top tb_top -cm line+tgl+cond -full64 -debug_all
	cd ./out && rm -rf build_$(TEST)
	cd ./out && mkdir -p build_$(TEST)
	mv csrc simv.daidir simv.vdb simv vc_hdrs.h ./out/build_$(TEST)

# Run simulation
sim:
	cd ./out/build_$(TEST) && ./simv -cm line+tgl+cond +UVM_TESTNAME=$(TEST) > build_$(TEST).log

# Open VPD waveform
gui:
	cd ./out/build_$(TEST) && dve -vpd waveform.vpd

# Code coverage
code_covg:
	urg -report ./out/code_coverage_report -dir ./out/build_*/*.vdb

# Clean test simulation
clean:
	cd ./out && rm -rf build_$(TEST)
