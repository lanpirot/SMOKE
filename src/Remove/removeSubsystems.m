function removeSubsystems(subsystems)
    for i=1:length(subsytems)
        try
            Simulink.BlockDiagram.expandSubsystem(subsystems(i));
        catch ME
            rethrow(ME)
        end
    end
end