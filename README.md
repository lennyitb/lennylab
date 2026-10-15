# phelanlab

A LaTeX document class for clean, consistent lab reports. It gives you a two-line header block and large title, styled tables, figure and caption defaults, question/answer boxes, and units that don't break across lines. Write the content and the class handles the formatting.

It was built for electronics lab reports (circuits, microcontrollers) and mirrors a matching Word style set, but nothing in it is specific to one course.

## Requirements

- **LuaLaTeX.** The class uses system OpenType fonts, so pdfLaTeX won't work. Any recent TeX Live or MacTeX includes LuaLaTeX and every package the class loads.
- **Fonts:**
  - Minion Pro (body text)
  - Myriad Pro (headings, table headers, questions)
  - STIX Two Math (maths symbols, free)

  Minion Pro and Myriad Pro are Adobe fonts; they come with Adobe Acrobat and Adobe Fonts. To use other fonts, change the `% ---------- Fonts ----------` section of `phelanlab.cls`. Myriad Pro is loaded by file name (`MYRIADPRO-REGULAR.OTF`, etc.), so check that the names match the files on your system.

## Install

Either copy `phelanlab.cls` next to your `.tex` file, or put it in your personal TeX tree so every document can find it:

```bash
mkdir -p "$(kpsewhich -var-value TEXMFHOME)/tex/latex/phelanlab"
```

```bash
ln -s "$PWD/phelanlab.cls" "$(kpsewhich -var-value TEXMFHOME)/tex/latex/phelanlab/"
```

A symlink means edits to the class here apply to every report the next time you build it.

## Quick start

```latex
\documentclass{phelanlab}

\newquantity{\Vth}{V}{TH}

\title{Thevenin Equivalent}
\author{Your Name}
\date{2026-09-28}
\labnumber{05}
\course{ELT-1031}
\instructor{Prof. Smith}
\footertext{Name -- ELT-1031 -- Lab 05}

\begin{document}
\maketitle

\section*{Objective}
Measure \Vth{} and compare it with the calculated \qty{6.00}{\volt}.

\section{Part I: Measurements}
\begin{table}
  \begin{labtable}{X[2]X[1]X[1]}
    Quantity & Calculated & Measured \\
    \Vth     & \qty{6.00}{\volt} & \qty{6.02}{\volt} \\
  \end{labtable}
  \caption{Thevenin voltage.}
\end{table}

\begin{question}Why do the values differ?\end{question}
\begin{answer}Resistor tolerance.\end{answer}
\end{document}
```

Build it with:

```bash
latexmk -lualatex report.tex
```

`template/` has a fuller starter report and a `.latexmkrc` that selects LuaLaTeX and can copy the finished PDF to a submission file name. In VS Code with LaTeX Workshop, set `"latex-workshop.latex.recipe.default": "latexmk (lualatex)"`.

## Commands

| Need | Write |
|---|---|
| Header block and title | `\maketitle`, using `\author`, `\date`, `\labnumber`, `\course`, `\instructor` |
| Number with unit | `\qty{10.01}{\volt}`, `\qtyrange{0.7}{2.7}{\percent}` (from siunitx) |
| Named quantity | `\newquantity{\Vth}{V}{TH}` in the preamble, then `\Vth` in text or maths |
| Figure | `\fig{0.6}{file}{Caption.}{fig:label}` (width as a fraction of the text width) |
| Table | `labtable` environment inside `table`; columns are tabularray `X[weight]` specs |
| Empty table cell | `\pending` (shaded placeholder) |
| Question and answer | `question` and `answer` environments; `\begin{question}[Q2b]` sets a custom label |
| Footer text | `\footertext{...}` in the preamble (bottom left; page number is bottom right) |

## Layout notes

- Sections are unnumbered on the page; subsections are numbered (1.1, 1.2). Use `\section*` for front matter like Objective and Equipment so that Part I is section 1.
- Figures and tables stay where you write them instead of floating.
- A section that would start in the bottom 40 % of a page moves to the next page. Change this with `\setlength{\sectionneedspace}{...}`.
- Text is left-aligned with no hyphenation, 12 pt on 1.16 line spacing, with space between paragraphs instead of indents.
- Use `equation*` for unnumbered equations. Numbered ones show small grey numbers.

## License

[MIT](LICENSE)
