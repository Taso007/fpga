"""Plot real Questa VCD data. Requires matplotlib; does not simulate the DUT."""
from pathlib import Path
import re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence"
NAMES = ("a", "b", "op", "r", "z", "c", "n", "lt")


def read_vcd(path):
    definitions, state, snapshots = {}, {}, []
    timestamp = None
    in_definitions = True

    def snapshot():
        values = {name: 0 for name in NAMES}
        for code, (name, bit) in definitions.items():
            if name not in values:
                continue
            value = state.get(code, "x")
            if value not in ("0", "1"):
                raise ValueError(f"Unknown value for {name} at {timestamp} ns")
            values[name] |= int(value) << bit
        return values

    contents = path.read_text()
    if not re.search(r"\$timescale\s+1ns\s+\$end", contents):
        raise ValueError("Expected VCD timescale 1ns")
    for raw in contents.splitlines():
        line = raw.strip()
        if in_definitions:
            if line.startswith("$var"):
                fields = line.split()
                code, name = fields[3:5]
                bit = int(fields[5][1:-1]) if fields[5].startswith("[") else 0
                definitions[code] = (name, bit)
            elif line == "$enddefinitions $end":
                in_definitions = False
            continue
        if line.startswith("#"):
            if timestamp is not None:
                snapshots.append((timestamp, snapshot()))
            timestamp = int(line[1:])
        elif line == "$dumpoff":
            # Questa writes X placeholders at dump termination; they are not DUT values.
            break
        elif line and line[0] in "01xXzZ":
            state[line[1:]] = line[0].lower()
    if timestamp is not None:
        snapshots.append((timestamp, snapshot()))
    return snapshots


def plot_waveforms(samples, start, end, filename, subtitle):
    fig, axes = plt.subplots(8, 1, figsize=(15, 7.8), sharex=True,
                             gridspec_kw={"height_ratios": [1.2] * 4 + [0.8] * 4})
    fig.patch.set_facecolor("#f5f7fb")
    selected = [(t, v) for t, v in samples if start <= t < end]
    for i, name in enumerate(NAMES):
        ax = axes[i]
        ax.set_facecolor("white")
        ax.set_xlim(start, end)
        ax.set_ylim(-0.1, 1.1)
        ax.set_yticks([])
        ax.set_ylabel(name.upper(), rotation=0, labelpad=30, fontsize=11,
                      fontweight="bold", color="#162b46")
        for side in ("left", "right", "top"):
            ax.spines[side].set_visible(False)
        ax.spines["bottom"].set_color("#d6dfeb")
        ax.grid(axis="x", color="#e1e8f0", linewidth=0.8)
        if i < 4:
            for t, values in selected:
                t1 = min(t + 10, end)
                vertices = [(t, 0.5), (t + 0.5, 0.12), (t1 - 0.5, 0.12),
                            (t1, 0.5), (t1 - 0.5, 0.88), (t + 0.5, 0.88)]
                color = "#e1efff" if name != "r" else "#d9f4eb"
                ax.add_patch(Polygon(vertices, closed=True, facecolor=color,
                                     edgecolor="#31668b", linewidth=0.8))
                label = f'{values[name]:03b}' if name == "op" else f'{values[name]:02X}'
                ax.text((t + t1) / 2, 0.5, label, ha="center", va="center",
                        fontsize=8.5, family="monospace", color="#112b43")
        else:
            times = [t for t, _ in selected] + [end]
            values = [v[name] for _, v in selected] + [selected[-1][1][name]]
            ax.step(times, values, where="post", color="#15786c", linewidth=1.7)
            ax.text(end + (end-start)*0.005, 0, "0", fontsize=8, va="center")
            ax.text(end + (end-start)*0.005, 1, "1", fontsize=8, va="center")
    axes[-1].set_xticks(range(start, end + 1, 10))
    axes[-1].set_xlabel("Simulation time (ns); A, B, R in hexadecimal; OP in binary", fontsize=10)
    fig.suptitle("8-bit CLU | " + subtitle, x=0.08, ha="left", y=0.97,
                 fontsize=18, fontweight="bold", color="#162b46")
    fig.text(0.08, 0.018, "Source: actual Questa functional simulation, evidence/clu_directed.vcd. "
             "Zero-delay RTL; this plot is not a simulator screenshot.", fontsize=9, color="#52637a")
    fig.subplots_adjust(left=0.08, right=0.96, top=0.89, bottom=0.10, hspace=0.18)
    fig.savefig(EVIDENCE / f"{filename}.png", dpi=400)
    fig.savefig(EVIDENCE / f"{filename}.svg")
    plt.close(fig)


def main():
    samples = read_vcd(EVIDENCE / "clu_directed.vcd")
    vectors = [(t, values) for t, values in samples if t < samples[-1][0]]
    if len(vectors) != 27 or samples[-1][0] != 270:
        raise ValueError("Unexpected directed stimulus; update plot windows before regenerating")
    plot_waveforms(samples, 0, 90, "wave_arithmetic", "addition, carry and subtraction borrow")
    plot_waveforms(samples, 90, 150, "wave_logic", "AND, OR and XOR")
    plot_waveforms(samples, 150, 270, "wave_compare_parity_rotate", "comparison, parity and custom rotation")
    print("Created three PNG/SVG plots from 27 VCD vectors.")


if __name__ == "__main__":
    main()
