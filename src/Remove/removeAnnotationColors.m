function removeAnnotationColors(ann)
% REMOVEANNOTATIONCOLORS Remove all annotation coloring from the model.

    for i = 1:length(ann)
        try
            set_param(ann(i), 'ForegroundColor', 'black');
            set_param(ann(i), 'BackgroundColor', 'white');
        catch ME %in unlockable Subsystems, these changes are not supported
            if ~strcmp(ME.identifier, {'Simulink:Libraries:RefViolation', 'MATLAB:hg:udd_interface:CannotDelete'})
                rethrow(ME)
            end
        end
    end
end