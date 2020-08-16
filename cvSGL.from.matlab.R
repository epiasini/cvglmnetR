library(R.matlab)
library(SGL)

# get name of file containing data and options for the fit and load it
args <- commandArgs(trailingOnly = TRUE)
temp.name <- args[[1]]
input.filename <- paste(temp.name, ".in.mat", sep="")
output.filename <- paste(temp.name, ".out.mat", sep="")

input <- readMat(input.filename)

# prepare data and options for use with SGL. Remove parameters that
# should be set to default values, and make sure each variable is an
# object of the appropriate class.
input <- input[lapply(input, length) > 0]
if (input$type == "logit") {
    input$y <- as.factor(input$y)
}

# make sure scalar parameters are actually scalars and not 1x1 matrices
input[lapply(input, length) == 1] <- lapply(input[lapply(input, length) == 1], `[[`, 1)

# make sure parameters that are expected to be vectors are not 1xn or nx1 matrices instead
vector.parameter.names <- c("index", "foldid")
input[vector.parameter.names] <- lapply(input[vector.parameter.names], as.vector)

# make sure logical parameters are actually logical and not 1/0
logical.parameter.names <- c("standardize", "verbose")
input[logical.parameter.names] <- lapply(input[logical.parameter.names], as.logical)

# assemble data argument from input. Make sure x and y are converted
# to (dense) matrix format if they are not (they could be sparse for
# instance)
input$data <- list(x=as.matrix(input$x), y=as.vector(input$y))

# each element of "input" should now correspond (name and class) to
# one argument to cvSGL, axcept "x" and "y"
cvSGL.args <- input[(names(input)!="x") & (names(input)!="y")]

fit <- do.call(cvSGL, cvSGL.args)

# save the results of the fit in a file that can be read back into
# matlab. Note that we have to get rid of all dots inside variable
# names, and that we avoid saving nested structures.
writeMat(output.filename, lldiff=fit$lldiff, llSD=fit$llSD,
         lambdas=fit$lambdas, type=fit$type, foldid=fit$foldid,
         prevals=fit$prevals, fbeta=fit$fit$beta, flambdas=fit$fit$lambdas, ftype=fit$fit$type,
         fintercept=fit$fit$intercept, fXtransform=fit$fit$X.transform)

## Local Variables:
## mode: R
## coding: utf-8-unix
## End:
