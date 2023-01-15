%
% mlemanual.cls for Sphinx (http://sphinx-doc.org/)
%

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{mymanual}[2023/01/13 v1.0.0 MY Document class (Sphinx manual)]

% fix according https://github.com/sphinx-doc/sphinx/issues/11128#issuecomment-1382950715
\def\sphinxdocclass{report}

\LoadClassWithOptions{sphinxmanual}

\renewcommand{\sphinxtableofcontents}{%
    \pagenumbering{roman}%
    \begingroup
        \parskip \z@skip
        \sphinxtableofcontentshook
        \tableofcontents
        \listoffigures
        \listoftables
    \endgroup
    % before resetting page counter, let's do the right thing.
    \if@openright\cleardoublepage\else\clearpage\fi
    \pagenumbering{arabic}%
}
