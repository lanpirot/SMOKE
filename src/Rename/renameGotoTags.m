function renameGotoTags(sys)
% RENAMEGOTOTAGS Give all goto/froms generic tags.
% Should be run from the root to avoid overlapping names.

    sys = get_param(sys, 'handle');
    gotos = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'Goto');
    changedFroms = [];

    for i = 1:length(gotos)
        tag = get_param(gotos(i), 'GotoTag');
        froms = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'From', 'GotoTag', tag);

        % Change goto
        set_param(gotos(i), 'GotoTag', ['GotoFrom' num2str(i)]);

        % Change froms
        for j = 1:length(froms)
            set_param(froms(j), 'GotoTag', ['GotoFrom' num2str(i)]);
            changedFroms = [changedFroms; froms(j)];
        end
    end

    % Change dangling Froms
    % TODO: Change froms with the same GotoTag to the same generic GotoTag
    froms = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'From');
    leftOver = setdiff(getfullname(froms), getfullname(changedFroms));
    for k = 1:length(leftOver)
         set_param(leftOver{k}, 'GotoTag', ['GotoFrom' num2str(k)]);
    end
end