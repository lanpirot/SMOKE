function removeDocBlocks(sys)
% REMOVEDOCBLOCKS Remove all DocBlocks from the model.
    sys = get_param(sys, 'handle');
    delete_block(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'SubSystem', 'MaskType', 'DocBlock'));
end