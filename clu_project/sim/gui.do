transcript file ""
do compile.do
vsim -t 1ns -voptargs=+acc -wlf ../evidence/clu_directed.wlf work.tb_clu
log -r /*
do wave.do
run -all
wave zoom full
