#! /bin/bash
cd $GIT_HOME
cd ./edp/R
R CMD build Peaks
R CMD check Peaks
R CMD INSTALL P*.tar.gz
rm -rf Peaks/src/*.so
rm -rf Peaks/src/*.o
rm -rf Peaks/src/*.rds
rm -rf Peaks.Rcheck
rm -rf *.tar.gz



