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
% This code is definitely not great, I know. Hard work by trial and error
% for alle these special cases, though..

    %file_name = ['C:/tmp/obfmodels/' gcs '_custom_parameters.csv'];
    %fileID = fopen(file_name, 'w');

    for i = 1:length(blocks)
        curr_block = blocks(i);
        curr_params = get_param(curr_block, 'DialogParameters');
        if isempty(curr_params)
            curr_params = {};
        else
            curr_params = fields(curr_params);
        end

        tmp_block_path = [get_param(curr_block, 'Parent') '/' 'tmpblock'];
        try
            tmp_block = add_block(['built-in/', get_param(curr_block, 'BlockType')], tmp_block_path);
            tmp_params = get_param(tmp_block, 'DialogParameters');
            if isempty(tmp_params)
                tmp_params = {};
            else
                tmp_params = fields(tmp_params);
            end
            tmp_success = 1;
        catch ME
            tmp_params = {};
            tmp_success = 0;
            continue
        end
        
        params = setdiff(curr_params, tmp_params);
        %for parameters, whose settings we cannot look up in a blank
        %block, we revert to guessing some value like -17 or ''
        for p = 1:length(params)
            try
                if ismember(params{p}, {'Inputs', 'Outputs', 'VariantControl', 'VariantControlMode', 'LabelModeActiveChoice', 'NumPorts', 'FrameSettings', 'Port', 'NumInputPorts', 'NumOutputPorts', 'BlockChoice', 'ShowPortLabels', 'MemberBlocks', 'InitialConditionSource', 'Permissions', 'Parameters'})
                    %these exceptions are mostly to not ruin the
                    %structure of the model, like mux/demux, but also
                    %because they may trigger MATLAB hard crashes
                    continue
                end
                old_param = get_param(curr_block, params{p});
                if isnumeric(old_param)
                    set_param(curr_block, params{p}, 17);
                elseif isnumeric(str2num(old_param))
                    set_param(curr_block, params{p}, '17');
                elseif ischar(old_param)
                    set_param(curr_block, params{p}, '');
                end
            catch ME
            end
        end



            
            
        if tmp_success
            %here, we can actually steal the original values
            params = tmp_params;

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
                    if ~ismember(ME.identifier, {'Simulink:Libraries:FailedToLoadLibraryForBlock' 'Simulink:DataType:DataTypeObjectNotInScope' 'MATLAB:class:InvalidHandle' 'Simulink:CustomCode:TokenizeError'})
                        rethrow(ME)
                    end
                end
                try
                    set_to = get_param(tmp_block, params{p});
                    if strcmp(params{p}, 'InitialCondition') || strcmp(params{p}, 'Gain')
                        set_to = '-17';
                    end
                    set_param(curr_block, params{p}, set_to)
                catch ME
                    try
                        if strcmp(ME.identifier, 'Simulink:blocks:LookupMismatchedParams')
                            set_param(curr_block, params{p}, '[ ]')
                        end
                    catch ME
                    end
                    %there is too many other to catch and handle
                    %just ignore model breaking dialog parameter changes
                end
            end
            
            % Clean up: Remove tmp block
            delete_block(tmp_block_path)
        end
    end
    %fclose(fileID);
    %disp("Dialog Parameters done")
end
