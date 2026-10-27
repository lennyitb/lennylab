#!/usr/bin/env python3
"""PicoScope CSV exports (../lab 6 assets/picoscope) -> data/scope-*.dat.

Part IV captures, one per circuit and direction, all on the +-50 V range at
50 s/div (Circuit 3 at 100 s/div). Samples are every 0.5 ms (1 ms for
Circuit 3) and the ADC steps are 0.46 V, so everything here works on bin
means: the noise dithers between steps and the means resolve far finer.

For each capture the script
  - finds the plateau before the switch flip: the capacitor shorted through
    47 ohm before charging, or charged through 47 ohm before discharging;
  - fits v = Vinf + A exp(-(t - ts)/tau) from the flip to 4 nominal tau (or
    to the first disturbance), and takes the flip time t0 as the moment the
    fitted curve leaves the plateau voltage;
  - writes the trace with time from t0 in multiples of the nominal tau
    (data/scope-c1.dat ...), a finer copy around 1 tau for the insets
    (data/scope-c1-zoom.dat) and a copy in seconds for the cover art
    (data/scope-cover-c1.dat), all shifted down by the scope's zero offset.

Zero offset: with the capacitor shorted through 47 ohm the scope reads
about +0.4 V, so every trace is shifted down by the mean of the four shorted
plateaus. With that shift the 47-ohm-charged plateau reads 14.9 V against
the 15.008 V the DMM measured on the supply.

Discharge plateaus sit exactly on one ADC step (15.317 V) and barely
dither, so the visible start of a decay lags the real flip by 0.23 V
divided by the slope (1.5-2 s for Circuits 2 and 3). The fitted t0 does
not have that lag, which is why the flip is taken from the fit.

Circuit 4's discharge was first saved only as 32s-d.psdata (PicoScope's
own format) and exported to 32s-d.csv on 2026-10-20. It is the one capture
that starts shorted (reading -0.04 V, not +0.4 V), with a false start at
-9.5 s before the 47-ohm charge; the plateau finder starts after both.

Run with python3 -I make-scope-data.py; standard library only.
"""
import csv
import math
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / "lab 6 assets" / "picoscope"
DATA = HERE / "data"

R = 1e6
R_VM = 9.598e6                       # 4.1: 1 Mohm * 13.592 / (15.008 - 13.592)
V_S = 15.008                         # supply, measured on the DMM
V_MAX = V_S * R_VM / (R_VM + R)      # 13.59 V
TARGET_CHARGE = 0.632 * V_MAX        # 8.59 V, where the stopwatch was stopped
XMIN, XMAX = -0.3, 5.35              # plotted window, in nominal tau
COVER_END = 272                      # cover art window, in seconds from the flip

# (direction, circuit): candidate files (first that exists), nominal tau (s)
CAPTURES = [
    ("c", 1, ["47s-c/47s-c_1.csv"], 47.0),
    ("c", 2, ["100s-c.csv"], 100.0),
    ("c", 3, ["147s-c-0002/147s-c-0002_1.csv"], 147.0),   # the 100 s/div retake
    ("c", 4, ["32s-c.csv"], 31.97),
    ("d", 1, ["47s-d.csv"], 47.0),
    ("d", 2, ["100s-d/100s-d_1.csv"], 100.0),
    ("d", 3, ["143s-d.csv"], 147.0),                      # Circuit 3, despite the name
    ("d", 4, ["32s-d.csv", "32s-d/32s-d_1.csv"], 31.97),
]


def load(path):
    """Return (t, v) lists; PicoScope's two header lines and blank are skipped."""
    t, v = [], []
    with open(path, newline="") as f:
        for row in csv.reader(f):
            try:
                a, b = float(row[0]), float(row[1])
            except (ValueError, IndexError):
                continue
            t.append(a)
            v.append(b)
    return t, v


def bins(t, v, width, lo=-math.inf, hi=math.inf):
    """Mean time and mean voltage of each `width`-second bin inside [lo, hi]."""
    out, edge, st, sv, n = [], None, 0.0, 0.0, 0
    for a, b in zip(t, v):
        if a < lo or a > hi:
            continue
        if edge is None:
            edge = a
        if a - edge >= width:
            out.append((st / n, sv / n))
            edge, st, sv, n = a, 0.0, 0.0, 0
        st += a
        sv += b
        n += 1
    if n:
        out.append((st / n, sv / n))
    return out


def solve3(A, b):
    M = [row[:] + [bb] for row, bb in zip(A, b)]
    for i in range(3):
        p = max(range(i, 3), key=lambda r: abs(M[r][i]))
        M[i], M[p] = M[p], M[i]
        for r in range(3):
            if r != i:
                f = M[r][i] / M[i][i]
                for c in range(i, 4):
                    M[r][c] -= f * M[i][c]
    return [M[i][3] / M[i][i] for i in range(3)]


