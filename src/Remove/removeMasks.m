function removeMasks(sys)
% REMOVEMASKS Clear the MaskDisplay parameter on blocks. Masks are commonly
% used for custom blocks, which the user may not want to reveal.

    blocks = find_system(sys, 'FollowLinks', 'on', 'type', 'block');
    for i = 1:length(blocks)
        try
            set_param(blocks{i}, 'MaskDisplay', '');
            set_param(blocks{i}, 'Mask', 'off');
            set_param(blocks{i}, 'MaskInitialization', '')
        catch
            % Skip. E.g., Reference blocks won't allow Mask modifications it.
        end
    end
end