function recurseModelReferences(sys, startsys, varargin)
    refs = find_system(startsys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'ModelReference');
    if ~iscell(refs)
        refs = {refs};
    end
    if ~isempty(refs)
        for i = 1:length(refs)
            try
                modelName = get_param(refs{i}, 'ModelName');
            catch ME
                if strcmp(ME.identifier, 'Simulink:protectedModel:ProtectedModelGetParamModelName')
                    modelName = get_param(refs{i}, 'ModelFile');
                else
                    rethrow(ME)
                end
            end
            try
                load_system([sysfolder filesep modelName]);
                obfuscateModel(modelName, sys, varargin{:});
                save_system(modelName);
                Simulink.ModelReference.refresh(refs{i});
                close_system(modelName);
            catch ME %no referenced model name is given, we do not just try out any name -- as the file is unknown, we also cannot obfuscate it
                continue
            end
            
        end
    end
end