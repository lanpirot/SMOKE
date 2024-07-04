function removeBlockColors(sys)
% REMOVEBLOCKCOLORS Remove all block coloring from the model.

    allBlks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    for i = 1:length(allBlks)
        try
            set_param(allBlks{i}, 'ForegroundColor', 'black');
            set_param(allBlks{i}, 'BackgroundColor', 'white');
        catch ME
            if ~strcmp(ME.identifier, '')
                rethrow(ME)
            end
        end
    end
end