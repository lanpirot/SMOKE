function renameBlocks(sys)
% RENAMEBLOCKS Change the 'Name' parameter to a generic name based on the block type.
    
    sys = get_param(sys, 'handle');
    blks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'Type', 'Block');
    
    
    
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
               blks_type{h} = getSubsystemType(blks(h));
           end   
       end
    end
    
    % Rename
    suffix = 1;
    for j = 1:length(blks)
        while 1
            suffix = suffix + 1;
            try
                set_param(blks(j), 'Name', [blks_type{j} num2str(suffix)]);
                set_param(blks(j), 'ShowName', 'off');
                break
            catch ME
                %try again, until an unblocked name is found
            end
        end
    end
end