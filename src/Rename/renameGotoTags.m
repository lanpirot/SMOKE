function renameGotoTags(fromsOrig, gotos)
% RENAMEGOTOTAGS Give all goto/froms generic tags.
% Should be run from the root to avoid overlapping names.

    changedFroms = [];

    for i = 1:length(gotos)
        tag = get_param(gotos(i), 'GotoTag');
        froms = fromsOrig(strcmp(get_param(fromsOrig, 'GotoTag'), tag));

        % Change goto
        set_param(gotos(i), 'GotoTag', ['GotoFrom' num2str(i)]);

        % Change froms
        for j = 1:length(froms)
            set_param(froms(j), 'GotoTag', ['GotoFrom' num2str(i)]);
            changedFroms = [changedFroms; froms(j)];
        end
    end

    % Change dangling Froms
    leftOver = setdiff(getfullname(fromsOrig), getfullname(changedFroms));
    for k = 1:length(leftOver)
         set_param(leftOver{k}, 'GotoTag', ['GotoFrom' num2str(k)]);
    end
end