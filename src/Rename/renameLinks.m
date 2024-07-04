function renameLinks(sys)
% RENAMELINKS Give all linked blocks and library links new names. Show names for inspection purposes.

    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block', 'BlockType', 'Reference'); 
    for i = 1:length(blocks)
        set_param(blocks(i), 'ShowName', 'on');
        try
            set_param(blocks(i), 'HideAutomaticName', 'off');
        catch ME
            if ~strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
                rethrow(ME)
            end
        end
    end
end