def fit_exp(pts, ts, vinf, amp, tau):
    """Gauss-Newton fit of v = vinf + amp exp(-(t - ts) k); returns vinf, amp, tau, rms."""
    k = 1.0 / tau
    for _ in range(100):
        JTJ = [[0.0] * 3 for _ in range(3)]
        JTr = [0.0] * 3
        sse = 0.0
        for t, y in pts:
            e = math.exp(-k * (t - ts))
            r = y - (vinf + amp * e)
            sse += r * r
            J = (1.0, e, -amp * (t - ts) * e)
            for i in range(3):
                JTr[i] += J[i] * r
                for j in range(3):
                    JTJ[i][j] += J[i] * J[j]
        d = solve3(JTJ, JTr)
        vinf, amp, k = vinf + d[0], amp + d[1], k + d[2]
        if max(abs(x) for x in d) < 1e-12:
            break
    return vinf, amp, 1.0 / k, math.sqrt(sse / len(pts))


def analyse(direction, t, v, tau_n):
    """Plateau, flip and fit for one capture, in raw scope volts."""
    b = bins(t, v, 0.1)
    rising = direction == "c"
    sgn = 1 if rising else -1
    # Start of the run: the first bin at the shorted (charging) or charged
    # (discharging) level, then the half-way crossing of the main transient.
    i0 = next(i for i, (_, y) in enumerate(b) if (y < 1.0 if rising else y > 14.5))
    if rising:
        vtop = max(y for _, y in b[i0:])
        ih = next(i for i in range(i0, len(b)) if b[i][1] > 0.5 * vtop)
        plat_ok = lambda y: y < 0.6           # shorted plateau reads about 0.4 V
    else:
        vtop = sum(y for _, y in b[i0 + 2:i0 + 10]) / 8
        ih = next(i for i in range(i0, len(b)) if b[i][1] < 0.5 * vtop)
        plat_ok = lambda y: y > vtop - 0.15
    # Walk back from the half-way point to the plateau, then along it, on
    # 0.5 s bins so a noisy 0.1 s bin on the slope can't pass for the plateau.
    bd = bins(t, v, 0.5, b[i0][0], b[ih][0])
    i_flip = next(i for i in range(len(bd) - 1, -1, -1) if plat_ok(bd[i][1]))
    i_start = i_flip
    while i_start > 0 and plat_ok(bd[i_start - 1][1]):
        i_start -= 1
    t_rough = bd[i_flip][0] + 0.25
    p_lo = bd[i_start][0]
    p_hi = max(p_lo + 0.3, t_rough - 0.03 * tau_n)
    plat = [y for x, y in b if p_lo <= x <= p_hi]
    v0 = sum(plat) / len(plat)
    # End of the run: the next big step (the 47 ohm leg switched back in).
    i_end = next((i for i in range(ih, len(b) - 1) if abs(b[i + 1][1] - b[i][1]) > 1.0),
                 len(b) - 1)
    t_end = b[i_end][0] - 0.5
    # First disturbance: a 1 s mean moving against the trend by > 0.08 V.
    sec = bins(t, v, 1.0, t_rough + 0.5 * tau_n, t_end)
    t_dist = next((sec[i + 1][0] - 1.0 for i in range(len(sec) - 1)
                   if -sgn * (sec[i + 1][1] - sec[i][1]) > 0.08), t_end)
    # Fit from just after the flip to 4 nominal tau.
    fit_hi = min(t_end, t_dist, t_rough + 4 * tau_n)
    pts = bins(t, v, tau_n / 200, t_rough + 0.5, fit_hi)
    vinf, amp, tau, rms = fit_exp(pts, t_rough, pts[-1][1], v0 - pts[-1][1], tau_n)
    t0 = t_rough + tau * math.log(amp / (v0 - vinf))
    return dict(v0=v0, vinf=vinf, tau=tau, t0=t0, rms=rms, plateau=(p_lo, p_hi),
                t_start=p_lo, t_end=t_end, t_dist=t_dist, fit_hi=fit_hi,
                n_fit=len(pts))


def crossing(t, v, t0, level, rising, width=0.1):
    """Time after t0 at which the binned trace first reaches `level`."""
    prev = None
    for x, y in bins(t, v, width, t0, math.inf):
        if (y >= level) if rising else (y <= level):
            if prev is None:
                return x - t0
            (xp, yp) = prev
            return xp + (x - xp) * (level - yp) / (y - yp) - t0
        prev = (x, y)
    return float("nan")


def write(name, rows):
    with open(DATA / name, "w") as f:
        f.write("x v\n")
        for x, y in rows:
            f.write(f"{x:.5f} {y:.4f}\n")


