% lennylab.cls -- Lenny Phelan's lab report style on a Tufte-style page
%
% A narrow text column with a wide note margin on the right, a full cover
% page, and blocks that can span both. Minion Pro text, Myriad Pro headings,
% house tables, units and question/answer boxes.
% Compile with LuaLaTeX:  latexmk -lualatex report.tex
%
% Page (letter, one-sided):
%   5/8 in | text 4.75 in | 1/4 in | margin 2.25 in | 5/8 in
%   Full width (text + gap + margin) is 7.25 in: \fulltextwidth.
%
% Usage:
%   \documentclass{lennylab}   % [offwhitecover]: cover on off-white paper
%   \title{RC Transient Response}
%   \author{Leonard H Phelan IV}
%   \date{2026-10-18}
%   \labnumber{06}
%   \course{ELT-1031}
%   \instructor{prof. Ashworth}
%   \footertext{Phelan · ELT-1031 · Lab 06}    % optional, bottom left
%   \coverart{<tikzpicture or \includegraphics>} % optional, 6.75 x 4.6 in
%   \contentssubpages{inline}  % subsection page numbers: inline, right, none
%   \begin{document}\maketitle \tableofcontents ...   % contents optional
%
% Headings:
%   \section{\headlabel{Part~1}Prelab Calculations}  lead in beige, no colon
%   \section*{...}             listed in the contents too, without a number
%
% Margin material:
%   \sidenote{text}            numbered note; the number goes in the text
%   \sidenote[-2pt]{text}      the same, nudged down (or up, if negative)
%   \marginnote{text}          unnumbered note beside the current line
%   marginfigure / margintable environments: content and \caption, in the margin
%   \marginfig{file}{caption}{label}   an image in the margin
% Text-column floats (figure, table, \fig): the caption goes in the margin,
%   its last line level with the bottom of the figure or table.
% Full width:
%   fullwidth environment       any text or table across text and margin
%   figure* / table*            full-width figure or table, caption below
%   \widefig{width}{file}{caption}{label}  width as a fraction of \fullwidth
% Blocks:
%   question / answer environments, definition{term}, quote
% Notes can't go inside boxes (tables, question/answer, figures): LaTeX
% only places margin notes from running text.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lennylab}[2026/10/26 v1.2 Phelan lab report style, Tufte-style layout]

