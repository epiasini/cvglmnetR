cvglmnetR.m
===========

Simple replacement for the 'cvglmnet' function from the
"[glmnet in MATLAB](http://web.stanford.edu/~hastie/glmnet_matlab/index.html)"
package that uses the R implementation of glmnet. Under the hood, a
new R process is run each time a fit is performed. This is meant as a
workaround for some bugs specific to the MATLAB version of the
package.

Although some effort has been made to make this into something fairly
generic, cvglmnetR has been only tested with the 'binomial' family of
models, under Linux and Mac OSX.

This is nothing more than a quick hack; use at your own risk. Bug
reports and pull requests are welcome, but please consider if you
shouldn't be helping out with
[the original MATLAB version of glmnet](http://web.stanford.edu/~hastie/glmnet_matlab/index.html)
instead.

Requirements
------------

Besides MATLAB with "glmnet in MATLAB", you will need a recent R
distribution with `glmnet` and `R.matlab` installed.

Usage
-----

The `cvglmnetR` function accepts the same arguments as `cvglmnet` from
"glmnet in MATLAB" except `keep` and `grouped`, and returns a
structure with the same fields as that returned by
`cvglmnet`. Functions such as `cvglmnetPredict` and `cvglmnetPlot`
should work when given this structure as the `cvfit` argument.

For further details, see the documentation for `cvglmnet`.

Licensing
---------

This program is licensed under version 3 of the GPL or any later
version. See COPYING for details.

