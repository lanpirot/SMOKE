function removeDocBlocks(sys)
% REMOVEDOCBLOCKS Remove all DocBlocks from the model.

    delete_block(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'BlockType', 'SubSystem', 'MaskType', 'DocBlock'));
end