function removeLibraryLinks(sys)
% REMOVELIBRARYLINKS Break library links. Links can be used to reference custom
% blocks or other libraries.

    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'type', 'block');
    for i = 1:length(blocks)
            
        try
            % Reset parameter values
            set_param(blocks(i), 'ReferenceBlock', '');
            set_param(blocks(i), 'LinkStatus', 'none');
            set_param(blocks(i), 'SourceBlock', '');
        catch
        end
    end
end