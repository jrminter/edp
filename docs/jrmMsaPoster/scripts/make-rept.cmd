cd ../Sweave/
R CMD Sweave  jrmMsaPoster
# R CMD Stangle jrmMsaPoster
pdflatex jrmMsaPoster
# bibtex jrmMsaPoster
# pdflatex jrmMsaPoster
pdflatex jrmMsaPoster
del *.aux
del *.dvi
del *.log
del *.tex
del *.toc
del *.blg
del *.bbl
del *.brf
del *.lo*
del jrmMsaPoster-*.*
del Rplots.pdf
del .Rhistory
# move /Y jrmMsaPoster.R ../R/

move  jrmMsaPoster.pdf jrmMsaPoster-uncomp.pdf
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=jrmMsaPoster.pdf jrmMsaPoster-uncomp.pdf
del *.out
del *.snm
del *.nav
del *-uncomp.pdf
 
pause

