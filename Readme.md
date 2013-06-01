edp - Softare to analyze polycrystalline electron diffraction patterns.
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
written in the DigitalMicrograph scripting language. Currently,
the **edp** subfolder contains an updated version of the
*Diffraction Distortion* plugin originally developed by
Hou and Li. This has been updated to work with GMS 1.8 and
GMS 2.1. It has been extended to correct the distortion,
perform the radial average, and output a profile for subsequent
analysis.

2. The **R** folder contains packages that encapuslate key
functions. The **edp** folder contains the main package for
analysis. The **Peaks** folder contains a patched version of
the Peaks package that works with R-3.0.0 and greater. This
will be removed when the maintainer incorparates these into
the version on CRAN. The **scripts** subfolder contains cmd
files (windows) and shell scripts (Linux/Mac) that automate
building and installing these packages.

3. The **docs** folder that contains documentation. The
**jrmMsaPoster** subfolder the has the the code to reproduce
the poster presented by J. Minter at the Aug 2013 Microscopy and
Microanalysis meeting.

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


