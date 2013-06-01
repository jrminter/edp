cd %GIT_HOME%
cd "./edp/R"
R CMD build Peaks
R CMD check Peaks
pause
R CMD INSTALL "./Peaks_*tar.gz"
pause
DEL /Q *.gz
DEL /Q Peaks/src/*.so
DEL /Q Peaks/src/*.o
DEL /Q Peaks/src/*.rds
DEL /S /Q /F Peaks.Rcheck
pause
