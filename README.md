cvglmnetR.m
===========

[![DOI:10.5281/zenodo.3568315](https://zenodo.org/badge/DOI/10.5281/zenodo.3568315.svg)](https://doi.org/10.5281/zenodo.3568315)

Simple replacement for the 'cvglmnet' function from the
"[glmnet in MATLAB](http://web.stanford.edu/~hastie/glmnet_matlab/index.html)"
package that uses the R implementation of glmnet. Under the hood, a
new R process is run each time a fit is performed. This is meant as a
workaround for some bugs specific to the MATLAB version of the
package. It can also be used to access newer features that have only
been implemented for the R version of the package.

Although some effort has been made to make this into something fairly
generic, cvglmnetR has been only tested with the 'binomial' and
'gaussian' family of models, under Linux and Mac OSX.

This is nothing more than a quick hack; use at your own risk. Bug
reports and pull requests are welcome.

Requirements
------------

Besides MATLAB with "glmnet in MATLAB", you will need a recent R
distribution with `glmnet` and `R.matlab` installed. `doParallel` is
optional, and only necessary to make use of the parallel features of
glmnet. These packages can be installed by the following command at
the R prompt:
```R
install.packages(c('glmnet', 'R.matlab', 'doParallel'))
```

Also, make sure that R is on your PATH. On linux (possibly Mac OS and
Windows too, this hasn't been tested), sometimes this can cause
problems if you usually rely on adding custom folders to your PATH
using `.profile` and similar. In that case you can use the following
command from the matlab prompt:
```matlab
setenv('PATH', ['/path/to/R/bin:', getenv('PATH')]);
```

Usage
-----

The `cvglmnetR` function accepts the same arguments as `cvglmnet` from
"glmnet in MATLAB" except `keep` and `grouped`, and returns a
structure with the same fields as that returned by
`cvglmnet`. Functions such as `cvglmnetPredict` and `cvglmnetPlot`
should work when given this structure as the `cvfit` argument.

Note that if the `parallel` option is true, a parallel backend is
automatically registered by calling `registerDoParallel()`.

For further details, see the documentation for `cvglmnet`.

Other functionality
-------------------

Partial, experimental support is also present for the following other
packages:
 - `gglasso`
 - `SGL`

The interface for these packages is meant to be analogous to that for
`glmnet`. This hasn't been sufficiently tested though, and is not
described more in detail on purpose, to discourage careless use.

Licensing
---------

This program is licensed under version 3 of the GPL or any later
version. See COPYING for details.

