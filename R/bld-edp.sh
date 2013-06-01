#! /bin/bash
cd $GIT_HOME
cd ./edp/R
R CMD build edp
R CMD check edp
R CMD INSTALL edp_*tar.gz
rm -rf edp.Rcheck
rm -rf *.tar.gz

