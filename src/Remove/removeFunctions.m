function removeFunctions(blocks)
% Removes MATLAB function Blocks' innards

    for i = 1:length(blocks)
        try
        config = get_param(blocks(i), "MATLABFunctionConfiguration");
        config.FunctionScript = '0';
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:ParamUnknown' 'Simulink:blocks:LockedMATLABFunction' 'Simulink:blocks:LinkedMATLABFunction'})
                rethrow(ME)
            end
        end
    end
end


