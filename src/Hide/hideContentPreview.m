function hideContentPreview(subs)
% HIDECONTENTPREVIEW Make the content preview of Subsystems visible or hidden.
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%       show    Whether to hide the preview (1), or not (0). [Default is 1]
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Shows or hides the content preview.
    

    for i = 1:length(subs)
        try
            set_param(subs{i}, 'ContentPreviewEnabled', 'Off'); 
        catch ME %trying to suppress popup errors of Mask Initialization failures
            if ~ismember(ME.identifier, {'Simulink:Masking:Bad_Init_Commands' 'Simulink:Libraries:FailedToLoadLibraryForBlock' 'Simulink:Libraries:MissingBlockInLib' 'Simulink:Parameters:InvParamSetting'})
                rethrow(ME)
            end
        end
    end
end