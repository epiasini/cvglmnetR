function fit = cvglmnetR(x, y, family, options, type, nfolds, foldid, parallel)
    % CVGLMNETR replacement for the 'cvglmnet' function from the "glmnet
    % for MATLAB" package that uses the R implementation of glmnet instead
    % of MATLAB. Makes use of the companion script
    % "cvglmnet.from.matlab.R", that has to be in the folder where MATLAB
    % is run. Obviously needs a working distribution of R, with the
    % "glmnet" and "R.matlab" packages. Only tested with the 'binomial'
    % family of models, under Linux and Mac OSX.

    % debug switch. Set this to 'true' to enable logging from glmnet. This
    % will create one '.log' file in the system's temporary folder each
    % time this function is called. Note that these files are purposely
    % *not* removed at the end of the function! Use with caution.
    debug = false;
    
    % set the "class" internal use parameter. This is not documented and is
    % not used by the R implementation, but the matlab implementation seems
    % to set it as following.
    switch family
        case 'gaussian'
            class = 'elnet';
        case {'binomial', 'multinomial'}
            class = 'lognet';
        case 'cox'
            class = 'coxnet';
        case 'mgaussian'
            class = 'mrelnet';
        case 'poisson'
            class = 'fishnet';
    end
    
    % generate a random name for the temporary files that will be used to
    % exchange data between MATLAB and R.
    temp_filename = tempname;
    if ispc
        % if we are on Windows, sanitize the temporary file name to a
        % format that makes both matlab and R happy
        temp_filename = strrep(temp_filename, '\', '\\');
    end
    data_filename_input = [temp_filename, '.in.mat'];
    data_filename_output = [temp_filename, '.out.mat'];
    
    % rename some options that have a different name in the original
    % implementation.
    options.type_multinomial = options.mtype;
    options.type_logistic = options.ltype;
    options.intercept = options.intr;
    options = rmfield(options, {'mtype', 'ltype', 'intr'});
    
    % prepare R options depending on the debug flag
    if debug
        r_opts = '--no-save --no-restore ';
        r_out_file = [temp_filename, '.log'];
    else
        r_opts = '--no-save --no-restore --no-timing --slave ';
        if ispc
            r_out_file = 'NUL';
        else
            r_out_file = '/dev/null';
        end
    end
    
    % save data and parameters for fit to temporary file and call R
    r_script = fullfile(fileparts(which('cvglmnetR')), 'cvglmnet.from.matlab.R');
    save(data_filename_input, '-struct', 'options');
    save(data_filename_input, 'x', 'y', 'family', 'type', 'nfolds', 'foldid', 'parallel', '-append');
    command = sprintf("R CMD BATCH %s ""--args %s"" ""%s"" ""%s"" ",...
        r_opts, temp_filename, r_script, r_out_file);
    system(command);
    
    % rename results fields and package the glmnet_fit object into a nested
    % structure
    fit = load(data_filename_output);
    fit.lambda_min = fit.lambdamin;
    fit.lambda_1se = fit.lambda1se;
    fit.class = 'cv.glmnet';
    
    fit.glmnet_fit = struct();
    fit.glmnet_fit.a0 = reshape(fit.fa0, [], 1);
    fit.glmnet_fit.label = fit.fclassnames;
    fit.glmnet_fit.beta = fit.fbeta;
    fit.glmnet_fit.dev = fit.fdevratio;
    fit.glmnet_fit.nulldev = fit.fnulldev;
    fit.glmnet_fit.df = fit.fdf;
    fit.glmnet_fit.lambda = fit.flambda;
    fit.glmnet_fit.npasses = fit.fnpasses;
    fit.glmnet_fit.jerr = fit.fjerr;
    fit.glmnet_fit.dim = fit.fdim;
    fit.glmnet_fit.offset = logical(fit.foffset);
    fit.glmnet_fit.class = class;
    fit.glmnet_fit.call = fit.fcall;
    fit.glmnet_fit.nobs = fit.fnobs;
    
    fit = rmfield(fit, {'lambdamin', 'lambda1se', 'fa0', 'fclassnames',...
        'fbeta', 'fdevratio', 'fnulldev', 'fdf', 'flambda', 'fnpasses',...
        'fjerr', 'fdim', 'foffset', 'fcall', 'fnobs'});
    
    % clean up temporary files
    delete(data_filename_input);
    delete(data_filename_output);
        
end
