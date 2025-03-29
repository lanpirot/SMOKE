function renameConstants(blocks)

% RENAMECONSTANTS Give all constants generic values and name.
    
    for i = 1:length(blocks)
        try
            val = get_param(blocks(i), 'Value');
            isNaN = isnan(str2double(val));
        
            set_param(blocks(i), 'Name', ['Constant' num2str(blocks(i))]);
            if ~isNaN
                set_param(blocks(i), 'Value', '-17');
            elseif ischar('val')
                % Constant is a string
                set_param(blocks(i), 'Value', '-17');
                set_param(blocks(i), 'OutDataTypeStr', 'char');
                try
                    set_param(blocks(i), 'Value', '-17randText-17');
                catch
                end
                %set_param(blocks(i), 'OutDataTypeStr', 'Inherit: Inherit from ''Constant value''');                
                % TODO: Should the workspace/data dictionary variable also be renamed?
            else
                disp(1)
            end
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:Promote_Parameter_InvalidSet' 'Simulink:SampleTime:InvTsParamSetting_Vector' 'Simulink:Parameters:InvParamSetting' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem'})
                rethrow(ME)
            end
        end
    end
end