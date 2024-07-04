function removeAnnotations(sys)
% REMOVEANNOTATIONS Remove all annotations from the model. 
% Removes any text, area, or image annotations.
    annotations = find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'type', 'annotation');
    for a = 1:length(annotations)
        try
            delete(annotations(a))
        catch ME %in unlockable subsystems, annotations cannot be deleted
            if ~strcmp(ME.identifier, 'Simulink:Libraries:RefModificationViolation')
                rethrow(ME)
            end
        end
    end

    % Remove block annotations
    blocks = Simulink.findBlocks(sys);
    for i = 1:length(blocks)
        if strcmp(get_param(blocks(i), 'AttributesFormatString'),'')
            continue
        end
        try
            set_param(blocks(i), 'AttributesFormatString', '');
        catch ME %in unlockable subsystems, annotations cannot be deleted
            if ~strcmp(ME.identifier, 'Simulink:Libraries:LockViolation')
                rethrow(ME)
            end
        end
    end
end