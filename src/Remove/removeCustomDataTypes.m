function removeCustomDataTypes(inports)
% REMOVECUSTOMDATATYPES Remove custom data types for inports.

    %builtinTypes = [{'Inherit: auto'}, {'boolean'}, {'double'}, {'single'}, {'int8'}, {'uint8'}, {'int16'}, {'uint16'}, {'int32'}, {'uint32'}];
    for i = 1:length(inports)
        try
            t = get_param(inports(i), 'OutDataTypeStr');
            %if ~any(ismember(builtinTypes, t))
            if ~strcmp(t, 'Inherit: auto')
                set_param(inports(i), 'OutDataTypeStr', 'Inherit: auto');
            end
        catch ME
            if ~ismember(ME.identifier, {})
                rethrow(ME)
            end
        end
    end
end