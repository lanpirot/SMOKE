function removeSizes(subsystems)
% Resets shape and sizes of blocks
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Resets shape and sizes of blocks

    for i = 1:length(subsystems)

        blocks = find_system(subsystems(i), 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'SearchDepth', '1', 'type', 'Block');
        for j = 1:length(blocks)
            % create a tmp block from which to steal the default sizes
            try
                curr_block = blocks(j);
                curr_parent = get_param(curr_block, 'Parent');
                tmp_block_path = [curr_parent '/' 'tmpblock'];
                tmp_block = add_block(['built-in/', get_param(curr_block, 'BlockType')], tmp_block_path);
                tmp_block_pos = get_param(tmp_block, 'Position');
                width = tmp_block_pos(3) - tmp_block_pos(1);
                height = tmp_block_pos(4) - tmp_block_pos(2);
                
                curr_block_pos = get_param(curr_block, 'Position');
                curr_block_pos(3) = curr_block_pos(1) + width;
                curr_block_pos(4) = curr_block_pos(2) + height;
                set_param(curr_block, 'Position', curr_block_pos)
            catch ME
                if ~ismember(ME.identifier, {'Simulink:blocks:TriggerPortExists' 'Simulink:blocks:EnablePortExists' 'Simulink:blocks:ActionPortExists' 'Simulink:blocks:IteratorBlockExists' 'Simulink:Commands:AddBlockBuiltinInportShadow' 'Simulink:StateConfigurator:DuplicateConfiguratorBlocks' 'Simulink:Libraries:RefModificationViolation' 'Simulink:blocks:EventListenerCannotBeAddedToSSHavingEventListenerBlock' 'Simulink:blocks:DataPortNotAllowedForCompositionSubDomain' 'Simulink:blocks:ResetPortExists' 'Simulink:blocks:SubsysErrFcnMsg'})
                    rethrow(ME)
                end
            end
    
            % Clean up: Remove tmp block
            try
                delete_block(tmp_block_path)
            catch ME
                if ~strcmp(ME.identifier, 'Simulink:Commands:InvSimulinkObjectName')
                    rethrow(ME)
                end
            end
        end
        
    end
end
