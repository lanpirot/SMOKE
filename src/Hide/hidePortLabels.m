function hidePortLabels(subs)
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
    
    

    for i = 1:length(subs)
        try
            set_param(subs{i}, 'ShowPortLabels', 'none');
        catch ME %may cause 'Failed to evaluate mask initialization commands.'
            if ~ismember(ME.identifier, {'Simulink:Libraries:CannotChangeLinkedBlkParam' 'Simulink:Masking:Bad_Init_Commands' 'Simulink:Libraries:FailedToLoadLibraryForBlock'})
                rethrow(ME)
            end
        end
    end
end