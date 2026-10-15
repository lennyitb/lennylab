% phelanlab.cls -- Lenny Phelan's lab report house style
%
% The LaTeX twin of the "Phelan Lab Report" Word style set (Lab Report Kit).
% Compile with LuaLaTeX:  latexmk -lualatex report.tex
%
% Usage:
%   \documentclass{phelanlab}
%   \title{Thevenin Equivalent}
%   \author{Leonard H Phelan IV}
%   \date{2026-09-28}            % lab date, YYYY-MM-DD
%   \labnumber{05}
%   \course{ELT-1031}            % default
%   \instructor{prof. Hartwell} % default
%   \footertext{Phelan -- ELT-1031 -- Lab 05}  % optional, bottom left
%   \begin{document}\maketitle ...
%
% What it provides (see README.md for examples):
%   \newquantity{\Vth}{V}{TH}   V_TH: upright with a real subscript in text,
%                               italic V in math
%   \fig{width}{file}{caption}{label}   centred figure, caption below
%   labtable environment         the "Lab Table" look (tabularray)
%   \pending                     amber "not yet measured" table cell
%   question / answer envs       Q-band and indented answer
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{phelanlab}[2026/10/14 v0.2 Phelan lab report house style]

\RequirePackage{iftex}
\ifPDFTeX
  \ClassError{phelanlab}{This class needs LuaLaTeX}{%
    It uses the Minion Pro and Myriad Pro system fonts, which pdfLaTeX
    cannot load.\MessageBreak Build with: latexmk -lualatex yourfile.tex}
\fi

% ---------- Options ----------
% Anything else (e.g. draft) is passed on to article.
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[12pt,letterpaper]{article}

% ---------- Page ----------
\RequirePackage[margin=1in, footskip=35pt]{geometry}
\raggedbottom
% A section needs this much of the page left, or it moves to the next page
% (Lab 04 rule: a section starting below ~60% of the page gets a break).
% Change it in a report with \setlength{\sectionneedspace}{...}.
\newlength{\sectionneedspace}
\setlength{\sectionneedspace}{0.4\textheight}

% ---------- Colours ----------
\RequirePackage[table]{xcolor}
\definecolor{labRule}{HTML}{9AA3AD}       % table top/bottom rules, question rule
\definecolor{labRowRule}{HTML}{C6CCD3}    % rules between table rows
\definecolor{labBand}{HTML}{E8EBEF}       % table header row, question band
\definecolor{labPendingBg}{HTML}{FDF4E6}  % unfilled table cells
\definecolor{labPendingFg}{HTML}{8A6D3B}
\definecolor{labEqNumber}{HTML}{7A828C}  % equation numbers

% ---------- Fonts ----------
% Body: Minion Pro. Headings, table headings, questions: Myriad Pro.
% Maths: STIX Two Math for symbols, with Minion letters and digits so
% equations match the text.
\RequirePackage{amsmath}
\RequirePackage{unicode-math}
\setmainfont{Minion Pro}
% By file name: by family name, Myriad Pro "Bold" resolves to Semibold.
\setsansfont{MYRIADPRO}[
  Extension = .OTF,
  UprightFont = *-REGULAR,
  BoldFont = *-BOLD,
  BoldItalicFont = *-BOLDIT]
\setmathfont{STIX Two Math}
\setmathfont{Minion Pro}[range={up/{Latin,latin,num}}]
\setmathfont{MinionPro-It.otf}[range={it/{Latin,latin}}]
\setmathrm{Minion Pro}
\RequirePackage{microtype}

