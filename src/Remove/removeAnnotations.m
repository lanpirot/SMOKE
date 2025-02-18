function removeAnnotations(annotations, blocks)
% REMOVEANNOTATIONS Remove all annotations from the model. 
% Removes any text, area, or image annotations.
    for a = 1:length(annotations)
        try
            delete(annotations(a))
        catch ME %in unlockable subsystems, annotations cannot be deleted
            if ~ismember(ME.identifier, {'Simulink:Libraries:RefModificationViolation' 'Simulink:blocks:SubsysWriteProtected'})
                rethrow(ME)
            end
        end
    end

    % Remove block annotations
    for i = 1:length(blocks)
        if strcmp(get_param(blocks(i), 'AttributesFormatString'),'')
            continue
        end
        try
            set_param(blocks(i), 'AttributesFormatString', '');
        catch ME %in unlockable subsystems, annotations cannot be deleted
            if ~ismember(ME.identifier, {'Simulink:Libraries:LockViolation' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem'})
                rethrow(ME)
            end
        end
    end
end