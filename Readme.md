edp - Software to analyze polycrystalline electron diffraction patterns.
=======================================================================

# Overview

Microscopists record electron diffraction patterns (``edp``) from
polycrystalline thin films and analyze them to elucidate the
crystal structure of these materials. Spherical aberration in the
microscope's diffraction lens introduces a
[distortion](http://www.fos.su.se/~svenh/TEM-distortions.pdf)
of the pattern, transforming the circular rings into what may
be modeled as an ellipse. Correcting this distortion improves the
ability to radially average and analyse the patterns. This
repository contains
software that assists the microsopist in developing a reproducible
workflow for the analysis of these patterns. Here we assume that
the patterns are originally recorded under the control of the
Gatan
[DigitalMicrograph](http://www.gatan.com/resources/scripting/demo/)
software.

# Prerequisites

You need the following to make full use of the software in this repository:

1. __DigitalMicrograph__ (GMS) from Gatan. This works with the demo version available [here](http://www.gatan.com/resources/scripting/demo/).
2. The __R-software__ for backend processing, available on [CRAN](http://cran.us.r-project.org/) where you can download binaries. You will really want to make sure the R executable is in your command path. I ___highly recommend___ the [R-Studio desktop](http://www.rstudio.com/ide/download/desktop) integrated development environment. It will make life much easier. All of these are free and Open Source.
3. The __git__ version control software. You can get away without it, but it will make your life a lot easier. You can just download a zip archive from the ``Download Zip`` button on the right, but it makes it harder to keep the software updated.
4. If you want to build the R packages from source, you need a LaTeX distribution. R Packages won't install without documentation, and currently that requires LaTeX. I think MikTex will work. I know TeXlive 2013 works. This is free and available [here](http://www.tug.org/texlive/). I know this is a pain. I hope to have binaries available for Win32 and Win64 shortly so you can just try it. 

# Design Goals

1. Script as much of the analysis as possible. Minimize mouse
clicks.
2. Assemble software in plug-ins and packages to avoid repetition.
[**DRY**](http://en.wikipedia.org/wiki/Don't_repeat_yourself)
3. Use version control.
4. Use [**literate programming**](http://en.wikipedia.org/wiki/Literate_programming)
where code chunks are embedded
in the documentation. The Open Source
[R](http://www.r-project.org/) statistical processing
language for the back end processing is the first step. This
permits the use of $\LaTeX$ (I use [TeXlive](http://www.tug.org/texlive/))
or R-markdown. Both approaches use plain text files and work
well with version control. [RStudio](http://www.rstudio.com/) is
a popular integrated development that I find useful.

# What's here?

1. The **dm** folder contains the source code for plug-ins
written in the Crystallographic scripting language. Currently,
the **edp** sub folder contains an updated version of the
*Diffraction Distortion* plugin originally developed by
Hou and Li. This has been updated to work with GMS 1.8 and
GMS 2.1. It has been extended to correct the distortion,
perform the radial average, and output a profile for subsequent
analysis.

2. The **R** folder contains packages that encapsulate key
functions. The **edp** folder contains the main package for
analysis. The **Peaks** folder contains a patched version of
the Peaks package that works with R-3.0.0 and greater. This
will be removed when the maintainer incorporates these into
the version on CRAN. The **scripts** sub folder contains cm
files (windows) and shell scripts (Linux/Mac) that automate
building and installing these packages.

3. The **docs** folder that contains documentation. The
**jrmMsaPoster** sub folder the has the the code to reproduce
the poster presented by J. Minter at the Aug 2013 Microscopy and
Microanalysis meeting. Note that executing the command

```
R CMD Stangle jrmMsaPoster.Rnw
```
in the ``docs/jrmMsaPoster/Sweave`` folder extracts all the
R code from the Sweave poster file so you can examine it

# Some hints

## Environment variables

I use multiple computers, including Win-XP, Win-7, Linux (Ubuntu),
and MacOSX (Mountain Lion). I set some environment variables on
each system that help me cope with different paths on different
systems. You will see these at various points in the code.
**None** of these variables terminate with a `/`.

* ``GIT_HOME`` This is my root directory for git repositories.
It makes relative paths more bulletproof.
* ``IMG_ROOT`` Images are large, and I don't typically keep them
in the git tree. I typically zip these into a separate compendium
to store alongside the compendium containing the code and report.
* ``HOME`` This typically exists on Mac or Linux. I set this
as a user environment variable on windows, in case a project
doesn't live relative to ``GIT_HOME``.

This works for me. You are welcome to change the paths in your
local copy...

## Basic installation instructions

### Preparation
1. __Install the prerequisite software___ (GMS, R, and git) Install LaTeX if you want to build the R packages from source.
2. __Set your user environment variables__ as described above. 
3. __Set your command path:__ Make sure the R executable and your LaTeX binaries are in your command path.

### Clone the repository

1. Open the ___Git bash shell__ and change to your ``GIT_HOME`` directory. 

2. Clone the repository

```
cd $GIT_HOME
git clone https://github.com/jrminter/edp.git
```

Now you have your own copy of this repository.

### Install the GMS/DM EDP package

1. Open GMS/DigitalMicrograph

2. Open the ``build EDP-Distortion-plugin.s`` script from the ``dm/EDP-distortion-plugin`` folder in GMS/DigitalMicrograph. This will install the script into the ``edp`` menu of GMS.

### Installing the R packages for back-end processing

If you have your environment variables set properly and have R and a LaTeX distribution installed, you can

1. Execute the ``bld-Peaks.cmd`` script in the ``R`` subfolder to build the required ``Peaks`` R-package (I had to patch it to work with the current version of R)
2. Execute the ``bld-edp.cmd`` script in the ``R`` subfolder to build the edp package.

Note that if you use RStudio, you can go to the ``Packages`` tab and click on the ``edp`` tab and that will show you the documentation for the package.

# The fine print
## License
All the software here is licensed under the
[GPL-2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html) The 
documentation is licensed under the 
[CC BY-NC-SA 3.0](http://creativecommons.org/licenses/by-nc-sa/3.0/).

You are always welcome to participate by
[forking](https://github.com/jrminter/edp/fork_select) this repository.

## Warranty

There is none. Use this at your own risk. I have done my best
to make this robust but know all too well that *to err is human.*
I will do my best to address concerns and incorporate improvements.
I do have a busy life and cannot guarantee *when* I will get to your
suggestion.

## Contact

``jrminter AT gmail.com``


