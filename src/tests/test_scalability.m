%runs script over a bunch of models
%tests error-free-ness and runtime
%compares model metrics before and after


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
    for m = 1:length(models)

        model = models(m);
        fprintf("%i %s\n", m, model.name)
        close_system(model.name(1:end-4), 0)
        try
            model_path = [model.folder filesep model.name];
            sys = load_system(model_path);
            metric_before = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
            loadable = 1;
        catch ME
            loadable = 0;
            csvData = append_to_table(csvData, csvFile, {m, model_path, loadable, 0, NaN, NaN, NaN, NaN, NaN});
            continue %model is broken
        end
        sys = get_param(sys, 'Name');
        

        argsmf = [args 'sysfolder' model.folder];

        if strcmp(get_param(sys, 'Lock'), 'on')
            time = NaN;
            locked = 1;
            success = 0;
            metric_after = NaN;
            saveable = NaN;
        else
            tic;
            obfuscateModel(sys, [], argsmf{:});
            time = toc;
            locked = 0;
            success = 1;
            metric_after = length(find_system(sys, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Variants', 'AllVariants'));
            try
                save_system(sys, ['C:\tmp\obfmodels\' model.name(1:min(end-4, 52)) num2str(m) model.name(end-3:end)], 'SaveDirtyReferencedModels', 'on')
                saveable = 1;
            catch ME
                saveable = 0;
                if ~ismember(ME.identifier, {'Stateflow:studio:LibrarySaveAsWhileModelOpenError' 'Simulink:Commands:SaveModelCallbackError' 'Simulink:SLX:PartHandlerError'})
                    rethrow(ME)
                end
            end
        end


        csvData = append_to_table(csvData, csvFile, {m, model_path, loadable, success, saveable, time, metric_before, metric_after, locked});
        bdclose('all')
    end
end

function new_table = append_to_table(old_table, filename, new_data)
    new_data = cell2table(new_data, 'VariableNames', {'ID', 'ModelPath', 'Loadable', 'Success', 'Saveable', 'Time', 'Metrics_before', 'Metrics_after', 'Locked'});
    new_table = [old_table; new_data];
    writetable(new_table, filename);
end

function models = find_models(path)
    models = vertcat(vertcat(dir(fullfile(path, strcat('**',filesep,'*.slx')))), vertcat(dir(fullfile(path, strcat('**',filesep,'*.mdl')))));
end

function csvData = readCsv(filename)
    if exist(filename, 'file') ~= 2
        % File does not exist, create a new one with the expected schema
        header = {'ID', 'ModelPath', 'Loadable', 'Success', 'Saveable', 'Time', 'Metrics_before', 'Metrics_after', 'Locked'};
        % Convert the header to a table and write it to a CSV file
        writetable(cell2table(header), filename, 'WriteVariableNames', false);
        disp('CSV-File did not exist. Created a new file with the expected schema.');
    end

    csvData = readtable(filename);
end
