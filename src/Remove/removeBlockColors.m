function removeBlockColors(allBlks)
% REMOVEBLOCKCOLORS Remove all block coloring from the model.
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