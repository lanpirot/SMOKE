%runs script over a bunch of models
%tests error-free-ness and runtime
%compares model metrics before and after


function test_compare_modelpairs()
    bdclose('all')
    csvFile = 'results_compare.csv';
    csvData = readtable(csvFile);
    warning('off', 'all');
    obf_models = find_models("C:\tmp\obfmodels");
    new_csvFile = 'results_compare.csv';
    runLoop(obf_models, csvData, new_csvFile);
end

function csvData = runLoop(obf_models, csvData, csvFile)
    models = csvData{:, 'ModelPath'};
    for m = 8920:length(models)
        if csvData{m, 'Saveable'} ~= 1 || csvData{m, 'Metrics_before'} == csvData{m, 'Metrics_after'}
            continue
        end

        model_path = models{m};
        fprintf("%i %s ", m, model_path)
        [num_blocks, simu_result] = get_comparator(model_path);

        obf_model_name = lookup_obf_model(model_path, m);
        if ~ismember(obf_model_name, {obf_models.name})
            fprintf("\n NO SAVE FOUNDNO SAVE FOUNDNO SAVE FOUNDNO SAVE FOUNDNO SAVE FOUND NO SAVE FOUND!\n")
            continue
        end
        model_path_obf = ['C:\tmp\obfmodels\' obf_model_name];
        [num_blocks_obf, simu_result_obf] = get_comparator(model_path_obf);


        if num_blocks_obf ~= num_blocks
            sys = load_system(model_path);
            obfuscateModel(sys)
            save_system(sys, ['C:\tmp\obfmodels\' obf_model_name], 'SaveDirtyReferencedModels', 'on')
            [num_blocks_obf, simu_result_obf] = get_comparator(sys);
        end
        if num_blocks_obf ~= num_blocks
            %keyboard
            fprintf('NON ALIGNMENT IN %i %s\n', m, model_path)
        else
            fprintf("      good obfuscation.\n")
        end


        csvData{m,'Metrics_before'} = num_blocks;
        csvData{m,'Metrics_after'} = num_blocks_obf;
        cd('C:\work\Obfuscate-Model\src\tests')
        writetable(csvData, csvFile);

    end
end


function [num_blocks, simu_result] = get_comparator(path)
    simu_result = [];
    num_blocks = -2;
    try
        if ischar(path)
            sys = load_system(path);
        else
            sys = path;
        end
        num_blocks = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
    catch ME
    end

    bdclose('all')
end

function model_name = lookup_obf_model(path, m)
    model_name = '';
    split_path = strsplit(path, '\');
    model_name_with = split_path{end};
    model_name_without = model_name_with(1:end-4);
    model_name = [model_name_without num2str(m) model_name_with(end-3:end)];
end


function models = find_models(path)
    models = vertcat(vertcat(dir(fullfile(path, strcat('**',filesep,'*.slx')))), vertcat(dir(fullfile(path, strcat('**',filesep,'*.mdl')))));
end