% Body: 12 pt on a 16.7 pt line (Word's 1.16 line spacing for Minion).
\renewcommand\normalsize{%
  \@setfontsize\normalsize{12}{16.7}%
  \abovedisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \abovedisplayshortskip 3\p@ \@plus3\p@
  \belowdisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
  \let\@listi\@listI}
\normalsize
\newcommand\labfontsize[1]{\fontsize{#1}{1.2\dimexpr#1pt\relax}\selectfont}

% ---------- Paragraphs ----------
% Left-aligned, no indent, 8 pt between paragraphs, no hyphenation (as Word).
\RequirePackage[skip=8pt plus 2pt]{parskip}
\RequirePackage[document]{ragged2e}
\hyphenpenalty=10000
\exhyphenpenalty=10000

% ---------- Equation numbers ----------
% Numbers beside equations are 10 pt and grey; \eqref in the text stays
% body size and black.
\def\tagform@#1{\maketag@@@{\color{labEqNumber}\labfontsize{10}%
  (\ignorespaces#1\unskip\@@italiccorr)}}
\renewcommand{\eqref}[1]{\textup{(\ref{#1})}}

% ---------- Units ----------
% \qty{10.01}{\volt} -> "10.01 V" with a non-breaking space;
% \qtyrange{0.7}{2.7}{\percent} -> "0.7–2.7 %".
\RequirePackage{siunitx}
\sisetup{
  per-mode = symbol,
  number-unit-product = \nobreakspace,
  range-phrase = \textendash,
  range-units = single,
  list-units = single,
  retain-explicit-plus = true,
}

% ---------- Headings ----------
% Myriad Pro Bold, black. Sections are unnumbered on the page; subsections
% show "1.1" (the Part number, then the subsection).
\RequirePackage{titlesec}
\RequirePackage{needspace}
\titleformat{\section}{\sffamily\bfseries\labfontsize{16}\RaggedRight}{}{0pt}{}
\titleformat{\subsection}{\sffamily\bfseries\labfontsize{13}\RaggedRight}{\thesubsection}{0.3em}{}
\titleformat{\subsubsection}{\sffamily\bfseries\labfontsize{12}\RaggedRight}{\thesubsubsection}{0.3em}{}
\titlespacing*{\section}{0pt}{18pt plus 4pt minus 2pt}{6pt}
\titlespacing*{\subsection}{0pt}{12pt plus 3pt minus 2pt}{4pt}
\titlespacing*{\subsubsection}{0pt}{10pt plus 2pt minus 2pt}{3pt}
\AddToHook{cmd/section/before}{\par\Needspace{\sectionneedspace}}

% ---------- Header block and title ----------
%   Leonard H Phelan IV                2026-09-28
%   ELT-1031 – Lab 05                  prof. Hartwell
%   Title (Myriad Pro Bold 36 pt)
\def\@course{ELT-1031}
\def\@instructor{prof. Hartwell}
\def\@labnumber{NN}
\newcommand\course[1]{\def\@course{#1}}
\newcommand\instructor[1]{\def\@instructor{#1}}
\newcommand\labnumber[1]{\def\@labnumber{#1}}
\date{\the\year-\two@digits{\the\month}-\two@digits{\the\day}}
\renewcommand\maketitle{%
  \begingroup
    \labfontsize{11}\parskip\z@
    \noindent\@author\hfill\@date\par
    \noindent\@course\ \textendash\ Lab~\@labnumber\hfill\@instructor\par
  \endgroup
  \vspace{14pt}%
  {\parskip\z@\sffamily\bfseries\fontsize{36}{40}\selectfont\RaggedRight
   \@title\par}%
  \vspace{2pt}%
  \begingroup
    \let\\\relax
    \hypersetup{pdftitle={\@title}, pdfauthor={\@author}}%
  \endgroup}

% ---------- Footer ----------
% Page number right-aligned, 10 pt. \footertext{...} adds text bottom left
% in the same size; without it the left side stays empty (as in Word).
\def\@footertext{}
\newcommand\footertext[1]{\def\@footertext{#1}}
\RequirePackage{fancyhdr}
\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyfoot[L]{\labfontsize{10}\@footertext}%
  \fancyfoot[R]{\labfontsize{10}\thepage}%
  \renewcommand\headrulewidth{0pt}%
  \renewcommand\footrulewidth{0pt}}
\pagestyle{plain}

% ---------- Figures and captions ----------
% Figures stay where they are written (no floating), centred.
% Captions: Minion italic 10 pt, left-aligned, below figures and tables.
\RequirePackage{graphicx}
\RequirePackage{float}
\floatplacement{figure}{H}
\floatplacement{table}{H}
\setlength{\intextsep}{10pt plus 2pt minus 2pt}
\RequirePackage{caption}
\DeclareCaptionFont{labcaption}{\labfontsize{10}}
\captionsetup{
  font = {labcaption, it},
  labelfont = {labcaption, it},
  labelsep = period,
  justification = raggedright,
  singlelinecheck = false,
  position = below,
  skip = 5pt,
}

% \fig{width}{file}{caption}{label}: width is a fraction of the text width.
% Height is capped so one figure never takes more than ~4.2 in.
\newcommand{\fig}[4]{%
  \begin{figure}[H]
    \centering
    \includegraphics[width=#1\linewidth,height=0.47\textheight,keepaspectratio]{#2}
    \caption{#3}\label{#4}
  \end{figure}}

% ---------- Tables ----------
% \begin{labtable}{X[2]X[1]X[1]}   header row & ... \\  rows ... \end{labtable}
% Full text width; 9 pt Minion; header row Myriad bold on a grey band,
% bottom-aligned; bold first column; grey rules top and bottom, light rules
% between rows, no vertical rules. Column widths are X[weight], so the Word
% widths in dxa can be reused as weights: X[1500]X[2150]...
\RequirePackage{tabularray}
\NewTblrEnviron{labtblr}
\SetTblrInner[labtblr]{
  width = \linewidth,
  rowsep = 2.5pt, colsep = 5pt,
  cells = {valign = m},
  column{1} = {font = \bfseries},
  row{1} = {font = \sffamily\bfseries, bg = labBand, valign = f},
  hline{1,Z} = {0.75pt, labRule},
  hline{2-Y} = {0.25pt, labRowRule},
}
\SetTblrOuter[labtblr]{expand = \pending}
% The 9 pt size is set outside the table so row heights follow it too.
\NewDocumentEnvironment{labtable}{m +b}
  {\fontsize{9}{11}\selectfont\begin{labtblr}{#1}#2\end{labtblr}}{}
% A cell that is still waiting for a value.
\newcommand{\pending}{\SetCell{bg=labPendingBg, fg=labPendingFg}\textemdash}

% ---------- Questions and answers ----------
% \begin{question} restated handout question \end{question}   -> "Q1  ..."
% \begin{question}[Q3b] ... \end{question}                     -> custom label
% \begin{answer} ... \end{answer}   body text indented 0.25 in, kept on one page;
%   16 pt after it, a little more than a paragraph break, so each question
%   and answer reads as one block
\RequirePackage[most]{tcolorbox}
\newcounter{question}
\NewTColorBox{question}{o}{%
  enhanced, unbreakable,
  colback = labBand, colframe = labRule,
  boxrule = 0pt, leftrule = 3pt, sharp corners,
  left = 8pt, right = 6pt, top = 4pt, bottom = 4pt, boxsep = 0pt,
  before skip = 12pt, after skip = 6pt,
  fontupper = \sffamily\fontsize{10}{13.2}\selectfont,
  halign = flush left,
  before upper = {%
    \IfNoValueTF{#1}%
      {\refstepcounter{question}\textbf{Q\thequestion}}%
      {\textbf{#1}}%
    \hspace{0.75em}}}
\NewTColorBox{answer}{}{%
  blank, unbreakable, parbox = false,
  left skip = 0.25in,
  before skip = 0pt, after skip = 16pt,
  halign = flush left}

% ---------- Quantities ----------
% \newquantity{\Vth}{V}{TH}: in text, an upright V with a real subscript
% (house style); in maths, italic V with an upright subscript.
\NewDocumentCommand\newquantity{mmm}{%
  \NewDocumentCommand#1{}{\TextOrMath{#2\textsubscript{#3}}{#2_{\mathrm{#3}}}}%
  \pdfstringdefDisableCommands{\def#1{#2#3}}}

% ---------- Links ----------
\RequirePackage[hidelinks]{hyperref}

\endinput
