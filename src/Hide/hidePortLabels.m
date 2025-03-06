function hidePortLabels(blocks)
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
    
    

    for i = 1:length(blocks)
        try
            set_param(blocks(i), 'ShowPortLabels', 'none');
        catch ME %may cause 'Failed to evaluate mask initialization commands.'
        end
    end
end