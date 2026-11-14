# CLU midterm project

An unsigned 8-bit combinational logic unit for the **Terasic C5G / Cyclone V GX
Starter Kit**, device **5CGXFC5C6F27C7**. The project includes VHDL sources,
self-checking testbenches, pin assignments, timing constraints and board evidence.

- [Technical report](output/pdf/CLU_Technical_Report.pdf)
- [Report source](docs/REPORT.md)
- [Demonstration video](evidence/DEMO.mp4)
- [Pin assignments](docs/PIN_ASSIGNMENTS.md)

Open the existing `clu_project.qpf` in Quartus. The supplied programming file is
`output_files/clu_project.sof`; the Programmer screenshot records **100% Successful**.

| Location | Contents |
|---|---|
| `rtl/` | CLU, board wrapper and seven-segment decoder |
| `tb/` | Directed/exhaustive CLU testbench and board-interface testbench |
| `constraints/` | Timing constraints |
| `sim/` | Questa compilation, simulation and waveform setup |
| `scripts/` | Build, simulation, waveform plotting and report generation |
| `docs/` | Report source, architecture diagram and pin documentation |
| `evidence/` | Screenshots, plots, waveform data, board photographs and video |
| `output_files/` | Programming file, pin report and compilation/timing reports |
| `output/pdf/` | Printable technical report |

## 1. Operations and flags

`rtl/clu.vhd` is the assignment's purely combinational unit. It has two 8-bit
unsigned operands, a 3-bit OP, an 8-bit result, and four flags. Its arithmetic wraps
modulo 256. These definitions fill in details that the brief leaves to the designer.

| OP2 OP1 OP0 | Operation | Result R |
|---|---|---|
| 000 | Unsigned addition | Low 8 bits of A+B |
| 001 | Unsigned subtraction | (A-B) modulo 256 |
| 010 | AND | A AND B |
| 011 | OR | A OR B |
| 100 | XOR | A XOR B |
| 101 | Comparison | 04 if A>B; 02 if A=B; 01 if A<B |
| 110 | Even-parity generation | Bit 0 = XOR of all A bits; bit 1 = XOR of all B bits; other bits 0 |
| 111 | Custom: rotate left | Rotate A left by B(2:0), i.e. B modulo 8 |

All values written as `FF`, `AA`, `81`, etc. in this guide are **hexadecimal**.
For example, FF hex is 255 decimal and 11111111 binary.

| Flag | Meaning |
|---|---|
| Z | 1 exactly when R=00, for every operation |
| C | Addition: carry out. Subtraction: **1 means borrow**. All other operations: 0 |
| N | R(7), the most significant result bit; operands are still unsigned |
| LT | 1 exactly when unsigned A<B, for every operation |

For comparison, R(2), R(1), R(0) mean greater, equal, less respectively. An equality
comparison produces R=02 and Z=0. Z describes the result bus, not operand equality.
Appending the generated parity bit to the corresponding operand makes its total
number of 1 bits even.

## 2. Run the simulations

Open **Windows PowerShell** and paste:

```powershell
Set-Location C:\fpga\clu_project
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_sim.ps1
```

This runs the following checks in Questa:

1. 27 representative CLU vectors, with a readable waveform.
2. Every combination of A=0..255, B=0..255, OP=0..7: 524,288 combinations,
   plus the same 27 representative vectors (524,315 checks in this run).
3. A separate board-interface test covering reset, loads, holding a button,
   all 256 input byte values, displays, flags, and display pages.

Successful completion prints **ALL THREE SIMULATIONS PASSED** in the console.
Waveform data are saved as `evidence/clu_directed.wlf`, `evidence/clu_directed.vcd`
and `evidence/c5g_interface.wlf`.

The scripts default to `C:\altera_lite\25.1std`. For another installation, pass
`-QuartusRoot` to either `run_sim.ps1` or `build.ps1`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\run_sim.ps1 -QuartusRoot 'D:\altera_lite\25.1std'
```

If you change VHDL later, rerun both simulation and compilation. The supplied
waveform plots/report figures describe the version that was actually tested.

## 3. View the waveforms

Open Questa. In its **Transcript** pane paste:

```tcl
cd C:/fpga/clu_project/sim
do gui.do
```

The Wave window should contain A, B, OP, R, Z, C, N, LT. A/B/R use hex; OP uses
binary. If the wave panel is hidden, choose **View > Wave**. Use **Zoom Full**.
The sequence finishes at 270 ns; no running clock is needed by this testbench.
The included simulation images cover the following:

| File in `evidence/` | Contents |
|---|---|
| `questa_all_operations.png` | Questa Wave window showing all 27 directed cases |
| `questa_arithmetic.png` | Questa arithmetic close-up, 0-90 ns |
| `questa_pass.png` | Questa test results |
| `wave_arithmetic.png` | Plot of addition, subtraction and flags |
| `wave_logic.png` | Plot of AND, OR and XOR |
| `wave_compare_parity_rotate.png` | Plot of comparison, parity and rotation |

The `wave_*.png` plots are generated from the VCD; SVG versions are also included.
Quartus compilation, timing, pin assignments, core register counts and programming
screenshots are in the same folder.

For example, at 20-30 ns, FF+01 produces 00 with C=1 and Z=1. At 60-70 ns,
03-05 produces FE with C=1, N=1, LT=1. VHDL functional simulation has no device
propagation delays; a vector is held for 10 ns so each case is easy to inspect.

## 4. Compile the Quartus project

1. Start Quartus Prime Lite.
2. Choose **File > Open Project** and open
   `C:\fpga\clu_project\clu_project.qpf`.
3. Check the top-level entity is `clu_c5g_top` and the device is
   `5CGXFC5C6F27C7` (the final N on the chip marking is not part of Quartus's name).
4. Choose **Processing > Start Compilation**. The project already lists all three
   synthesizable VHDL files, the pin assignments and the timing constraints.
   Do not add either testbench as a synthesis source.
5. Wait for successful full compilation. The programming file is
   `output_files\clu_project.sof`.
6. Check **Flow Summary** for the compilation result.
7. In the Compilation Report, expand **Analysis & Synthesis > Resource Utilization
   by Entity**. The row for `clu:unit_under_test` has **0 dedicated registers**.
   The wrapper uses registers to hold inputs; these are outside the combinational CLU.
8. Inspect the Timing Analyzer summary for the 50 MHz target.

Equivalent build command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build.ps1
```

