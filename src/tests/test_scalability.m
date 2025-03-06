%runs script over a bunch of models
%tests error-free-ness and runtime
%compares model metrics before and after anonymization


%test without unlinking library blocks for problematic models
function test_scalability()
    bdclose('all')
    csvFile = 'results_scalability.csv';
    csvData = readCsv(csvFile);
    warning('off', 'all');
    args = {...
        'removemasks',            1, ...
        'removelibrarylinks',     0, ...
        'removesignalnames',      1, ...
        'removedocblocks',        1, ...
        'removeannotations',      1, ...
        'removedescriptions',     1, ...
        'removeblockcallbacks',   1, ...
        'removemodelinformation', 1, ...
        'removecolorblocks',      1, ...
        'removecolorannotations', 1, ...
        'removedialogparameters', 1, ...
        'removefunctions',        1, ...
        'removepositioning',      1, ...
        'removesizes',            1, ...
        'renameblocks',           0, ...
        'renameconstants',        1, ...
        'renamegotofromtag',      1, ...
        'renamedatastorename',    1, ...
        'renamearguments',        1, ...
        'renamefunctions',        1, ...
        'hidecontentpreview',     1, ...
        'hideportlabels',         1, ...
        'sfcharts',               1, ...
        'sfports',                1, ...
        'sfevents',               1, ...
        'sfstates',               1, ...
        'sfboxes',                1, ...
        'sffunctions',            1, ...
        'sflabels',               1, ...
        'removemodelreferences',  0, ...
        'recursemodels',          1, ...
        'completeModel',          1};
    models = find_models("C:\work\data\SLNET");
    runLoop(models, csvData, csvFile, args);
end


function csvData = runLoop(models, csvData, csvFile, args)
    for m = 3051:length(models)
        rng(m)
        if height(csvData) >= m && csvData(m,:).Blocks_before == csvData(m,:).Blocks_after && csvData(m,:).Signals_before == csvData(m,:).Signals_after
            continue
        end

        loadable = 0;
        bdclose('all')
        model = models(m);
        fprintf("%i %s\n", m, model.name)
        
        
        try
            model_path = [model.folder filesep model.name];
            new_model_path = ['C:\tmp\obfmodels\o' num2str(m) model.name(end-3:end)];
            copyfile(model_path, new_model_path)
            sys = load_system(new_model_path);

            %clean up model for taking accurate measurements:
            %delete DocBlocks
            %look inside of read-protected Blocks
            %delete Masks that prevent looking into read-protected Blocks
            cleanup(sys)
            cleanup(sys)
            cleanup(sys)


            save_system(sys, new_model_path, 'SaveDirtyReferencedModels', 'on')
            bdclose('all')
            sys = load_system(new_model_path);
            [blocks_before, signals_before] = compute_metrics(sys);
            loadable = 1;
        catch ME
            csvData = add_to_table(csvData, csvFile, {m, model_path, '', loadable, NaN, NaN, NaN, NaN, NaN}, m);
            continue %model is broken
        end
        sys = get_param(sys, 'Name');
        

        argsmf = [args 'sysfolder' model.folder];
        tic;
        addpath C:\work\Obfuscate-Model\src
        SMOKE(sys, [], argsmf{:});
        time = toc;
        try
            sys = try_save(new_model_path, model, sys);
            [blocks_after, signals_after] = compute_metrics(sys);
        catch ME
            %handle models with broken PreSaveFcn/PostSaveFcns
            s = get_param(sys, 'handle');
            blocks = find_system(s, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants');
            for b = 1:length(blocks)
                try
                    set_param(blocks(b), 'PreSaveFcn', '')
                    set_param(blocks(b), 'PostSaveFcn', '')
                catch ME
                    
                end
            end
            sys = try_save(new_model_path, model, sys);
            [blocks_after, signals_after] = compute_metrics(sys);
        end

        if signals_before ~= signals_after
            disp(111111111111111111)
        end
        csvData = add_to_table(csvData, csvFile, {m, model_path, new_model_path, loadable, time, blocks_before, blocks_after, signals_before, signals_after}, m);
    end
end

function [blocks, signals] = compute_metrics(sys)
    blocks = length(find_system(sys, 'LookUnderMasks', 'all', 'Variants', 'AllVariants'));
    signals = length(find_system(sys, 'FindAll', 'on', 'LookUnderMasks', 'all', 'Variants', 'AllVariants', 'Type', 'Line'));
end

function sys = try_save(new_model_path, model, sys)
    obf_new_model_path = [new_model_path(1:end-4) '_obf' model.name(end-3:end)];
    save_system(sys, obf_new_model_path, 'SaveDirtyReferencedModels', 'on')
    bdclose('all')
    sys = load_system(obf_new_model_path);
end

function cleanup(sys)
    try
        set_param(sys, 'Lock', 'off');
    end
    removeMasks(sys)
    %sometimes masks need to be removed before read-protection can
    %be applied
    %read-protected blocks are not found in original model!
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants');
    for j=1:length(blocks)
        try
            set_param(blocks(j), 'Lock', 'off');
        end
        try
            set_param(blocks(j), 'Permissions', 'ReadWrite')
        end
    end
    %docblocks would be counted, as well
    delete_block(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'SubSystem', 'MaskType', 'DocBlock'))
end

function table = add_to_table(table, filename, new_data, row_number)
    table(row_number,:) = new_data;
    cd('C:\work\Obfuscate-Model\src\tests')
    writetable(table, filename);
end

function models = find_models(path)
    models = vertcat(vertcat(dir(fullfile(path, strcat('**',filesep,'*.slx')))), vertcat(dir(fullfile(path, strcat('**',filesep,'*.mdl')))));
end

function csvData = readCsv(filename)
    if exist(filename, 'file') ~= 2
        % File does not exist, create a new one with the expected schema
        header = {'ID', 'ModelPath', 'NewPath', 'Loadable', 'Time', 'Blocks_before', 'Blocks_after', 'Signals_before', 'Signals_after'};
        % Convert the header to a table and write it to a CSV file
        writetable(cell2table(header), filename, 'WriteVariableNames', false);
        disp('CSV-File did not exist. Created a new file with the expected schema.');
        csvData = readtable(filename);
        csvData.ModelPath = string(csvData.ModelPath);
        csvData.NewPath = string(csvData.NewPath);
        return
    end

    csvData = readtable(filename);
end
