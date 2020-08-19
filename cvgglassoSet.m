classdef cvgglassoSet
    %SGLSet Option container for gglasso
    
    properties
        loss = 'ls'
        pred_loss = 'L2'
        nfolds = 5
        nlambda = 100
        lambda_factor = 0.001
        intercept = true
        standardize = true
    end
end

