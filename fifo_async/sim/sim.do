quit -sim 
.main clear

vlib work  
vmap work work 
################################################################################
# complie testbench files 
vlog ./tb.v

################################################################################
# complie design files 
vlog ./../bfm/*.v

################################################################################
# complie ipcore files 

#vlog ./altera_lib/*.v

################################################################################
#
vsim   -voptargs=+acc   work.tb

################################################################################
add wave -divider {tesebench_inst}
add wave tb/*

add wave -divider {bfm_inst}
add wave bfm_inst/*

add wave -divider {fifo_wptr_gen_inst}
add wave bfm_inst/fifo_wptr_gen_inst/*

add wave -divider {fifo_full_gen_inst}
add wave bfm_inst/fifo_full_gen_inst/*

add wave -divider {fifo_empty_gen_inst}
add wave bfm_inst/fifo_empty_gen_inst/*

add wave -divider {fifo_rptr_gen_inst}
add wave bfm_inst/fifo_rptr_gen_inst/*

run 1ms

 