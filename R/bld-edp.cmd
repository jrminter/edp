cd %GIT_HOME%
cd "./edp/R"
R CMD build edp
R CMD check edp
pause
R CMD INSTALL "./edp_*.tar.gz"
pause
DEL /Q *.gz
DEL /S /Q /F edp.Rcheck
pause
