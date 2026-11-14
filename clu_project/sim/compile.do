onerror {quit -code 1 -force}
onbreak {quit -code 1 -force}
if {![file isdirectory work]} {vlib work}
vmap work work
vcom -2008 ../rtl/clu.vhd ../rtl/hex7seg.vhd ../rtl/clu_c5g_top.vhd
vcom -2008 ../tb/tb_clu.vhd ../tb/tb_clu_c5g_top.vhd
