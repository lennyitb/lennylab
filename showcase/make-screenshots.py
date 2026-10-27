#!/usr/bin/env python3
"""phelan-lab06.pdf -> pages/page-N.png for the README.

Renders the cover and pages 2, 3, 5 and 12 with pdftoppm and draws a hairline
border inside each edge, so the white pages show their edges on a white
background. GitHub shows README images 838 CSS px wide on desktop; at twice
that, a 2 px border lands on whole screen pixels on a 2x display and matches
the 1 px frame around the README in GitHub's border gray.

Run it with python3 -I make-screenshots.py after building the PDF; it needs
pdftoppm (poppler) and Pillow.
"""
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
PDF = HERE / "phelan-lab06.pdf"
OUT = HERE / "pages"
PAGES = [1, 2, 3, 5, 12]
WIDTH_PX = 1676            # 2 x 838 CSS px
BORDER = (209, 217, 224)   # GitHub's --borderColor-default, #d1d9e0
WIDTH = 2                  # px; 1 CSS px on GitHub

OUT.mkdir(exist_ok=True)
for p in PAGES:
    stem = OUT / f"page-{p}"
    subprocess.run(["pdftoppm", "-png", "-scale-to-x", str(WIDTH_PX),
                    "-scale-to-y", "-1", "-f", str(p),
                    "-l", str(p), "-singlefile", str(PDF), str(stem)],
                   check=True)
    png = stem.with_suffix(".png")
    img = Image.open(png).convert("RGB")
    w, h = img.size
    ImageDraw.Draw(img).rectangle([0, 0, w - 1, h - 1],
                                  outline=BORDER, width=WIDTH)
    img.save(png, optimize=True)
    print(png.name, f"{w}x{h}")
