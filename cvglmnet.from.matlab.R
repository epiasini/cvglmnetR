library(R.matlab)
library(glmnet)

# get name of file containing data and options for the fit and load it
args <- commandArgs(trailingOnly = TRUE)
temp.name <- paste(args, collapse=' ') # this is a workaround to deal with paths with whitespace in them
input.filename <- paste(temp.name, ".in.mat", sep="")
output.filename <- paste(temp.name, ".out.mat", sep="")

input <- readMat(input.filename)

# prepare data and options for use with glmnet. Remove parameters that
# should be set to default values, and make sure each variable is an
# object of the appropriate class.
input <- input[lapply(input, length) > 0]
if (input$family == "binomial" || input$family == "multinomial") {
    input$y <- as.factor(input$y)
}
input$lower.limits <- input$cl[1,]
input$upper.limits <- input$cl[2,]

# convert name of parameter from matlab to R version
if (exists("lambda.min", where=input)) {
    input$lambda.min.ratio <- input$lambda.min
}

# make sure scalar parameters are actually scalars and not 1x1 matrices
input[lapply(input, length) == 1] <- lapply(input[lapply(input, length) == 1], `[[`, 1)

# make sure foldid is a vector and not an nx1 or 1xn matrix
input$foldid <- as.vector(input$foldid)

# make sure logical parameters are actually logical and not 1/0
logical.parameter.names <- c("standardize", "intercept", "standardize.resp", "parallel")
input[logical.parameter.names] <- lapply(input[logical.parameter.names], as.logical)

# if necessary, register a parallel environment
if (input$parallel) {
    library(doParallel)
    registerDoParallel()
}

# each element of "input" should now correspond (name and class) to
# one argument to cv.glmnet, with the exception of "cl" and "lambda.min"
glmnet.args <- input[(names(input)!="cl") & (names(input)!="lambda.min")]

max.n.attempts <- 10
attempt <- 1

while (attempt <= max.n.attempts) {
    fit <- tryCatch({
        do.call(cv.glmnet, glmnet.args)
    }, error = function(err) {
        # Sometimes the lambda values are such that the fit will not
        # converge for any lambda except the one that corresponds to
        # the intercept model. In these cases, instead than just
        # issuing a "fit not converged" warning, it seems that glmnet
        # is crashing with a "Error in predmat[which, seq(nlami)] =
        # preds : replacement has length zero" error.
        if (exists("lambda", where=glmnet.args)) {
            # if the user provided an explicit lambda sequence, we
            # leave it up to them to figure out that they have to
            # select another sequence.
            stop(err)
        } else {
            # If the lambda sequence was left for glmnet to compute,
            # we iteratively modify lambda.min.ratio until we find one
            # setting for which this issue doesn't occur (i.e. the
            # second largest value of lambda is close enough to the
            # largest that the fit converges).
            if (!exists("lambda.min.ratio", where=input)) {
                # if lambda.min.ratio was not specified by the user,
                # the default value used by glmnet in the run that
                # threw the error depends on whether nobs<ndims
                input$lambda.min.ratio <- ifelse(dim(input$x)[[1]]<dim(input$x)[[2]],0.01,0.0001)
            }
            # every time we re-try this, we increase lambda.min.ratio
            # exponentially towards 1 in such a way that when
            # attempt==max.n.attempts the distance between 1 and
            # lambda.min.ratio will have shrunk down to a factor of
            # (1-exp(-1))~60%
            new.lambda.min.ratio <- 1 - (1 - input$lambda.min.ratio) * (1 - exp(-max.n.attempts/(attempt)))
            warning(paste("glmnet errored with the following message:\n", err, "going to attempt with a sequence of larger lambda values. Attempt number", attempt, "; new lambda.min.ratio value", new.lambda.min.ratio))
            return(new.lambda.min.ratio)
        }
    })
    if (class(fit)=="numeric"){
        # something went wrong: "fit" is not an output from a glmnet
        # fit but it's instead the new value to be used for
        # lambda.min.ratio
        glmnet.args$lambda.min.ratio <- fit
        attempt <- attempt+1
    } else break
}
# the "call" variable doesn't appear to be used in matlab, but it's
# just set like this
dummy.call <- t(c("x", "y", "family", "options"))

# save the results of the fit in a file that can be read back into
# matlab. Note that we have to get rid of all dots inside variable
# names, and that we avoid saving nested structures. Note also that
# some variables need to be transposed as in MATLAB they're supposed
# to be row rather than column arrays. Finally, we convert 'offset'
# from logical to numeric to work around an issue in writeMat.
writeMat(output.filename, lambda=fit$lambda, cvm=fit$cvm,
         cvsd=fit$cvsd, cvup=fit$cvup, cvlo=fit$cvlo, nzero=fit$nzero,
         name=fit$name, lambdamin=fit$lambda.min, lambda1se=fit$lambda.1se,
         fa0=t(fit$glmnet.fit$a0), fbeta=fit$glmnet.fit$beta,
         fdf=fit$glmnet.fit$df, fdim=t(fit$glmnet.fit$dim),
         flambda=fit$glmnet.fit$lambda, fdevratio=fit$glmnet.fit$dev.ratio,
         fnulldev=fit$glmnet.fit$nulldev, fnpasses=fit$glmnet.fit$npasses,
         fjerr=fit$glmnet.fit$jerr, foffset=as.numeric(fit$glmnet.fit$offset),
         fclassnames=as.numeric(fit$glmnet.fit$classnames), fcall=dummy.call,
         fnobs=fit$glmnet.fit$nobs)


## Local Variables:
## mode: R
## coding: utf-8-unix
## End:
