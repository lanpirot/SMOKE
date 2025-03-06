function renameConstants(blocks)

% RENAMECONSTANTS Give all constants generic values. Applies only if the
% constant has a variable value instead of a number.
    
    for i = 1:length(blocks)
        val = get_param(blocks(i), 'Value');
        isNaN = isnan(str2double(val));
        try
            if isNaN
                % Constant is a variable
                set_param(blocks(i), 'Value', ['Constant' num2str(i)]);
                set_param(blocks(i), 'OutDataTypeStr', 'Inherit: Inherit from ''Constant value''');
                
                % TODO: Should the workspace/data dictionary variable also be renamed?
            else
                set_param(blocks(i), 'Value', '1');
            end
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:Promote_Parameter_InvalidSet' 'Simulink:SampleTime:InvTsParamSetting_Vector'})
                rethrow(ME)
            end
        end
    end
end