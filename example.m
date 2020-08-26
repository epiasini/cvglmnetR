%% Example/testing script

%% Summary
% This is an example script showing how to fit simple GLMs using the R
% implementation of glmnet from matlab.

%% Setup
% Here we define the parameters of the simple synthetic problem.

% number of data points
n = 1000;

% number of predictors
p = 30;

% noise strength (for linear model)
eta = 5;

%% Generate synthetic data

% generate predictors
x = randn(n, p);

% define true value of coefficients
intercept = randn;
beta = randn(p,1);

% generate y values under linear model
y_linear = intercept + x * beta + eta * randn(n,1);

% generate y values under logistic model
y_logistic = rand(n,1) <= 1./(1+exp(-(intercept + x * beta)));

%% Fit linear model
opts = glmnetSet;

fit_linear = cvglmnetR(...
    x,...
    y_linear,...
    'gaussian',...
    opts);

fit_logistic = cvglmnetR(...
    x,...
    y_logistic,...
    'binomial',...
    opts);

fits = [fit_linear, fit_logistic];
fit_names = ["Linear", "Logistic"];

for fit_id = 1:2
    fit = fits(fit_id);

    %% Plot fit
    % Note that the |fit| object returned by cvglmnetR is compatible with the
    % "glmnet in matlab" package. So, if this is available, we can make use of
    % it to visualize the fit. (note that this can also be easily replicated by
    % hand if "glmnet in matlab" is not available)
    cvglmnetPlot(fit)
    h = get(gcf, 'Children');
    
    % create new figure and copy over the output of glmnetPlot in a subplot
    % - this is a workaround for the fact that glmnetPlot always wants to
    % plot in a new/clean figure, in figure 1.
    figure(fit_id+1);clf;set(gcf, 'Name', fit_names(fit_id)+" regression");
    ax = subplot(2,1,1);
    newh = copyobj(h, fit_id+1);
    posnewh = get(newh(1), 'Position');
    possub = get(ax, 'Position');
    set(newh(1), 'Position', [posnewh(1) possub(2) posnewh(3) possub(4)]);
    close 1;
    
    coefs = cvglmnetCoef(fit, 'lambda_1se');
    subplot(2,2,3)
    scatter(coefs, [intercept; beta]);
    xlabel("Fitted beta")
    ylabel("True beta")
    
    %% Plot linear model predictions
    % In the same way, we can use the function provided by "glmnet in matlab"
    % for computing predictions (and as above, this can also be done by hand if
    % needed).
    yhat = cvglmnetPredict(fit, x, 'lambda_1se', 'link');
    if fit_id==1
        y = y_linear;
    else
        y = y_logistic;
    end
    subplot(2,2,4);
    scatter(yhat, y);
    if fit_id==1
        xlabel("Predicted Y (in-sample)")
        ylabel("Observed Y")
    else
        xlabel("Predicted logit (in-sample)")
        ylabel("Observed Y")
        xrange = linspace(min(yhat)*0.8, max(yhat)*0.8, 1000);
        hold on
        plot(xrange, 1./(1+exp(-xrange)))
    end

end