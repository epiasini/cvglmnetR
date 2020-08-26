library(R.matlab)
library(gglasso)

# get name of file containing data and options for the fit and load it
args <- commandArgs(trailingOnly = TRUE)
temp.name <- paste(args, collapse=' ') # this is a workaround to deal with paths with whitespace in them
input.filename <- paste(temp.name, ".in.mat", sep="")
output.filename <- paste(temp.name, ".out.mat", sep="")

input <- readMat(input.filename)

# prepare data and options for use with SGL. Remove parameters that
# should be set to default values, and make sure each variable is an
# object of the appropriate class.
input <- input[lapply(input, length) > 0]
if (input$pred.loss == "logit") {
    input$y <- as.factor(input$y)
}

# make sure scalar parameters are actually scalars and not 1x1 matrices
input[lapply(input, length) == 1] <- lapply(input[lapply(input, length) == 1], `[[`, 1)

# make sure parameters that are expected to be vectors are not 1xn or nx1 matrices instead
vector.parameter.names <- c("group", "foldid")
input[vector.parameter.names] <- lapply(input[vector.parameter.names], as.vector)

# make sure logical parameters are actually logical and not 1/0
logical.parameter.names <- c("standardize", "intercept")
input[logical.parameter.names] <- lapply(input[logical.parameter.names], as.logical)

# assemble data argument from input. Make sure x and y are converted
# to (dense) matrix format if they are not (they could be sparse for
# instance)
input$x <- as.matrix(input$x)
input$y <- as.vector(input$y)

# if standardization is requested, store scaling constants and
# standardize predictors
if (input$standardize) {
    scaling.center <- apply(input$x, 2, mean)
    scaling.scale <- apply(input$x, 2, sd)
    input$x <- scale(input$x)
} else {
    scaling.center <- rep(0, dim(input$x)[[2]])
    scaling.scale <- rep(1, dim(input$x)[[2]])
}

# each element of "input" should now correspond (name and class) to
# one argument to gglasso, except for "standardize"
gglasso.args <- input[(names(input)!="standardize")]

fit <- do.call(cv.gglasso, gglasso.args)

# save the results of the fit in a file that can be read back into
# matlab. Note that we have to get rid of all dots inside variable
# names, and that we avoid saving nested structures.
writeMat(output.filename, standardize=input$standardize,
         scalingcenter=scaling.center, scalingscale=scaling.scale,
         lambda=fit$lambda, cvm=fit$cvm, cvsd=fit$cvsd,
         cvupper=fit$cvupper, cvlower=fit$cvlower, name=fit$name,
         lambdamin=fit$lambda.min, lambda1se=fit$lambda.1se,
         fcall=toString(fit$gglasso.fit$call), fb0=fit$gglasso.fit$b0,
         fbeta=fit$gglasso.fit$beta, fdf=fit$gglasso.fit$df,
         fdim=fit$gglasso.fit$dim, flambda=fit$gglasso.fit$lambda,
         fnpasses=fit$gglasso.fit$npasses, fjerr=fit$gglasso.fit$jerr,
         fgroup=fit$gglasso.fit$group)

## Local Variables:
## mode: R
## coding: utf-8-unix
## End:
