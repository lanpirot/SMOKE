function renameBlocks(sys)
% RENAMEBLOCKS Change the 'Name' parameter to a generic name based on the block type.
    
    sys = get_param(sys, 'handle');
    blks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Type', 'Block');
    blks_hdl = get_param(blks, 'Handle');
    blks_parent = get_param(blks, 'Parent');
    
    blks_rename = cell(size(blks));
    blks_rename(:) = {''};
    
    % Get more accurate block types for Stateflow elements
    blks_type = get_param(blks, 'BlockType');
    if ~iscell(blks_type)
        blks_type = {blks_type};
    end
    for h = 1:length(blks_type)
       if strcmp(blks_type{h}, 'SubSystem')
            
           sfBlockType = '';
           try 
               sfBlockType = get_param(blks(h), 'SFBlockType');
           catch ME
                if ~strcmp(ME.identifier, '')
                    rethrow(ME)
                end
           end
            
           if ~isempty(sfBlockType) && ~strcmpi(sfBlockType, 'NONE')
                % Stateflow element
               blks_type{h} = strrep(sfBlockType, ' ', '');
           else
               % Subsystem
               blks_type{h} = getSubsystemType(blks_hdl(h));
           end   
       end
    end
    
    % Determine new name
    for i = 1:length(blks)
        suffix = 1;

        if i == 1
            % First element has no duplicates, so don't need further checks
            blks_rename{i} = [blks_type{i} num2str(suffix)];
            continue
        end
        
        % Check that new block name does not overlap with previous names
        sameTypeIdx = strcmp(blks_type{i}, blks_type(1:i-1));
        parents = blks_parent(sameTypeIdx);
        numDuplicates = length(find(strcmp(blks_parent(i), parents)));

        suffix = numDuplicates + 1; % Increment suffix so the names aren't the same
        blks_rename{i} = [blks_type{i} num2str(suffix)];
    end
    
    % Rename
    for j = 1:length(blks)
        try
            set_param(blks_hdl(j), 'Name', blks_rename{j});
        catch ME
            if strcmp(ME.identifier, 'Simulink:blocks:DupBlockName')
                % Block with that name already exists
                parent = get_param(blks_hdl(j), 'Parent');
                set_param([parent '/' blks_rename{j}], 'Name', [blks_rename{j} '_temp' num2str(j)]);
                set_param(blks_hdl(j), 'Name', blks_rename{j});
            else
                warning(['Could not rename block ' blks(j)]);
            end
        end
    end
end