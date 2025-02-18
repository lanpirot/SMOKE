function removeModelReferences(blocks)
% REMOVEMODELREFERENCES Remove references to other models.


    for i = 1:length(blocks)
        
        if strcmp(get_param(blocks(i), 'BlockType'), 'ModelReference')
            try
                % Reset parameter values
                set_param(blocks(i), 'ModelNameDialog', '<Enter Model Name>');
                set_param(blocks(i), 'ModelFile', '<Enter Model Name>');
            catch ME
                if ~strcmp(ME.identifier, '')
                    rethrow(ME)
                end
            end
            try
                set_param(blocks(i), 'ModelName', '<Enter Model Name>');
            catch ME
                if ~strcmp(ME.identifier, '')
                    rethrow(ME)
                end
            end
        end
    end
end