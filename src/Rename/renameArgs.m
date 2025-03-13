function renameArgs(allArgIns, allArgOuts)
% RENAMEARGS Give all Simulink Function arguments generic names.

    parentSys = gcs;
    % Argument Inputs
    for i = 1:length(allArgIns)
        changed = false;
        num = 1;
        simFcn = get_param(allArgIns(i), 'Parent');
        callers = findCallers(simFcn, parentSys);
        while ~changed
            try
                newName = ['u' num2str(num)];
                set_param(allArgIns(i), 'ArgumentName', newName);
                changed = true;
            catch
                num = num + 1;
            end
        end
        % Update the function callers that use the argument
        if ~isempty(callers)
            updateCallers(simFcn, callers, [], parentSys);
        end
    end

    % Argument Outputs
    for j = 1:length(allArgOuts)
        changed = false;
        num = 1;
        simFcn = get_param(allArgOuts(j), 'Parent');
        callers = findCallers(simFcn, parentSys);
        while ~changed
            try
                newName = ['y' num2str(num)];
                set_param(allArgOuts(j), 'ArgumentName', newName);
                changed = true;
            catch
                num = num + 1;
            end
        end
        if ~isempty(callers)
            updateCallers(simFcn, callers, [], parentSys);
        end
    end
end