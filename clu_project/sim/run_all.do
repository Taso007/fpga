# Run from the sim directory; run_sim.ps1 sets this automatically.
onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
do compile.do
vsim -t 1ns -voptargs=+acc -wlf ../evidence/clu_directed.wlf work.tb_clu
log -r /*
vcd file ../evidence/clu_directed.vcd
vcd add /tb_clu/a /tb_clu/b /tb_clu/op /tb_clu/r /tb_clu/z /tb_clu/c /tb_clu/n /tb_clu/lt
run -all
if {[examine /tb_clu/done] ne "TRUE"} {error "Directed test did not complete"}
vcd flush
vcd off
quit -sim
vsim -t 1ns -voptargs=+acc -wlf work/exhaustive.wlf -gEXHAUSTIVE=true work.tb_clu
run -all
if {[examine /tb_clu/done] ne "TRUE"} {error "Exhaustive test did not complete"}
quit -sim
vsim -t 1ns -voptargs=+acc -wlf ../evidence/c5g_interface.wlf work.tb_clu_c5g_top
log -r /*
run -all
if {[examine /tb_clu_c5g_top/done] ne "TRUE"} {error "Board interface test did not complete"}
echo "ALL THREE SIMULATIONS PASSED"
quit -code 0 -force
