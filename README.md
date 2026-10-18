# phelanlab

My own LaTeX style for lab reports. The page layout is inspired by the Tufte-style book: a narrow text column with a wide margin beside it for notes, small tables and figures, plus a full cover page and blocks that run across both columns. The type, tables, units and colours are my own house style: Minion Pro for the text and Myriad Pro for the headings.

The sample below is a real report of mine, an RC transient lab. Its source and PDF are in [`showcase/`](showcase/).

[![Cover: author, title and a full-page plot of four RC charging and discharging curves](showcase/pages/page-1.png)](showcase/phelan-lab06.pdf)
[![Page 2: four circuit diagrams across the full width, equations, and a side note and table in the margin](showcase/pages/page-2.png)](showcase/phelan-lab06.pdf)
[![Page 3: a full-width table, then text with a side note and a screenshot in the margin](showcase/pages/page-3.png)](showcase/phelan-lab06.pdf)
[![Page 5: two plots with captions in the margin, and a close-up plot in the margin](showcase/pages/page-5.png)](showcase/phelan-lab06.pdf)

## Inside

- `phelanbook.cls`: the Tufte-inspired layout
- `phelanstyle.sty`: the shared house style (fonts, colours, tables, units, question and answer boxes)
- `phelanlab.cls`: the earlier single-column class, on the same house style
- `showcase/`: the report above, with its pgfplots and circuitikz sources

It builds with LuaLaTeX and needs Minion Pro, Myriad Pro and STIX Two Math installed. The comments at the top of each class list its commands.

## License

[MIT](LICENSE)
