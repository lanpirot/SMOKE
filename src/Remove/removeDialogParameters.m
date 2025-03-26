function removeDialogParameters(blocks)
% Reset all Dialog Parameters of all blocks
%
%   Inputs:
%       sys     Name of Simulink model or subsystem.
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Resets all Dialog Parameters of all blocks.

    for i = 1:length(blocks)
        warning('off', 'all');
        try
            curr_block = blocks(i);
            curr_parent = get_param(curr_block, 'Parent');
            tmp_block_path = [curr_parent '/' 'tmpblock'];
            tmp_block = add_block(['built-in/', get_param(curr_block, 'BlockType')], tmp_block_path);
            
            if ~isempty(get_param(tmp_block, 'DialogParameters'))
                params = fields(get_param(tmp_block, 'DialogParameters'));
                
                for p = 1:length(params)
                    if ismember(params{p}, {'Inputs', 'Outputs', 'VariantControl', 'VariantControlMode', 'LabelModeActiveChoice', 'NumPorts', 'FrameSettings', 'Port', 'NumInputPorts', 'NumOutputPorts', 'BlockChoice', 'ShowPortLabels', 'MemberBlocks', 'InitialConditionSource', 'Permissions'}) 
                        %these exceptions are mostly to not ruin the
                        %structure of the model, like mux/demux, but also
                        %because they may trigger MATLAB hard crashes
                        continue
                    end
                    try
                        if isequal(get_param(curr_block, params{p}), get_param(tmp_block, params{p}))
                            %often MATLAB hard crashes, even if the
                            %parameters would not be changed, as they are the same before and after --> skip
                            %if started without display, some DialogParameters are completely broken, also
                            continue
                        end
                    catch ME

                        if ~ismember(ME.identifier, {'Simulink:Libraries:FailedToLoadLibraryForBlock' 'Simulink:DataType:DataTypeObjectNotInScope' 'MATLAB:class:InvalidHandle'})
                            rethrow(ME)
                        end
                    end
                    try
                        %fprintf("%i %i %i %s\n", length(find_system(bdroot(blocks(i)), 'FindAll', 'on', 'LookUnderMasks', 'all', 'Variants', 'AllVariants', 'Type', 'Line')), i, p, params{p})
                        set_to = get_param(tmp_block, params{p});
                        if strcmp(params{p}, 'InitialCondition') || strcmp(params{p}, 'Gain')
                            set_to = '17';
                        end
                        set_param(curr_block, params{p}, set_to)
                        %fprintf("%i %i %i %s\n", length(find_system(bdroot(blocks(i)), 'FindAll', 'on', 'LookUnderMasks', 'all', 'Variants', 'AllVariants', 'Type', 'Line')), i, p, params{p})
                    catch ME
                        %there is too many to catch and handle
                        %just ignore model breaking dialog parameter
                        %changes
                        %if ~ismember(ME.identifier, {'Simulink:Commands:AddBlockInvSrcBlock' 'Simulink:blocks:ConfigSubInvTemplate' 'Simulink:BusElPorts:ParameterNotSupported' 'MATLAB:fieldnames:InvalidInput' 'Simulink:blocks:InvDiscPulseWidth' 'Simulink:Libraries:MissingSourceBlock' 'Simulink:blocks:TriggerPortExists' 'Simulink:Commands:InvSimulinkObjectName' 'Simulink:Commands:SetParamReadOnly' 'Simulink:Parameters:InvParamSetting'})
                        %    rethrow(ME)
                        %end
                    end
                end
            end
            set_param(curr_block, 'MoveFcn', '')
        catch ME
            if ~ismember(ME.identifier, {'Simulink:blocks:EnablePortExists' 'Simulink:blocks:TriggerPortExists' 'Simulink:blocks:ActionPortExists' 'Simulink:blocks:IteratorBlockExists' 'Simulink:Libraries:CannotChangeLinkedBlkParam' 'Simulink:StateConfigurator:DuplicateConfiguratorBlocks' 'Simulink:Commands:AddBlockBuiltinInportShadow' 'Simulink:Libraries:RefModificationViolation' 'Simulink:Commands:InvSimulinkObjHandle' 'Simulink:blocks:EventListenerCannotBeAddedToSSHavingEventListenerBlock' 'Simulink:blocks:DataPortNotAllowedForCompositionSubDomain' 'Simulink:blocks:ResetPortExists' 'Simulink:CustomCode:InvalidFunctionName' 'Simulink:CustomCode:TokenizeError' 'Simulink:blocks:SubsysErrFcnMsg'})
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
