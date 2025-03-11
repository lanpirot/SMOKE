function removePositioning(blocks)
% Autopositions the whole model
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Autopositions the whole model
    for j = 1:length(blocks)
        pos = get_param(blocks(j), 'Position');
        width = pos(3) - pos(1);
        height = pos(4) - pos(2);
        pos = [0 0 width height];
        set_param(blocks(j), 'Position', pos)
    end

    %then auto layout the subsystems
    try
        %Simulink.BlockDiagram.arrangeSystem(subsystems(i), FullLayout='true')
    catch ME
        if ~ismember(ME.identifier, {'glee_util:messages:GenericError'})
            rethrow(ME)
        end
        %some Subsystems, like the compare to constant block pretend to
        %be a Subsystem, while no changes within are possible.
    end
end
