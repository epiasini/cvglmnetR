classdef SGLSet
    %SGLSet Option container for SGL
    %   Note that the defaults in SGL are different from those in glmnet.
    %   Here we set them to be similar to the numbers used in glmnet.
    
    properties
        type = 'linear'
        maxit = 1e5
        thresh = 1e-7
        min_frac = 1e-4
        nlam = 100
        gamma = 0.8
        nfold = 10
        standardize = true
        verbose = false
        step = 1
        reset = 10
        alpha = 0.95
        lambdas = []
    end
end

