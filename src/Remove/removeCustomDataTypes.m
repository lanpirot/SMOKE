function removeCustomDataTypes(inports)
% REMOVECUSTOMDATATYPES Remove custom data types for inports.

    % TODO: 
    % - Allow fixdt
    % - Should work on all blocks with a specified data type
    builtinTypes = [{'Inherit: auto'}, {'boolean'}, {'double'}, {'single'}, {'int8'}, {'uint8'}, {'int16'}, {'uint16'}, {'int32'}, {'uint32'}];
    for i = 1:length(inports)
        t = get_param(inports(i), 'OutDataTypeStr');
        if ~any(ismember(builtinTypes, t))
            set_param(inports(i), 'OutDataTypeStr', 'Inherit: auto');
        end
    end
end