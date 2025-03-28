function removeSubsystems(subsystems)
    subsystems = get_param(subsystems, 'Handle');
    for i=1:length(subsystems)
        try
            Simulink.BlockDiagram.expandSubsystem(subsystems{i});
        catch ME
            if ~ismember(ME.identifier, {'Simulink:ExpandSubsystem:EnabledSubsystem' 'Simulink:ExpandSubsystem:NotSubsystem' 'Simulink:ExpandSubsystem:SimulationCallbacks' 'Simulink:ExpandSubsystem:Masked' 'Simulink:ExpandSubsystem:HiddenContents' 'Simulink:ExpandSubsystem:VariantSubsystem' 'Simulink:ExpandSubsystem:LibraryLink' 'Simulink:ExpandSubsystem:ConfigurableSubsystem' 'Simulink:ExpandSubsystem:LockedLibraryLink'})
                rethrow(ME)
            end
        end
    end
end