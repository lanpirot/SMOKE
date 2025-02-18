function hideContentPreview(blocks)
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
    

    for i = 1:length(blocks)
        try
            set(blocks(i), 'ContentPreviewEnabled', 'Off'); 
        catch ME %trying to suppress popup errors of Mask Initialization failures
        end
    end
end