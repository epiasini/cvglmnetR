function fit = cvgglasso(x, y, group, options, foldid)
    %CVGGLASSO simple matlab-to-R wrapper for (a subset of)
    %gglasso.
    %
    %   Note that if options.standardize=true, the predictors will
    %   be standardized (and their center and scale returned as
    %   scaling_center and scaling_scale). It is up to the user to
    %   keep this in mind when interpreting the fitted coefficients
    %   and making predictions.
    
    % debug switch. Set this to 'true' to enable logging from glmnet. This
    % will create one '.log' file in the system's temporary folder each
    % time this function is called. Note that these files are purposely
    % *not* removed at the end of the function! Use with caution.
    debug = false;
    
    % generate a random name for the temporary files that will be used to
    % exchange data between MATLAB and R.
    temp_filename = tempname;
    data_filename_input = [temp_filename, '.in.mat'];
    data_filename_output = [temp_filename, '.out.mat'];
    
    % rename some options that have a different name in the original
    % implementation.

    
    % prepare R options depending on the debug flag
    if debug
        r_opts = '--no-save --no-restore ';
        r_out_file = [temp_filename, '.log'];
    else
        r_opts = '--no-save --no-restore --no-timing --slave ';
        r_out_file = '/dev/null';
    end
    
    % convert options from SGLSet object to simple struct. This is
    % needed for the save -struct command below
    options = struct(options);
    
    % save data and parameters for fit to temporary file and call R
    r_script = fullfile(fileparts(which('cvSGL')), 'cvgglasso.from.matlab.R');
    save(data_filename_input, '-struct', 'options');
    save(data_filename_input, 'x', 'y', 'group', 'foldid', '-append');
    command = sprintf('R CMD BATCH %s''--args %s'' %s %s',...
        r_opts, temp_filename, r_script, r_out_file);
    system(command);
    
    % rename results fields and package the SGL fit object into a nested
    % structure
    fit = load(data_filename_output);
    fit.scaling_center = fit.scalingcenter;
    fit.scaling_scale = fit.scalingscale;
    fit.lambda_min = fit.lambdamin;
    fit.lambda_1se = fit.lambda1se;
    
    fit.fit = struct();
    fit.fit.call = fit.fcall;
    fit.fit.b0 = fit.fb0;
    fit.fit.beta = fit.fbeta;
    fit.fit.df = fit.fdf;
    fit.fit.dim = fit.fdim;
    fit.fit.lambda = fit.flambda;
    fit.fit.npasses = fit.fnpasses;
    fit.fit.jerr = fit.fjerr;
    fit.fit.group = fit.fgroup;
    
    fit = rmfield(fit, {'scalingcenter', 'scalingscale', 'lambdamin', ...
                        'lambda1se', 'fcall', 'fb0', 'fbeta', 'fdf', ...
                        'fdim', 'flambda', 'fnpasses', 'fjerr', 'fgroup'});
                        
    % clean up temporary files
    %    delete(data_filename_input);
    delete(data_filename_output);
        
end
