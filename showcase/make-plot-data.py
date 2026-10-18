#!/usr/bin/env python3
"""Multisim Grapher exports (data/*.xlsx) -> data/*.dat for pgfplots.

Each export holds X/Y column pairs, one pair per trace, with headers like
"X--Trace 3::[V(8) | V(32s)]". The probe names are the time constants, so a
trace is keyed by the number before the "s" (32, 47, 100, 147).

Scaling and fixes:
  - currents are written in µA (the export is in A);
  - the export writes 0 at t = 0 for the charging current and for the
    discharge voltage and current, where the true values are +15 µA, 15 V and
    -15 µA (the draft's notes on Figures 3, 5, 7 and 8). Those rows are
    replaced so the curves start where the circuit does.

Run it with python3 -I make-plot-data.py; stdlib only. It also prints the
value at 1τ and 5τ of every trace, interpolated linearly between the two
nearest exported points, to check Tables 2 and 3.
"""
import math
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
DATA = HERE / "data"
NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
TAUS = {32: 31.97, 47: 47.0, 100: 100.0, 147: 147.0}


def col_index(ref):
    letters = re.match(r"[A-Z]+", ref).group(0)
    n = 0
    for ch in letters:
        n = n * 26 + ord(ch) - 64
    return n - 1


def read_xlsx(path):
    """Return {header: [floats]} for the first sheet."""
    with zipfile.ZipFile(path) as z:
        strings = [si.findtext("m:t", namespaces=NS) or ""
                   for si in ET.fromstring(z.read("xl/sharedStrings.xml"))
                   .findall("m:si", NS)]
        sheet = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))
    rows = []
    for row in sheet.find("m:sheetData", NS).findall("m:row", NS):
        cells = {}
        for c in row.findall("m:c", NS):
            v = c.findtext("m:v", namespaces=NS)
            if v is None:
                continue
            cells[col_index(c.get("r"))] = strings[int(v)] if c.get("t") == "s" else float(v)
        rows.append(cells)
    header, body = rows[0], rows[1:]
    return {name: [r[i] for r in body if i in r] for i, name in header.items()}


def traces(path):
    """Return {(quantity, tau_key): [(t, y), ...]} from one export."""
    cols = read_xlsx(path)
    out = {}
    for name, xs in cols.items():
        if not name.startswith("X--"):
            continue
        ys = cols["Y--" + name[3:]]
        m = re.search(r"\|\s*(I|V)\((\d+)s\)", name)
        if m:
            key = (m.group(1), int(m.group(2)))
        else:  # single-circuit file: "V(2)" and "I(C1:1)" without a probe name
            key = ("I" if name.startswith("X--") and "I(" in name else "V", 47)
        out[key] = list(zip(xs, ys))
    return out


def interp(points, t):
    for (t0, y0), (t1, y1) in zip(points, points[1:]):
        if t0 <= t <= t1:
            return y0 + (y1 - y0) * (t - t0) / (t1 - t0), (t0, y0), (t1, y1)
    raise ValueError(t)


def write(name, columns, rows):
    with open(DATA / name, "w") as f:
        f.write(" ".join(columns) + "\n")
        for r in rows:
            f.write(" ".join(f"{v:.6g}" for v in r) + "\n")


def main():
    sets = {
        "charge": (traces(DATA / "4 circuit v.xlsx"), traces(DATA / "4 circuit i.xlsx")),
        "discharge": (traces(DATA / "4c discharge v.xlsx"), traces(DATA / "4c discharge i.xlsx")),
    }
    t0_fix = {("charge", "V"): None, ("charge", "I"): 15.0,
              ("discharge", "V"): 15.0, ("discharge", "I"): -15.0}

    for phase, (vt, it) in sets.items():
        print(f"\n{phase}")
        for q, tr in (("V", vt), ("I", it)):
            for (_, key), pts in sorted(tr.items(), key=lambda kv: kv[0][1]):
                scale = 1e6 if q == "I" else 1.0
                pts = [(t, y * scale) for t, y in pts]
                fix = t0_fix[(phase, q)]
                if fix is not None and pts[0][0] == 0:
                    pts[0] = (0.0, fix)
                write(f"{phase}-{q.lower()}-{key}.dat", ["t", "y"], pts)
                tau = TAUS[key]
                y1, a, b = interp(pts, tau)
                y5, _, _ = interp(pts, 5 * tau)
                unit = "uA" if q == "I" else "V"
                print(f"  {q} tau={tau:6.2f}  1tau={y1:8.3f} {unit}"
                      f"  (between t={a[0]:.1f}:{a[1]:.3f} and t={b[0]:.1f}:{b[1]:.3f})"
                      f"  5tau={y5:8.3f}  n={len(pts)}")

    # Circuit 1 alone (Figure 3). Its two traces are V(2) and I(C1:1).
    single = read_xlsx(DATA / "single circuit.xlsx")
    print("\nsingle circuit headers:", list(single))
    pairs = {}
    for name, xs in single.items():
        if name.startswith("X--"):
            ys = single["Y--" + name[3:]]
            q = "I" if "I(" in name else "V"
            pairs[q] = list(zip(xs, ys))
    v = pairs["V"]
    i = [(t, y * 1e6) for t, y in pairs["I"]]
    if i[0][0] == 0:
        i[0] = (0.0, 15.0)
    write("single-v.dat", ["t", "y"], v)
    write("single-i.dat", ["t", "y"], i)
    print("  single V at 47 s:", round(interp(v, 47)[0], 4), " I at 47 s:", round(interp(i, 47)[0], 4))
    print("  single first rows:", v[:4], i[:4])

    # Circuit 4 around its 1τ (the margin figure on interpolation error):
    # the two exported points either side of 31.97 s and the formula there.
    v4 = [(t, y) for t, y in traces(DATA / "4 circuit v.xlsx")[("V", 32)]]
    y, a, b = interp(v4, 31.97)
    exact = 15 * (1 - math.exp(-1))
    print(f"\nCircuit 4: interp {y:.4f} V between {a} and {b}; formula {exact:.4f} V")
    for t, yy in v4[:6]:
        print(f"  t={t:7.3f}  export={yy:.4f}  formula={15*(1-math.exp(-t/31.97)):.4f}")


if __name__ == "__main__":
    sys.exit(main())