The current build has zero errors. Its documented warnings are constant pins
(LEDR8/9 off, LEDG7 on), the Lite edition's LogicLock notice, and default drive
strength/slew settings for outputs. Every used pin has an explicit physical
location and I/O voltage standard. See the report and `output_files/*.rpt`.

## 5. Prepare and program the C5G

1. With power off, set the **rear S1/S2 DIP switches to ON** for the HEX2/HEX3
   display connections, as described in the C5G manual. Leave the GPIO expansion
   header disconnected because those displays share GPIO pins.
2. Put the board's RUN/PROG switch in **RUN** for JTAG use. Connect power and the
   USB-Blaster USB cable, then power on.
3. In Quartus choose **Tools > Programmer**.
4. Choose **Hardware Setup**, select **USB-Blaster [USB-0]**, then close that dialog.
5. Set the programming mode to **JTAG**.
6. Use **Auto Detect** if needed. If asked for the exact device variant, choose
   **5CGXFC5C6** for this board. The project itself targets 5CGXFC5C6F27C7.
7. Add `C:\fpga\clu_project\output_files\clu_project.sof` with **Add File**, or use
   **Change File** on the detected FPGA row. Keep one FPGA row for the one physical
   FPGA; remove a duplicate row if adding the file created one.
8. Tick **Program/Configure** on that row and click **Start**.
9. Wait until progress reaches **100% (Successful)**.
10. Press and release **KEY3** to reset the stored operands and operation.

Programming the SOF configures volatile FPGA memory. After a power cycle the
factory configuration returns; load this SOF again for your demonstration.

## 6. Board controls and example

The C5G has ten switches, so it cannot directly present all 19 independent A/B/OP
bits at once. The wrapper stores A, B and OP on separate button presses. The CLU
continuously computes from those stored values.

| Board control | Action |
|---|---|
| SW7..SW0 | Data byte; SW0 is the least significant bit. UP=1, DOWN=0 |
| KEY0 | Press/release to load SW7..SW0 into A |
| KEY1 | Press/release to load SW7..SW0 into B |
| KEY2 | Press/release to load SW2..SW0 into OP; SW7..SW3 do not matter |
| KEY3 | Reset A=00, B=00, OP=000 |
| SW9 SW8 = 00 | HEX3 HEX2 show stored A |
| SW9 SW8 = 01 | HEX3 HEX2 show stored B |
| SW9 SW8 = 10 | HEX3 HEX2 show the current switch data byte |
| SW9 SW8 = 11 | HEX3 HEX2 show the stored OP, 00..07 |

Set the data switches **before** pressing a load button, then press/release only
that button. Holding a button captures once; switch changes while it is held do
not load new values. Settle the switches by hand before each press. The two-stage
synchronizers reduce metastability risk, but are not an atomic bus-transfer
protocol for switches that are moving during a press.

| Indicator | Meaning |
|---|---|
| HEX1 HEX0 | Result in hex, continuously shown |
| LEDR7..LEDR0 | Result in binary; LEDR0 is bit 0 |
| LEDR9..LEDR8 | Always off |
| LEDG0 | Zero Z |
| LEDG1 | Carry/borrow C |
| LEDG2 | Result MSB N |
| LEDG3 | Unsigned less-than LT |
| LEDG6..LEDG4 | OP2..OP0, respectively |
| LEDG7 | Always on as an indicator that this design is loaded |

### Report example: 13 + 25 = 38 (hexadecimal)

1. Press KEY3.
2. Set SW9=0, SW8=0. Set SW7..SW0 to **00010011** (SW4, SW1 and SW0 up).
3. Press/release KEY0. HEX3 HEX2 should show **13**.
4. Set SW7..SW0 to **00100101** (SW5, SW2 and SW0 up), then press/release KEY1.
5. Set SW2..SW0 to **000**, then press/release KEY2 to select addition.
6. HEX1 HEX0 should show **38**. LEDR5, LEDR4 and LEDR3 show the result in binary.
   LT=1 and Z=C=N=0, so LEDG3 and LEDG7 are on.
7. Set SW9=0, SW8=1 to inspect B=25, then SW9=1, SW8=1 to inspect OP=00.

Section 6 of the report lists the expected results for all eight operations with
these operands and includes the board photographs and demonstration sequence.

## 7. Regenerate the report and plots

Install the documentation dependencies once:

```powershell
python -m pip install -r scripts/requirements-docs.txt
```

After rerunning the simulation, regenerate its plots if needed:

```powershell
python scripts/make_waveforms.py
```

After editing `docs/REPORT.md`, rebuild the PDF:

```powershell
python scripts/build_report_pdf.py
```

These commands update the existing plots and PDF. The simulation runner prints
its results in the console without creating a separate log or status file.
Quartus and Questa create working folders such as `db/`, `incremental_db/` and
`sim/work/` when run. These are generated caches and are excluded from Git;
they are not needed in the assignment submission. Temporary previews under
`tmp/` and Python `__pycache__/` folders are also excluded.

