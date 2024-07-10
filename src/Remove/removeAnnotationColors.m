function removeAnnotationColors(sys)
% REMOVEANNOTATIONCOLORS Remove all annotation coloring from the model.

    sys = get_param(sys, 'handle');
    ann = find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'type', 'annotation');
    for i = 1:length(ann)
        try
            set_param(ann(i), 'ForegroundColor', 'black');
            set_param(ann(i), 'BackgroundColor', 'white');
        catch ME %in unlockable Subsystems, these changes are not supported
            if ~strcmp(ME.identifier, 'Simulink:Libraries:RefViolation')
                rethrow(ME)
            end
        end
    end
end