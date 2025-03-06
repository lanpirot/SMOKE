function removeSubsystems(subsystems)
    for i=1:length(subsystems)
        try
            Simulink.BlockDiagram.expandSubsystem(subsystems(i));
        catch ME
            if ~ismember(ME.identifier, {'Simulink:ExpandSubsystem:EnabledSubsystem' 'Simulink:ExpandSubsystem:NotSubsystem' 'Simulink:ExpandSubsystem:SimulationCallbacks' 'Simulink:ExpandSubsystem:Masked'})
                rethrow(ME)
            end
        end
    end
end