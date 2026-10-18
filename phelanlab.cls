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
% What it provides (see README.md for examples; most of it comes from
% phelanstyle.sty, shared with phelanbook.cls):
%   \newquantity{\Vth}{V}{TH}   V_TH: upright with a real subscript in text,
%                               italic V in math
%   \fig{width}{file}{caption}{label}   centred figure, caption below
%   labtable environment         the "Lab Table" look (tabularray)
%   \pending                     amber "not yet measured" table cell
%   question / answer envs       Q-band and indented answer
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{phelanlab}[2026/10/18 v0.3 Phelan lab report house style]

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

% ---------- Shared house style ----------
% Fonts, colours, units, quantities, equation numbers, tables and the
% question/answer boxes live in phelanstyle.sty, shared with phelanbook.cls.
\RequirePackage{phelanstyle}

% Body: 12 pt on a 16.7 pt line (Word's 1.16 line spacing for Minion).
\renewcommand\normalsize{%
  \@setfontsize\normalsize{12}{16.7}%
  \abovedisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \abovedisplayshortskip 3\p@ \@plus3\p@
  \belowdisplayskip 6\p@ \@plus3\p@ \@minus3\p@
  \belowdisplayshortskip 6\p@ \@plus3\p@ \@minus3\p@
  \let\@listi\@listI}
\normalsize

% ---------- Paragraphs ----------
% Left-aligned, no indent, 8 pt between paragraphs, no hyphenation (as Word).
\RequirePackage[skip=8pt plus 2pt]{parskip}
\RequirePackage[document]{ragged2e}
\hyphenpenalty=10000
\exhyphenpenalty=10000

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

% ---------- Links ----------
\RequirePackage[hidelinks]{hyperref}

\endinput
