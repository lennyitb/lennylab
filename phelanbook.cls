% phelanbook.cls -- Lenny Phelan's house style on a Tufte-style page
%
% A narrow text column with a wide note margin on the right, a full cover
% page, and blocks that can span both. Fonts, colours, tables, units and the
% question/answer boxes are the same as phelanlab.cls (phelanstyle.sty).
% Compile with LuaLaTeX:  latexmk -lualatex report.tex
%
% Page (letter, one-sided):
%   5/8 in | text 4.75 in | 1/4 in | margin 2.25 in | 5/8 in
%   Full width (text + gap + margin) is 7.25 in: \fulltextwidth.
%
% Usage:
%   \documentclass{phelanbook}
%   \title{RC Transient Response}
%   \author{Leonard H Phelan IV}
%   \date{2026-10-18}
%   \labnumber{06}
%   \course{ELT-1031}
%   \instructor{prof. Ashworth}
%   \footertext{Phelan · ELT-1031 · Lab 06}    % optional, bottom left
%   \coverart{<tikzpicture or \includegraphics>} % optional, 7.25 x 4.6 in
%   \begin{document}\maketitle ...
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
% Notes can't go inside boxes (tables, question/answer, figures): LaTeX
% only places margin notes from running text.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{phelanbook}[2026/10/18 v0.1 Phelan house style, Tufte-style layout]

% ---------- Options ----------
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[11pt,letterpaper]{article}

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

% ---------- Shared house style ----------
\RequirePackage{phelanstyle}
% Cover and chart ink: the house data blue.
\definecolor{labInk}{HTML}{1C5CAB}
\definecolor{labMuted}{HTML}{52514E}

% Body: 11 pt on a 15 pt line. Smaller than phelanlab's 12 pt to suit the
% 4.75 in column (about 70 characters a line).
\renewcommand\normalsize{%
  \@setfontsize\normalsize{11}{15}%
  \abovedisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \abovedisplayshortskip 3\p@ \@plus3\p@
  \belowdisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
  \let\@listi\@listI}
\normalsize

% ---------- Paragraphs ----------
% Left-aligned, no indent, 6 pt between paragraphs, no hyphenation.
\RequirePackage[skip=6pt plus 2pt]{parskip}
\RequirePackage[document]{ragged2e}
\hyphenpenalty=10000
\exhyphenpenalty=10000

% ---------- Headings ----------
% Myriad Pro Bold. Sections are unnumbered on the page; subsections show
% "1.1" in grey.
\RequirePackage{titlesec}
\RequirePackage{needspace}
\titleformat{\section}{\sffamily\bfseries\labfontsize{15}\RaggedRight}{}{0pt}{}
\titleformat{\subsection}{\sffamily\bfseries\labfontsize{12}\RaggedRight}
  {\textcolor{labEqNumber}{\thesubsection}}{0.4em}{}
\titleformat{\subsubsection}{\sffamily\bfseries\labfontsize{11}\RaggedRight}
  {\textcolor{labEqNumber}{\thesubsubsection}}{0.4em}{}
\titlespacing*{\section}{0pt}{20pt plus 4pt minus 2pt}{6pt}
\titlespacing*{\subsection}{0pt}{14pt plus 3pt minus 2pt}{4pt}
\titlespacing*{\subsubsection}{0pt}{10pt plus 2pt minus 2pt}{3pt}
\AddToHook{cmd/section/before}{\par\Needspace{\sectionneedspace}}

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
% Captions: Minion italic 8.5 pt, left-aligned. Text-column captions sit in
% the margin; margin and full-width captions sit below their content.
\RequirePackage{float}
\floatplacement{figure}{H}
\floatplacement{table}{H}
\setlength{\intextsep}{10pt plus 2pt minus 2pt}
\RequirePackage{caption}
\DeclareCaptionFont{labcaption}{\fontsize{8.5}{11}\selectfont}
\captionsetup{
  font = {labcaption, it},
  labelfont = {labcaption, it},
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
% margintable. 8 pt; header row Myriad bold on the grey band; grey rules top
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
    % Author, then the title
    \node[anchor=base west, inner sep=0pt, text=labMuted] at (0.625, 0.95)
      {\itshape\fontsize{22}{26}\selectfont\@author};
    \node[anchor=north west, inner sep=0pt, text width=6.5in, align=left]
      at (0.625, 1.3)
      {\sffamily\bfseries\fontsize{46}{50}\selectfont\RaggedRight\@title\par
       \ifx\@subtitle\@empty\else
         \vspace{10pt}{\rmfamily\mdseries\itshape\fontsize{17}{21}\selectfont
         \color{labMuted}\@subtitle\par}\fi};
    % Cover art, or the lab number in the house grey band colour
    \ifx\@coverart\@empty
      \node[anchor=south east, inner sep=0pt, text=labBand] at (7.875, 9.3)
        {\sffamily\bfseries\fontsize{300}{300}\selectfont\@labnumber};
    \else
      \node[anchor=south west, inner sep=0pt] at (0.625, 9.3)
        {\usebox\@coverbox};
    \fi
    % Footer: rule, then one line across the full width
    %   ELT-1031 · Lab 06 · prof. Ashworth                  2026-10-18
    \draw[labRule, line width=0.6pt] (0.625, 9.6) -- (7.875, 9.6);
    \begin{scope}[every node/.style={inner sep=0pt,
        font=\fontsize{11}{13}\selectfont}]
      \node[anchor=base west] at (0.625, 9.85)
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
% Parts of the footer are separated by a centred dot: \@footsep.
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

% ---------- Links ----------
\RequirePackage[hidelinks]{hyperref}

\endinput
