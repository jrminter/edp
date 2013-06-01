#!/bin/bash
cd ~/work/proj/jrmMsaPoster/scripts
cd ../Sweave/
R CMD Sweave  jrmMsaPoster
# R CMD Stangle jrmMsaPoster
pdflatex jrmMsaPoster
# bibtex jrmMsaPoster
# pdflatex jrmMsaPoster
pdflatex jrmMsaPoster
rm -rf *.aux
rm -rf *.dvi
rm -rf *.log
rm -rf *.tex
rm -rf *.toc
rm -rf *.blg
rm -rf *.bbl
rm -rf *.brf
rm -rf *.lo*
rm -rf jrmMsaPoster-*.*
rm -rf Rplots.pdf
rm -rf .Rhistory
# move /Y jrmMsaPoster.R ../R/

mv  jrmMsaPoster.pdf jrmMsaPoster-uncomp.pdf
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=jrmMsaPoster.pdf jrmMsaPoster-uncomp.pdf
rm -rf *.out
rm -rf *.snm
rm -rf *.nav
rm -rf *-uncomp.pdf
 
pause

