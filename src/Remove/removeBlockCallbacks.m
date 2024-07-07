function removeBlockCallbacks(sys)
% REMOVEBLOCKCALLBACKS Clear the various callback parameters on blocks. 
% These parameters may include custom scripts.
%
% See: https://www.mathworks.com/help/simulink/ug/block-callbacks.html

    sys = get_param(sys, 'handle');
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    callbacks = {'CopyFcn' 'DeleteFcn' 'LoadFcn' 'ModelCloseFcn' 'PreSaveFcn' 'PostSaveFcn' 'InitFcn' 'StartFcn' 'PauseFcn' 'ContinueFcn' 'StopFcn' 'NameChangeFcn' 'ClipboardFcn' 'DestroyFcn' 'PreCopyFcn' 'OpenFcn' 'CloseFcn' 'PreDeleteFcn' 'ParentCloseFcn' 'MoveFcn' 'PreSaveFcn'};
    for i = 1:length(blocks)
        for c = 1:length(callbacks)
            try
                set_param(blocks(i), callbacks{c}, '');
            catch ME
                if ~ismember(ME.identifier, {'Simulink:Commands:SetParamInvalidArgumentType' 'Simulink:Libraries:CannotChangeLinkedBlkParam' 'Simulink:Commands:InvSimulinkObjHandle' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem' 'Simulink:blocks:SubsysErrFcnMsgInvCB'})
                    rethrow(ME)
                end
            end
        end
    end
end