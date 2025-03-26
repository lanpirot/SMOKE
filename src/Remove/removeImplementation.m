function removeImplementation(sys)
% REMOVEIMPLEMENTATION Clear system of implementation blocks. Keep interface
% blocks.
%currently this function is not called. It would not work as is: the
%surrounding SubSystems of the "interface" will get deleted, as well.

    % Remove lines
    allLines = find_system(sys, 'Searchdepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'All', 'MatchFilter', @Simulink.match.allVariants, 'FindAll', 'on', 'Type', 'line');
    delete_line(allLines);
    
    blocks = find_system(sys, 'SearchDepth', '1', 'MatchFilter', @Simulink.match.allVariants, 'type', 'block');
    
    % Blocks to keep
    inports = find_system(sys, 'SearchDepth', '1', 'FindAll', 'on', 'MatchFilter', @Simulink.match.allVariants, 'type', 'block', 'BlockType', 'Inport');
    outports = find_system(sys, 'SearchDepth', '1', 'FindAll', 'on', 'MatchFilter', @Simulink.match.allVariants, 'type', 'block', 'BlockType', 'Outport');
    triggers = find_system(sys, 'SearchDepth', '1', 'FindAll', 'on', 'MatchFilter', @Simulink.match.allVariants, 'type', 'block', 'BlockType', 'TriggerPort');
    
    
    blocks(blocks==get_param(sys, 'Handle')) = []; % Remove sys from list, faster maybe: blocks[1] = [];
    blocks = setdiff(blocks, inports);
    blocks = setdiff(blocks, outports);
    blocks = setdiff(blocks, triggers);
    delete_block(blocks);
end