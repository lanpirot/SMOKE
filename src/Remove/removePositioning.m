function removePositioning(sys)
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

    %for all subsystems:
    subsystems = find_system(sys, 'FindAll', 'on', 'FollowLinks', 'on', 'BlockType', 'SubSystem');
    subsystems = [subsystems; get_param(sys, 'Handle')];
    for i = 1:length(subsystems)

        %first reset all blocks to the origin
        blocks = find_system(subsystems(i), 'SearchDepth', '1', 'type', 'Block');
        for j = 1:length(blocks)
            pos = get_param(blocks(j), 'Position');
            width = pos(3) - pos(1);
            height = pos(4) - pos(2);
            pos = [0 0 width height];
            set_param(blocks(j), 'Position', pos)
        end

        %then auto layout the subsystems
        try
            Simulink.BlockDiagram.arrangeSystem(subsystems(i), FullLayout='true')
        catch ME
            %some Subsystems, like the compare to constant block pretend to
            %be a Subsystem, while no changes within are possible.
        end
    end
end
