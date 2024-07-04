function removeDescriptions(sys)
% REMOVEDESCRIPTIONS Remove all Description parameters in lines, blocks and
% annotations.

    sys = get_param(sys, 'handle');
    all = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    all = [all; find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'type', 'annotation')];
    all = [all; find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'type', 'line')];
    for i = 1:length(all)
        try
            set_param(all(i), 'Description', '');
            set_param(all(i), 'Tag', '');
            set_param(all(i), 'BlockDescription', '');
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:SetParamReadOnly' 'Simulink:Commands:ParamUnknown' 'Simulink:Libraries:RefModificationViolation' 'Simulink:Libraries:RefViolation' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem'})
                corethrow(ME)
            end
        end
    end
            
%         % Subsystem specific
%         if strcmp(get_param(all(i), 'BlockType'), 'SubSystem')
%             % RTW params
%             set_param(all(i), 'RTWSystemCode', 'Auto');
%             set_param(all(i), 'RTWFcnNameOpts', 'Auto');
%             set_param(all(i), 'RTWFcnName', '');
%             set_param(all(i), 'RTWFileNameOpts', 'Auto');
%             set_param(all(i), 'RTWFileName', '');
%         end
end