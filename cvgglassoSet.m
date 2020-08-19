classdef gglassoSet
    %SGLSet Option container for gglasso
    
    properties
        loss = 'ls'
        pred_loss = 'L2'
        nfolds = 5
        nlambda = 30 % TODO:potentially raise to 100
        lambda_factor = 0.001
        intercept = true
        standardize = true
    end
end

