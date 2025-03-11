function removeDescriptions(bla)
% REMOVEDESCRIPTIONS Remove all Description parameters in lines, blocks and
% annotations.
    
    for i = 1:length(bla)
        try
            set_param(bla(i), 'Description', '');
            set_param(bla(i), 'Tag', '');
            set_param(bla(i), 'BlockDescription', '');
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:SetParamReadOnly' 'Simulink:Commands:ParamUnknown' 'Simulink:Libraries:RefModificationViolation' 'Simulink:Libraries:RefViolation' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem' 'Simulink:BusElPorts:CannotChangeAttributesBusObject' 'Simulink:blocks:SubsysErrFcnMsg'})
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