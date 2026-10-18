#!/usr/bin/env python3
"""phelan-lab06.pdf -> pages/page-N.png for the README.

Renders the cover and pages 2, 3 and 5 at 150 dpi with pdftoppm and draws a
hairline grey border inside each edge, so the white pages show their edges
on a white background.

Run it with python3 -I make-screenshots.py after building the PDF; it needs
pdftoppm (poppler) and Pillow.
"""
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
PDF = HERE / "phelan-lab06.pdf"
OUT = HERE / "pages"
PAGES = [1, 2, 3, 5]
DPI = 150
BORDER = (175, 184, 193)  # mid grey; paler greys vanish once GitHub scales the image
WIDTH = 3                 # px at 150 dpi; about 2 px as GitHub scales it down

OUT.mkdir(exist_ok=True)
for p in PAGES:
    stem = OUT / f"page-{p}"
    subprocess.run(["pdftoppm", "-png", "-r", str(DPI), "-f", str(p),
                    "-l", str(p), "-singlefile", str(PDF), str(stem)],
                   check=True)
    png = stem.with_suffix(".png")
    img = Image.open(png).convert("RGB")
    w, h = img.size
    ImageDraw.Draw(img).rectangle([0, 0, w - 1, h - 1],
                                  outline=BORDER, width=WIDTH)
    img.save(png, optimize=True)
    print(png.name, f"{w}x{h}")
