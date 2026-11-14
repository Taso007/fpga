# C5G pin assignment reference

All 61 top-level signal locations are explicit and unique. This table is extracted
from the project's QSF; the fitted Quartus pin report is `output_files/clu_project.pin`.

| Signal | FPGA pin | Direction | I/O standard |
|---|---|---|---|
| `CLOCK_50` | PIN_R20 | Input | 3.3-V LVTTL |
| `SW[0]` | PIN_AC9 | Input | 1.2 V |
| `SW[1]` | PIN_AE10 | Input | 1.2 V |
| `SW[2]` | PIN_AD13 | Input | 1.2 V |
| `SW[3]` | PIN_AC8 | Input | 1.2 V |
| `SW[4]` | PIN_W11 | Input | 1.2 V |
| `SW[5]` | PIN_AB10 | Input | 1.2 V |
| `SW[6]` | PIN_V10 | Input | 1.2 V |
| `SW[7]` | PIN_AC10 | Input | 1.2 V |
| `SW[8]` | PIN_Y11 | Input | 1.2 V |
| `SW[9]` | PIN_AE19 | Input | 1.2 V |
| `KEY[0]` | PIN_P11 | Input | 1.2 V |
| `KEY[1]` | PIN_P12 | Input | 1.2 V |
| `KEY[2]` | PIN_Y15 | Input | 1.2 V |
| `KEY[3]` | PIN_Y16 | Input | 1.2 V |
| `LEDR[0]` | PIN_F7 | Output | 2.5 V |
| `LEDR[1]` | PIN_F6 | Output | 2.5 V |
| `LEDR[2]` | PIN_G6 | Output | 2.5 V |
| `LEDR[3]` | PIN_G7 | Output | 2.5 V |
| `LEDR[4]` | PIN_J8 | Output | 2.5 V |
| `LEDR[5]` | PIN_J7 | Output | 2.5 V |
| `LEDR[6]` | PIN_K10 | Output | 2.5 V |
| `LEDR[7]` | PIN_K8 | Output | 2.5 V |
| `LEDR[8]` | PIN_H7 | Output | 2.5 V |
| `LEDR[9]` | PIN_J10 | Output | 2.5 V |
| `LEDG[0]` | PIN_L7 | Output | 2.5 V |
| `LEDG[1]` | PIN_K6 | Output | 2.5 V |
| `LEDG[2]` | PIN_D8 | Output | 2.5 V |
| `LEDG[3]` | PIN_E9 | Output | 2.5 V |
| `LEDG[4]` | PIN_A5 | Output | 2.5 V |
| `LEDG[5]` | PIN_B6 | Output | 2.5 V |
| `LEDG[6]` | PIN_H8 | Output | 2.5 V |
| `LEDG[7]` | PIN_H9 | Output | 2.5 V |
| `HEX0[0]` | PIN_V19 | Output | 1.2 V |
| `HEX0[1]` | PIN_V18 | Output | 1.2 V |
| `HEX0[2]` | PIN_V17 | Output | 1.2 V |
| `HEX0[3]` | PIN_W18 | Output | 1.2 V |
| `HEX0[4]` | PIN_Y20 | Output | 1.2 V |
| `HEX0[5]` | PIN_Y19 | Output | 1.2 V |
| `HEX0[6]` | PIN_Y18 | Output | 1.2 V |
| `HEX1[0]` | PIN_AA18 | Output | 1.2 V |
| `HEX1[1]` | PIN_AD26 | Output | 1.2 V |
| `HEX1[2]` | PIN_AB19 | Output | 1.2 V |
| `HEX1[3]` | PIN_AE26 | Output | 1.2 V |
| `HEX1[4]` | PIN_AE25 | Output | 1.2 V |
| `HEX1[5]` | PIN_AC19 | Output | 1.2 V |
| `HEX1[6]` | PIN_AF24 | Output | 1.2 V |
| `HEX2[0]` | PIN_AD7 | Output | 3.3-V LVTTL |
| `HEX2[1]` | PIN_AD6 | Output | 3.3-V LVTTL |
| `HEX2[2]` | PIN_U20 | Output | 3.3-V LVTTL |
| `HEX2[3]` | PIN_V22 | Output | 3.3-V LVTTL |
| `HEX2[4]` | PIN_V20 | Output | 3.3-V LVTTL |
| `HEX2[5]` | PIN_W21 | Output | 3.3-V LVTTL |
| `HEX2[6]` | PIN_W20 | Output | 3.3-V LVTTL |
| `HEX3[0]` | PIN_Y24 | Output | 3.3-V LVTTL |
| `HEX3[1]` | PIN_Y23 | Output | 3.3-V LVTTL |
| `HEX3[2]` | PIN_AA23 | Output | 3.3-V LVTTL |
| `HEX3[3]` | PIN_AA22 | Output | 3.3-V LVTTL |
| `HEX3[4]` | PIN_AC24 | Output | 3.3-V LVTTL |
| `HEX3[5]` | PIN_AC23 | Output | 3.3-V LVTTL |
| `HEX3[6]` | PIN_AC22 | Output | 3.3-V LVTTL |

Reference: Terasic C5G User Manual v1.2.1, Tables 3-2 through 3-6.
HEX2/HEX3 share GPIO signals and require the rear S1/S2 routing switches enabled.
