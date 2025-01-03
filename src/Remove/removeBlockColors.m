function removeBlockColors(sys)
% REMOVEBLOCKCOLORS Remove all block coloring from the model.

    sys = get_param(sys, 'handle');
    allBlks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'type', 'block');
    for i = 1:length(allBlks)
        try
            set_param(allBlks(i), 'ForegroundColor', 'black');
            set_param(allBlks(i), 'BackgroundColor', 'white');
        catch ME
            if ~strcmp(ME.identifier, 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem')
                rethrow(ME)
            end
        end
    end
end