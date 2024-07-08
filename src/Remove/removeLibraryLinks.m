function removeLibraryLinks(sys)
% REMOVELIBRARYLINKS Break library links. Links can be used to reference custom
% blocks or other libraries.

    sys = get_param(sys, 'handle');
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    simscapestr = 'Simscape';
    lsimscapestr = length(simscapestr);
    for i = 1:length(blocks)

        try
            bt = get_param(blocks(i), 'blocktype');

            portHandles = get_param(blocks(i), 'porthandles');
            if strcmp(bt(1:min(lsimscapestr, length(bt))), simscapestr) || ~isempty(portHandles.LConn) || ~isempty(portHandles.RConn)
                % do not interfere with Simscape blocks
                continue
            end
            % Reset parameter values
            set_param(blocks(i), 'LinkStatus', 'none');
            set_param(blocks(i), 'ReferenceBlock', '');
            set_param(blocks(i), 'SourceBlock', '');
        catch ME
            if ~ismember(ME.identifier, {'Simulink:Commands:ParamUnknown' 'Simulink:blocks:BlkParamLinkStatusOnNonReference' 'Simulink:Libraries:MissingSourceBlock' 'Simulink:blocks:SubsysReadProtectErr' 'Simulink:blocks:SubsysErrFcnMsgInvCB' 'Simulink:Commands:InvSimulinkObjHandle' 'Simulink:Libraries:SetParamDeniedForBlockInsideReadOnlySubsystem' 'Simulink:blocks:SubsysErrFcnMsg' 'Simulink:blocks:SubsysErrFcnMsgInvCBRetVal'})
                rethrow(ME)
            end
        end
    end
end