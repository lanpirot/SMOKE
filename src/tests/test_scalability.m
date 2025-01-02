%runs script over a bunch of models
%tests error-free-ness and runtime
%compares model metrics before and after anonymization


function test_scalability()
    bdclose('all')
    csvFile = 'results_scalability.csv';
    csvData = readCsv(csvFile);
    warning('off', 'all');
    args = {...
        'removemasks',            1, ...
        'removelibrarylinks',     1, ...
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
        'renameblocks',           1, ...
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
        'recursemodels',          1};
    models = find_models("C:\work\data\SLNET");
    runLoop(models, csvData, csvFile, args);
end


function csvData = runLoop(models, csvData, csvFile, args)
    for m = 20:length(models)
        bdclose('all')
        model = models(m);
        fprintf("%i %s\n", m, model.name)
        
        
        try
            model_path = [model.folder filesep model.name];
            new_model_path = ['C:\tmp\obfmodels\o' num2str(m) model.name(end-3:end)];
            sys = load_system(model_path);

            %clean up model for taking accurate measurements:
            %delete DocBlocks
            %look inside of read-protected Blocks
            %delete Masks that prevent looking into read-protected Blocks
            cleanup(sys)
            cleanup(sys)
            cleanup(sys)


            blocks_before = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
            loadable = 1;
        catch ME
            loadable = 0;
            csvData = append_to_table(csvData, csvFile, {m, model_path, '', loadable, NaN, NaN, NaN, NaN, NaN, NaN});
            continue %model is broken
        end
        sys = get_param(sys, 'Name');
        

        argsmf = [args 'sysfolder' model.folder];

        if strcmp(get_param(sys, 'Lock'), 'on')
            time = NaN;
            locked = 1;
            success = 0;
            blocks_after = NaN;
            saveable = NaN;
        else
            tic;
            addpath C:\work\Obfuscate-Model\src
            SMOKE(sys, [], argsmf{:});
            time = toc;
            locked = 0;
            success = 1;
            try
                obf_new_model_path = [new_model_path(1:end-4) '_obf' model.name(end-3:end)];
                save_system(sys, obf_new_model_path, 'SaveDirtyReferencedModels', 'on')
                bdclose('all')
                sys = load_system(obf_new_model_path);
                blocks_after = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
                copyfile(model_path, new_model_path)
                saveable = 1;
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
                obf_new_model_path = [new_model_path(1:end-4) '_obf' model.name(end-3:end)];
                save_system(sys, obf_new_model_path, 'SaveDirtyReferencedModels', 'on')
                bdclose('all')
                sys = load_system(obf_new_model_path);
                blocks_after = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
                copyfile(model_path, new_model_path)
                saveable = 1;
            end
        end


        csvData = append_to_table(csvData, csvFile, {m, model_path, new_model_path, loadable, success, saveable, time, blocks_before, blocks_after, locked});
    end
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
            set_param(blocks(j), 'Permissions', 'ReadWrite')
        catch 
        end
    end
    %docblocks would be counted, as well
    delete_block(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants', 'BlockType', 'SubSystem', 'MaskType', 'DocBlock'))
end

function new_table = append_to_table(old_table, filename, new_data)
    new_data = cell2table(new_data, 'VariableNames', {'ID', 'ModelPath', 'NewPath', 'Loadable', 'Success', 'Saveable', 'Time', 'Blocks_before', 'Blocks_after', 'Locked'});
    new_table = [old_table; new_data];
    cd('C:\work\Obfuscate-Model\src\tests')
    writetable(new_table, filename);
end

function models = find_models(path)
    models = vertcat(vertcat(dir(fullfile(path, strcat('**',filesep,'*.slx')))), vertcat(dir(fullfile(path, strcat('**',filesep,'*.mdl')))));
end

function csvData = readCsv(filename)
    if exist(filename, 'file') ~= 2
        % File does not exist, create a new one with the expected schema
        header = {'ID', 'ModelPath', 'NewPath', 'Loadable', 'Success', 'Saveable', 'Time', 'Blocks_before', 'Blocks_after', 'Locked'};
        % Convert the header to a table and write it to a CSV file
        writetable(cell2table(header), filename, 'WriteVariableNames', false);
        disp('CSV-File did not exist. Created a new file with the expected schema.');
    end

    csvData = readtable(filename);
end
