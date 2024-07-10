function hidePortLabels(sys, varargin)
% HIDEPORTLABELS Make port labels of Subsystems visible or hidden.
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%       show    Whether to hide the port label (1), or not (0). [Default is 1]
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Shows or hides the port label.

    sys = get_param(sys, 'handle');

    if nargin > 1
        hide = varargin{1};
    else
        hide = true;
    end
    
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'SubSystem');
    
    if hide
        for i = 1:length(blocks)
            try
                set_param(blocks(i), 'ShowPortLabels', 'none');
            catch ME %may cause 'Failed to evaluate mask initialization commands.'
            end
            %fprintf('%i %i\n', i, length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on')))
        end
    else
        for i = 1:length(blocks)
            set_param(blocks(i), 'ShowPortLabels', 'FromPortIcon');
        end
    end
end