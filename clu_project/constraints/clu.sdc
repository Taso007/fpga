create_clock -name board_clk -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty

# Switches/buttons are asynchronous human inputs. The wrapper synchronizes
# them; no external setup/hold contract is possible at these board inputs.
# This cuts input-to-first-stage/reset paths, NOT synchronizer register paths.
set_false_path -from [get_ports {SW[*] KEY[*]}]

# A 20 ns output settling budget relative to launch on board_clk.
# LEDs have no receiving clock; this is a design budget, not a board protocol.
set_output_delay -clock board_clk -max 0.000 [get_ports {LEDR[*] LEDG[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*]}]
set_output_delay -clock board_clk -min 0.000 [get_ports {LEDR[*] LEDG[*] HEX0[*] HEX1[*] HEX2[*] HEX3[*]}]
