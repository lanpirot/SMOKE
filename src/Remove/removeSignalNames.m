function removeSignalNames(sys)
% REMOVESIGNALNAMES Remove signal names and turn off signal propagation.
% NOTE: This does not work for signals of buses.
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Removes names and disables signal propagation.

    sys = get_param(sys, 'handle');
    % Lines
    lines = find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'type', 'line');
    for i = 1:length(lines)
        try
            set(lines(i), 'SignalPropagation', 'off');
            set(lines(i), 'Name', '');
        catch
            % Bus signal
        end
    end

    % Ports
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'block');
    for j = 1:length(blocks)
         pc = get_param(gcb, 'PortHandles');
         for k = 1:length(pc.Outport)
             try
                set_param(pc.Outport(k), 'ShowPropagatedSignals', 'off')
             catch me
                 if ~strcmp(me.identifier, 'Simulink:Signals:NoPropSigLabThroughBlock') && ~strcmp(me.identifier, 'Simulink:Libraries:LockViolation')
                     rethrow(me)
                 end
             end
         end
    end
end
