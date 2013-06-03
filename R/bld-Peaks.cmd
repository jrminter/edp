R CMD build Peaks
R CMD check Peaks
pause
R CMD INSTALL "./Peaks_*tar.gz"
pause
DEL /Q *.gz
DEL /Q Peaks\src\Peaks.dll
DEL /Q Peaks\src\Peaks.o
DEL /Q Peaks\src\.rds
DEL /S /Q /F Peaks.Rcheck
pause
