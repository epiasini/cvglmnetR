function fit = cvSGL(x, y, index, options, foldid)
    
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
        if ispc
            r_out_file = 'NUL';
        else
            r_out_file = '/dev/null';
        end
    end
    
    % convert options from SGLSet object to simple struct. This is
    % needed for the save -struct command below
    options = struct(options);
    
    % save data and parameters for fit to temporary file and call R
    r_script = fullfile(fileparts(which('cvSGL')), 'cvSGL.from.matlab.R');
    save(data_filename_input, '-struct', 'options');
    save(data_filename_input, 'x', 'y', 'index', 'foldid', '-append');
    command = sprintf('R CMD BATCH %s''--args %s'' %s %s',...
        r_opts, temp_filename, r_script, r_out_file);
    system(command);
    
    % rename results fields and package the SGL fit object into a nested
    % structure
    fit = load(data_filename_output);
    
    fit.fit = struct();
    fit.fit.beta = fit.fbeta;
    fit.fit.lambdas = fit.flambdas;
    fit.fit.type = fit.ftype;
    fit.fit.intercept = fit.fintercept;
    fit.fit.X_transform = fit.fXtransform;
    
    fit = rmfield(fit, {'fbeta', 'flambdas', 'ftype', 'fintercept', ...
                        'fXtransform'});
    
    % clean up temporary files
    %    delete(data_filename_input);
    delete(data_filename_output);
        
end
