function removeFunctions(sys)
% Removes MATLAB function Blocks' innards

    sys = get_param(sys, 'handle');
    block = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'type', 'block');
    for i = 1:length(block)
        try
        config = get_param(block(i), "MATLABFunctionConfiguration");
        config.FunctionScript = '';
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:ParamUnknown'})
                continue
            end
            config.FunctionScript = '1';
        end
    end
end