def main():
    loaded, results = {}, {}
    for direction, n, names, tau_n in CAPTURES:
        path = next((SRC / nm for nm in names if (SRC / nm).exists()), None)
        if path is None:
            print(f"{direction}{n}: no CSV ({', '.join(names)}); panel stays a placeholder")
            continue
        t, v = load(path)
        loaded[(direction, n)] = (t, v, tau_n, path.name)
        results[(direction, n)] = analyse(direction, t, v, tau_n)

    # Zero offset: mean of the shorted plateaus before each charge.
    shorted = [results[k]["v0"] for k in results if k[0] == "c"]
    offset = sum(shorted) / len(shorted)
    print(f"zero offset: {offset:.3f} V (shorted plateaus "
          f"{', '.join(f'{x:.3f}' for x in shorted)})\n")

    lines = [f"# zero offset {offset:.3f} V; V_MAX {V_MAX:.3f} V; "
             f"8.59 V target {TARGET_CHARGE:.3f} V; times in s from the flip",
             "# key  file  tau_nom  tau_fit  vs_RC%  vs_adj%  V0  Vinf  t(63.2%)  "
             "t(8.59V)  t(5.52V)  rms_mV  fit_to"]
    adj = R * R_VM / (R + R_VM) / R          # 0.9056
    tex = []
    for key, (t, v, tau_n, fname) in loaded.items():
        r = results[key]
        rising = key[0] == "c"
        v0, vinf = r["v0"] - offset, r["vinf"] - offset
        lvl = r["v0"] + 0.632 * (r["vinf"] - r["v0"])
        t63 = crossing(t, v, r["t0"], lvl, rising)
        t859 = crossing(t, v, r["t0"], TARGET_CHARGE + offset, True) if rising else float("nan")
        t552 = crossing(t, v, r["t0"], 0.368 * 15 + offset, False) if not rising else float("nan")
        line = (f"{key[0]}{key[1]}  {fname:<22} {tau_n:7.2f} {r['tau']:8.2f} "
                f"{100 * (r['tau'] / tau_n - 1):+6.1f} {100 * (r['tau'] / (adj * tau_n) - 1):+6.1f} "
                f"{v0:6.2f} {vinf:6.2f} {t63:8.2f} {t859:8.2f} {t552:8.2f} "
                f"{1000 * r['rms']:6.1f} {r['fit_hi'] - r['t0']:7.1f}")
        lines.append(line)
        print(line)
        print(f"      plateau {r['plateau'][0]:.1f}..{r['plateau'][1]:.1f} s, flip {r['t0']:.2f} s, "
              f"run ends {r['t_end']:.1f} s, first disturbance {r['t_dist']:.1f} s, "
              f"{r['n_fit']} fit points")

        # Main trace: bins of tau/100 from the start of the plateau.
        lo = max(r["t_start"] + 0.1, r["t0"] + XMIN * tau_n)
        hi = min(r["t_end"], r["t0"] + XMAX * tau_n)
        rows = [((x - r["t0"]) / tau_n, y - offset) for x, y in bins(t, v, tau_n / 100, lo, hi)]
        write(f"scope-{key[0]}{key[1]}.dat", rows)
        # Inset: bins of tau/400 from 0.7 to 1.3 tau.
        rows = [((x - r["t0"]) / tau_n, y - offset)
                for x, y in bins(t, v, tau_n / 400, r["t0"] + 0.7 * tau_n, r["t0"] + 1.3 * tau_n)]
        write(f"scope-{key[0]}{key[1]}-zoom.dat", rows)
        # Cover: 1 s bins in seconds from the flip, over the span every run
        # covers (Circuit 4 charging ends at 277 s; its discharge stops
        # short at 238 s, already at 0 V).
        rows = [(x - r["t0"], y - offset)
                for x, y in bins(t, v, 1.0, max(r["t_start"] + 0.1, r["t0"] - 2),
                                 min(r["t_end"], r["t0"] + COVER_END))]
        write(f"scope-cover-{key[0]}{key[1]}.dat", rows)

        # Values for plots/scope.tex: tau and the 63.2 % level as the inset
        # draws them, and the verdict tag.
        tex.append(f"% {key[0]}{key[1]}: {fname}")
        for name, val in (("tau", f"{r['tau'] / tau_n:.4f}"),
                          ("taus", f"{r['tau']:.1f}" if r["tau"] < 100 else f"{r['tau']:.0f}"),
                          ("err", f"{100 * (r['tau'] / tau_n - 1):+.1f}"),
                          ("level", f"{lvl - offset:.3f}"),
                          ("vinf", f"{vinf:.2f}"),
                          ("vzero", f"{v0:.2f}")):
            tex.append(f"\\expandafter\\def\\csname scope-{key[0]}{key[1]}-{name}\\endcsname{{{val}}}")

    with open(DATA / "scope-summary.txt", "w") as f:
        f.write("\n".join(lines) + "\n")
    with open(DATA / "scope-values.tex", "w") as f:
        f.write("% Written by make-scope-data.py; do not edit.\n"
                f"% Zero offset {offset:.3f} V. tau is the fitted tau over the nominal R*C;\n"
                "% level is 63.2 % of the way from the plateau to the fitted final value.\n")
        f.write("\n".join(tex) + "\n")


if __name__ == "__main__":
    sys.exit(main())