% ---------- Options ----------
% offwhitecover: print the cover on warm off-white paper (labCoverPaper)
% instead of white. Pages after the cover stay white.
\newif\if@offwhitecover
\DeclareOption{offwhitecover}{\@offwhitecovertrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[11pt,letterpaper]{article}

% ---------- Engine ----------
\RequirePackage{iftex}
\ifPDFTeX
  \ClassError{lennylab}{This class needs LuaLaTeX}{%
    It uses the Minion Pro and Myriad Pro system fonts, which pdfLaTeX
    cannot load.\MessageBreak Build with: latexmk -lualatex yourfile.tex}
\fi

% ---------- Page ----------
\RequirePackage[
  letterpaper,
  left = 0.625in, textwidth = 4.75in,
  marginparsep = 0.25in, marginparwidth = 2.25in,
  top = 0.8in, bottom = 1in, footskip = 0.45in,
]{geometry}
\raggedbottom
\newlength{\fulltextwidth}
\setlength{\fulltextwidth}{\dimexpr\textwidth+\marginparsep+\marginparwidth\relax}
% A section needs this much of the page left, or it moves to the next page.
\newlength{\sectionneedspace}
\setlength{\sectionneedspace}{0.25\textheight}

% ---------- Colors ----------
\RequirePackage[table]{xcolor}
% The page furniture is beige: rules, bands, numbers, block rules and
% caption labels. Charts keep gray axes and grids under their bright data.
\definecolor{labRule}{HTML}{C8B796}       % table top/bottom rules
\definecolor{labRowRule}{HTML}{E4DBC8}    % rules between table rows
\definecolor{labBand}{HTML}{F3EDE1}       % table header row, question and definition bands
\definecolor{labCoverBar}{HTML}{5B3A22}   % the bar down the cover's left edge, dark brown
\definecolor{labAccent}{HTML}{9E8256}     % heading and equation numbers, block rules, caption labels
\definecolor{labPendingBg}{HTML}{FBE3D3}  % unfilled table cells
\definecolor{labPendingFg}{HTML}{A0522D}
\definecolor{labInk}{HTML}{1C5CAB}        % cover and chart ink, the house data blue
\definecolor{labMuted}{HTML}{5C5347}      % cover author and subtitle, caption text
\definecolor{labChartRule}{HTML}{9AA3AD}  % chart axes and ticks
\definecolor{labChartGrid}{HTML}{C6CCD3}  % chart grid
% The cover's paper: off-white in the band's hue, a step lighter than
% labBand so the big lab number and faint cover art still show on it.
% White unless the class option offwhitecover is given; cover art can fill
% with labCoverPaper to match either way.
\definecolor{labOffWhite}{HTML}{FAF7F0}
\if@offwhitecover
  \colorlet{labCoverPaper}{labOffWhite}
\else
  \colorlet{labCoverPaper}{white}
\fi

% ---------- Fonts ----------
% Body: Minion Pro. Headings, table headings, questions: Myriad Pro.
% Math: STIX Two Math for symbols, with Minion letters and digits so
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

% Body: 11 pt on a 15 pt line, to suit the 4.75 in column (about 70
% characters a line).
\renewcommand\normalsize{%
  \@setfontsize\normalsize{11}{15}%
  \abovedisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \abovedisplayshortskip 3\p@ \@plus3\p@
  \belowdisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
  \let\@listi\@listI}
\normalsize
% Extra space between the lines of gather, align and the like (default 3 pt).
\setlength\jot{6pt}

% \labfontsize{10}: that size on 1.2 line spacing.
\newcommand\labfontsize[1]{\fontsize{#1}{1.2\dimexpr#1pt\relax}\selectfont}

% ---------- Equation numbers ----------
% Numbers beside equations are 10 pt and beige; \eqref in the text stays
% body size and black.
\def\tagform@#1{\maketag@@@{\color{labAccent}\labfontsize{10}%
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

\RequirePackage{graphicx}

% ---------- Tables ----------
% \begin{labtable}{X[2]X[1]X[1]}   header row & ... \\  rows ... \end{labtable}
% Full line width; 9 pt Minion; header row Myriad bold on a beige band,
% bottom-aligned; bold first column; tan rules top and bottom, light rules
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
%   8 pt between the question band and its answer, and 16 pt after the
%   answer, a little more than a paragraph break, so each question and
%   answer reads as one block. tcolorbox takes \parskip off every skip, so
%   the answer's before skip must match the question's after skip; at 0 pt
%   the two cancel and the answer touches the band.
\RequirePackage[most]{tcolorbox}
\newcounter{question}
\NewTColorBox{question}{o}{%
  enhanced, unbreakable,
  colback = labBand, colframe = labAccent,
  boxrule = 0pt, leftrule = 3pt, sharp corners,
  left = 8pt, right = 6pt, top = 4pt, bottom = 4pt, boxsep = 0pt,
  before skip = 12pt, after skip = 8pt,
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
  before skip = 8pt, after skip = 16pt,
  halign = flush left}

% ---------- Definitions and quotes ----------
% \begin{definition}{Time constant} ... \end{definition}: the term in Myriad
%   bold, then the definition in Minion, on the beige band with a beige rule.
% \begin{quote} ... \end{quote}: Minion italic beside a thin beige rule.
\NewTColorBox{definition}{m}{%
  enhanced, unbreakable,
  colback = labBand, colframe = labAccent,
  boxrule = 0pt, leftrule = 3pt, sharp corners,
  left = 8pt, right = 6pt, top = 5pt, bottom = 5pt, boxsep = 0pt,
  before skip = 12pt, after skip = 12pt,
  halign = flush left,
  before upper = {{\sffamily\bfseries #1}\hspace{0.75em}}}
\RenewTColorBox{quote}{}{%
  blank, breakable, parbox = false,
  borderline west = {1.5pt}{0pt}{labAccent},
  left = 12pt,
  before skip = 10pt, after skip = 10pt,
  fontupper = \itshape,
  halign = flush left}

% ---------- Quantities ----------
% \newquantity{\Vth}{V}{TH}: in text, an upright V with a real subscript
% (house style); in math, italic V with an upright subscript.
\NewDocumentCommand\newquantity{mmm}{%
  \NewDocumentCommand#1{}{\TextOrMath{#2\textsubscript{#3}}{#2_{\mathrm{#3}}}}%
  \pdfstringdefDisableCommands{\def#1{#2#3}}}

% ---------- Paragraphs ----------
% Left-aligned, no indent, 6 pt between paragraphs, no hyphenation.
\RequirePackage[skip=6pt plus 2pt]{parskip}
\RequirePackage[document]{ragged2e}
\hyphenpenalty=10000
\exhyphenpenalty=10000

% ---------- Headings ----------
% Myriad Pro Bold. Sections are unnumbered on the page; subsections show
% "1.1" in beige.
\RequirePackage{titlesec}
\RequirePackage{needspace}
\titleformat{\section}{\sffamily\bfseries\labfontsize{15}\RaggedRight}{}{0pt}{}
\titleformat{\subsection}{\sffamily\bfseries\labfontsize{12}\RaggedRight}
  {\textcolor{labAccent}{\thesubsection}}{0.4em}{}
\titleformat{\subsubsection}{\sffamily\bfseries\labfontsize{11}\RaggedRight}
  {\textcolor{labAccent}{\thesubsubsection}}{0.4em}{}
\titlespacing*{\section}{0pt}{20pt plus 4pt minus 2pt}{6pt}
\titlespacing*{\subsection}{0pt}{14pt plus 3pt minus 2pt}{4pt}
\titlespacing*{\subsubsection}{0pt}{10pt plus 2pt minus 2pt}{3pt}
\AddToHook{cmd/section/before}{\par\Needspace{\sectionneedspace}}
% Starred sections go in the contents too: no section shows its number, so
% the star only keeps the section counter where it is. The contents line is
% handed to titlesec, which writes it where it writes a numbered section's;
% that also gets hyperref to put a link target on the heading.
\newif\if@labstarsection
\NewCommandCopy\@labsection\section
\RenewDocumentCommand\section{s o m}{%
  \IfBooleanTF{#1}
    {\global\@labstarsectiontrue\@labsection*{#3}}
    {\IfValueTF{#2}{\@labsection[#2]{#3}}{\@labsection{#3}}}}
\AddToHook{cmd/ttl@labelling/before}{%
  \if@labstarsection
    \global\@labstarsectionfalse
    \def\ttl@savewrite{\addcontentsline{toc}{section}{\ttl@savetitle}%
      \nobreak\global\let\ttl@savewrite\@empty}%
  \fi}
% \headlabel{Part~1}: a heading's lead, in beige and set off by a space
% instead of a colon. The PDF bookmark gets it as plain text, and the
% contents hang it in a column of its own. Defined at \begin{document} only
% if the report hasn't defined its own \headlabel.
\newcommand\@headlabel[1]{\textcolor{labAccent}{#1}\hspace{0.4em}}
\AtBeginDocument{%
  \@ifundefined{headlabel}{\DeclareRobustCommand\headlabel{\@headlabel}}{}}

% ---------- Margin notes ----------
% LaTeX moves a note down when it would overlap the one above it. (The
% marginfix package also moves notes up from the page bottom, but it adds a
% blank last page when the last page is full, so it isn't loaded.)
\newcommand\marginfont{\fontsize{8.5}{11}\selectfont\RaggedRight
  \setlength{\parskip}{4pt}}
% Superior figures from Minion Pro for note numbers.
\newcommand\@sidenotemark[1]{{\addfontfeatures{VerticalPosition=Superior}#1}}
\newcounter{sidenote}
\NewDocumentCommand\sidenote{o +m}{%
  \refstepcounter{sidenote}%
  \unskip\@sidenotemark{\thesidenote}%
  \marginpar{\marginfont\IfValueT{#1}{\vspace*{#1}}%
    \@sidenotemark{\thesidenote}\,#2}}
\NewDocumentCommand\marginnote{o +m}{%
  \marginpar{\marginfont\IfValueT{#1}{\vspace*{#1}}#2}}
\let\footnote\sidenote

% ---------- Figures and captions ----------
% Figures and tables stay where they are written (no floating).
% Captions: Minion italic 8.5 pt in warm gray, left-aligned, the label
% ("Figure 3.") in beige. Text-column captions sit in the margin; margin and
% full-width captions sit below their content.
\RequirePackage{float}
\floatplacement{figure}{H}
\floatplacement{table}{H}
\setlength{\intextsep}{10pt plus 2pt minus 2pt}
\RequirePackage{caption}
\DeclareCaptionFont{labcaption}{\fontsize{8.5}{11}\selectfont}
\DeclareCaptionFont{labMuted}{\color{labMuted}}
\DeclareCaptionFont{labAccent}{\color{labAccent}}
\captionsetup{
  font = {labcaption, it, labMuted},
  labelfont = {labcaption, it, labAccent},
  labelsep = period,
  justification = raggedright,
  singlelinecheck = false,
  position = below,
}
% Side caption (the default): typed after the content like any caption,
% but set in a zero-size box that hangs into the margin with its last line
% on the baseline of the content above it. The negative skip cancels the
% line space TeX puts between the content and the caption's empty line.
\DeclareCaptionFormat{side}{%
  \smash{\rlap{\hspace*{\dimexpr\textwidth+\marginparsep\relax}%
    \parbox[b]{\marginparwidth}{\RaggedRight#1#2#3}}}}
\captionsetup{format=side, skip=-\baselineskip}
% In the margin and at full width the caption goes below its content.
\newcommand\@margincaptions{\captionsetup{format=plain, skip=4pt}}
\newcommand\@widecaptions{\captionsetup{format=plain, skip=5pt,
  margin={0pt,\dimexpr\fulltextwidth-\textwidth\relax}}}

% Full-width block: text, a table, an equation across text and margin.
\RequirePackage{changepage}
\newenvironment{fullwidth}
  {\begin{adjustwidth}{0pt}{-\dimexpr\marginparsep+\marginparwidth\relax}}
  {\end{adjustwidth}}

% figure* and table*: full width, caption below in the text-column width.
\RenewDocumentEnvironment{figure*}{O{H}}
  {\begin{figure}[#1]\begin{fullwidth}\@widecaptions}
  {\end{fullwidth}\end{figure}}
\RenewDocumentEnvironment{table*}{O{H}}
  {\begin{table}[#1]\begin{fullwidth}\@widecaptions}
  {\end{fullwidth}\end{table}}

% Margin figure and table. The optional argument moves it down (or up).
% The first line of the margin box is lined up with the text line it was
% called from; the \kern makes that the top of the content, not the bottom
% of its first line.
\NewDocumentEnvironment{marginfigure}{O{0pt} +b}
  {\marginpar{\marginfont\kern\dimexpr#1-0.65em\relax
     \captionsetup{type=figure}\@margincaptions#2}}{}
\NewDocumentEnvironment{margintable}{O{0pt} +b}
  {\marginpar{\marginfont\kern\dimexpr#1-0.65em\relax
     \captionsetup{type=table}\@margincaptions#2}}{}
% marginlabtable: the labtable look sized for the margin, for use inside
% margintable. 8 pt; header row Myriad bold on the gray band; gray rules top
% and bottom, light rules between rows. \begin{marginlabtable}{X[l]X[r]X[r]}
\NewTblrEnviron{marginlabtblr}
\SetTblrInner[marginlabtblr]{
  width = \linewidth,
  rowsep = 1.5pt, colsep = 3pt,
  cells = {valign = m},
  row{1} = {font = \sffamily\bfseries, bg = labBand, valign = f},
  hline{1,Z} = {0.6pt, labRule},
  hline{2-Y} = {0.25pt, labRowRule},
}
\NewDocumentEnvironment{marginlabtable}{m +b}
  {\fontsize{8}{10}\selectfont\begin{marginlabtblr}{#1}#2\end{marginlabtblr}}{}

% \fig{width}{file}{caption}{label}: width is a fraction of the text width.
% Height is capped at 0.4\textheight.
\newcommand{\fig}[4]{%
  \begin{figure}[H]
    \includegraphics[width=#1\linewidth,height=0.4\textheight,keepaspectratio]{#2}
    \caption{#3}\label{#4}
  \end{figure}}
% \widefig{width}{file}{caption}{label}: width is a fraction of \fulltextwidth.
\newcommand{\widefig}[4]{%
  \begin{figure*}
    \includegraphics[width=#1\linewidth,height=0.5\textheight,keepaspectratio]{#2}
    \caption{#3}\label{#4}
  \end{figure*}}
% \marginfig[offset]{file}{caption}{label}
\NewDocumentCommand\marginfig{O{0pt} m m m}{%
  \begin{marginfigure}[#1]
    \includegraphics[width=\linewidth]{#2}
    \caption{#3}\label{#4}
  \end{marginfigure}}

% ---------- Cover page ----------
% \maketitle draws a full cover: the author above the title (as on the
% Tufte sample book's title page, but in normal case), the cover art (or a
% large lab number when there is none), and a footer with the course, lab
% number, instructor and date. No small capitals or letterspaced labels.
% A 1/2 in dark brown bar runs down the left edge, and everything else starts
% 5/8 in past it, at 1 1/8 in, so the cover is 6.75 in wide. With the
% offwhitecover option the whole cover is filled with labCoverPaper first.
% The report starts on page 2.
\RequirePackage{tikz}
\def\@course{ELT-1031}
\def\@instructor{prof. Ashworth}
\def\@labnumber{NN}
\def\@subtitle{}
\def\@coverart{}
\newcommand\course[1]{\def\@course{#1}}
\newcommand\instructor[1]{\def\@instructor{#1}}
\newcommand\labnumber[1]{\def\@labnumber{#1}}
\newcommand\subtitle[1]{\def\@subtitle{#1}}
\newcommand\coverart[1]{\def\@coverart{#1}}
\date{\the\year-\two@digits{\the\month}-\two@digits{\the\day}}
\newsavebox\@coverbox
\renewcommand\maketitle{%
  % Art first, in a box: a tikzpicture can't be nested inside the overlay.
  \sbox\@coverbox{\@coverart}%
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay,
      x=1in, y=-1in, shift={(current page.north west)}]
    % The paper, then the bar down the left edge
    \if@offwhitecover
      \fill[labCoverPaper] (0, 0) rectangle (8.5, 11);
    \fi
    \fill[labCoverBar] (0, 0) rectangle (0.5, 11);
    % Author, then the title
    \node[anchor=base west, inner sep=0pt, text=labMuted] at (1.125, 0.95)
      {\itshape\fontsize{22}{26}\selectfont\@author};
    \node[anchor=north west, inner sep=0pt, text width=6.75in, align=left]
      at (1.125, 1.3)
      {\sffamily\bfseries\fontsize{46}{50}\selectfont\RaggedRight\@title\par
       \ifx\@subtitle\@empty\else
         \vspace{10pt}{\rmfamily\mdseries\itshape\fontsize{17}{21}\selectfont
         \color{labMuted}\@subtitle\par}\fi};
    % Cover art, or the lab number in the house band color
    \ifx\@coverart\@empty
      \node[anchor=south east, inner sep=0pt, text=labBand] at (7.875, 9.3)
        {\sffamily\bfseries\fontsize{300}{300}\selectfont\@labnumber};
    \else
      \node[anchor=south west, inner sep=0pt] at (1.125, 9.3)
        {\usebox\@coverbox};
    \fi
    % Footer: rule, then one line across the full width
    %   ELT-1031 · Lab 06 · prof. Ashworth                  2026-10-18
    \draw[labRule, line width=0.6pt] (1.125, 9.6) -- (7.875, 9.6);
    \begin{scope}[every node/.style={inner sep=0pt,
        font=\fontsize{11}{13}\selectfont}]
      \node[anchor=base west] at (1.125, 9.85)
        {\@course\@footsep Lab~\@labnumber\@footsep\@instructor};
      \node[anchor=base east] at (7.875, 9.85) {\@date};
    \end{scope}
  \end{tikzpicture}%
  \null\newpage
  \begingroup
    \let\\\relax
    \hypersetup{pdftitle={\@title}, pdfauthor={\@author}}%
  \endgroup}

% ---------- Footer ----------
% Across the full width: \footertext on the left (default: course, lab
% number and title), page number on the right, 10 pt. No running head.
% Parts of the footer are separated by a centered dot: \@footsep.
\def\@footsep{\enspace\textperiodcentered\enspace}
\def\@footertext{\@course\@footsep Lab~\@labnumber\@footsep\@title}
\newcommand\footertext[1]{\def\@footertext{#1}}
\RequirePackage{fancyhdr}
\fancypagestyle{plain}{%
  \fancyhf{}%
  \fancyhfoffset[R]{\dimexpr\marginparsep+\marginparwidth\relax}%
  \fancyfoot[L]{\labfontsize{10}\@footertext}%
  \fancyfoot[R]{\labfontsize{10}\thepage}%
  \renewcommand\headrulewidth{0pt}%
  \renewcommand\footrulewidth{0pt}}
\pagestyle{plain}

% ---------- Contents ----------
% \tableofcontents: a page of its own, after the cover. The column is as
% wide as the text column but centered on the page, so both side margins
% are 1 7/8 in, and it sits a little above the middle of the page.
% "Contents" in Myriad Pro Bold, then each section in Myriad bold with its
% subsections under it in Minion, their numbers in beige and the page
% numbers flush right, and a light rule between sections like the rules
% between table rows. Heading leads (\headlabel) hang in a column left of
% the titles, as wide as the widest lead, so the titles line up.
\newlength\contentswidth
\setlength\contentswidth{\textwidth}
\setcounter{tocdepth}{2}
\newcommand\@tocsectionfont{\sffamily\bfseries\labfontsize{11.5}}
\newcommand\@tocsubsectionfont{\labfontsize{10.5}}
\newdimen\@tocleadwidth      % lead column, measured from the .toc
\newdimen\@tocnumwidth       % subsection numbers
\newdimen\@tocpagewidth      % page numbers, with the gap before them
\@tocnumwidth=24pt
\@tocpagewidth=0.35in
% The widest lead in the last run's .toc, plus the gap after it.
\newcommand\@measuretocleads{%
  \global\@tocleadwidth\z@
  \begingroup
    \def\contentsline##1##2##3##4{\setbox\z@\hbox{##2}}%
    \def\@headlabel##1{\setbox\tw@\hbox{\@tocsectionfont##1\hskip0.75em}%
      \ifdim\wd\tw@>\@tocleadwidth \global\@tocleadwidth\wd\tw@\fi}%
    \makeatletter
    \InputIfFileExists{\jobname.toc}{}{}%
  \endgroup}
% The rule above every section but the first, midway between it and the
% line above, across the whole column.
\newif\if@tocfirst
\newcommand\@tocrule{%
  \if@tocfirst \global\@tocfirstfalse \else
    \hskip-\leftskip\rlap{\raisebox{17.5pt}[0pt][0pt]{%
      \color{labRowRule}\rule{\linewidth}{0.4pt}}}\hskip\leftskip
  \fi}
\newcommand\@tocheadlabel[1]{%
  \llap{\hb@xt@\@tocleadwidth{\textcolor{labAccent}{#1}\hfil}}\ignorespaces}
% \@tocentry{indent}{title}{page}: ragged title, page number flush right
\newcommand\@tocentry[3]{%
  \parindent\z@ \leftskip#1\relax
  \rightskip\@tocpagewidth\@plus1fil \parfillskip-\@tocpagewidth
  \leavevmode#2\nobreak\hfill\nobreak\hb@xt@\@tocpagewidth{\hss#3}\par}
\renewcommand*\l@section[2]{%
  \ifnum\c@tocdepth>\z@
    \addpenalty\@secpenalty
    \addvspace{14pt plus 2pt}%
    \begingroup
      \@tocsectionfont
      \let\numberline\@gobble
      \let\@headlabel\@tocheadlabel
      \@tocentry\@tocleadwidth{\@tocrule#1}{\normalfont\labfontsize{11}#2}%
    \endgroup
    \nobreak
  \fi}
% Subsection page numbers are small and beige, in one of three places:
%   \contentssubpages{inline}  right after the title (the default), so only
%                              the sections' numbers stand at the right edge
%   \contentssubpages{right}   at the right edge too, a step in from the
%                              sections' numbers
%   \contentssubpages{none}    left out, for a short report where they
%                              mostly repeat their section's page
\newcommand\contentssubpages[1]{%
  \@ifundefined{@tocsubpage@#1}
    {\ClassError{lennylab}{Unknown \string\contentssubpages{#1}}
       {Use inline, right or none.}}
    {\def\@tocsubpages{#1}}}
\newcommand\@tocsubpagefont{\labfontsize{9}\color{labAccent}}
% \@tocsubpage@<style>{indent}{title}{page}
\def\@tocsubpage@inline#1#2#3{%
  \@tocentry{#1}{#2\nobreak\hskip0.6em{\@tocsubpagefont#3}}{}}
\def\@tocsubpage@right#1#2#3{%
  \@tocentry{#1}{#2}{{\@tocsubpagefont#3}\hskip12pt}}
\def\@tocsubpage@none#1#2#3{\@tocentry{#1}{#2}{}}
\contentssubpages{inline}
\renewcommand*\l@subsection[2]{%
  \ifnum\c@tocdepth>\@ne
    \begingroup
      \@tocsubsectionfont
      \def\numberline##1{\hskip-\@tocnumwidth
        \hb@xt@\@tocnumwidth{\textcolor{labAccent}{##1}\hfil}}%
      \@nameuse{@tocsubpage@\@tocsubpages}%
        {\dimexpr\@tocleadwidth+\@tocnumwidth\relax}{#1}{#2}%
    \endgroup
  \fi}
\renewcommand\tableofcontents{%
  \clearpage
  \@measuretocleads
  \begingroup
    \setlength\parskip\z@
    \begin{adjustwidth}
        {\dimexpr(\paperwidth-\contentswidth)/2-1in-\hoffset-\oddsidemargin\relax}
        {\dimexpr\textwidth-(\paperwidth+\contentswidth)/2+1in+\hoffset+\oddsidemargin\relax}
      \vspace*{\stretch{1}}%
      \pdfbookmark[1]{\contentsname}{contents}%
      {\sffamily\bfseries\labfontsize{24}\contentsname\par}%
      \vspace{14pt}%
      \global\@tocfirsttrue
      \@starttoc{toc}%
      \vspace*{\stretch{1.6}}%
    \end{adjustwidth}
  \endgroup
  \clearpage}

% ---------- Links ----------
\RequirePackage[hidelinks, linktoc=all]{hyperref}
\pdfstringdefDisableCommands{\def\headlabel#1{#1 }}

\endinput
