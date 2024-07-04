function renameSimFcns(sys, parentSys)
% RENAMESIMFCNS Rename Simulink Functions to generic names, and update callers.
    % Triggers
    sys = get_param(sys, 'handle');
    triggers = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'BlockType', 'TriggerPort');
    global fcnNum;
    if isempty(fcnNum)
        fcnNum = 1;
    end
    for i = 1:length(triggers)
        if strcmp(get_param(triggers(i), 'IsSimulinkFunction'), 'on')
            simFcn = get_param(triggers(i), 'Parent');
            callers = findCallers(simFcn, parentSys);
            
            newName = ['f' num2str(fcnNum)];
            set_param(triggers(i), 'FunctionName', newName);
            
            fcnNum = fcnNum + 1;
            
            % Update the Simulink Function callers
            if ~isempty(callers)
                updateCallers(simFcn, callers, newName, parentSys)
            end
        end
    end  
end