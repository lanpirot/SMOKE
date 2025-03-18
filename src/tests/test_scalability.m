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
        'removepositioning',      0, ...
        'removesizes',            0, ...
        'renameblocks',           1, ...
        'renameconstants',        1, ...
        'renamegotofromtag',      1, ...
        'renamedatastorename',    1, ...
        'renamearguments',        1, ...
        'renamefunctions',        1, ...
        'renameStateFlow',        1, ...
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
        'customdatatypes',        1, ...
        'completeModel',          1};
    models = find_models("C:\work\data\SLNET");
    %models = find_models("/home/matlab/SLNET");
    runLoop(models, csvData, csvFile, args);
    disp('All models completely obfuscated.')
end


function csvData = runLoop(models, csvData, csvFile, args)
    metric_engine = slmetric.Engine();

    %for ii = 1:length(models)
    %    m = round(1.5^(ii-1));
    for m = 17:length(models)
        rng(m, 'twister')
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
            %new_model_path = ['/home/matlab/SMOKE/src/tests/tmp/o' num2str(m) model.name(end-3:end)];
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
            [blocks_before, signals_before] = compute_metrics(sys, new_model_path, metric_engine);
            bdclose('all')
            sys = load_system(new_model_path);
            loadable = 1;
        catch ME
            csvData = add_to_table(csvData, csvFile, {m, model_path, '', loadable, NaN, NaN, NaN, NaN, NaN}, m);
            continue %model is broken
        end
        sys = get_param(sys, 'Name');
        

        argsmf = [args 'sysfolder' model.folder];
        tic;
        SMOKE(sys, argsmf{:});
        time = toc;
        try
            sys = try_save(new_model_path, model, sys);
            [blocks_after, signals_after] = compute_metrics(sys, new_model_path, metric_engine);
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
            [blocks_after, signals_after] = compute_metrics(sys, new_model_path, metric_engine);
        end
        csvData = add_to_table(csvData, csvFile, {m, model_path, new_model_path, loadable, time, blocks_before, blocks_after, signals_before, signals_after}, m);
    end
end

function [blocks, signals] = compute_metrics(sys, model_path, metric_engine)
    blocks = find_system(sys, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants);
    blocktypes = length(unique(get_param(blocks(2:end), 'BlockType')));
    blocks = length(blocks);
    signals = length(find_system(sys, 'FindAll', 'on', 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Line'));
    subsystems = length(find_system(sys, 'LookUnderMasks', 'all', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem'));

    setAnalysisRoot(metric_engine, 'Root', get_param(sys, 'Name'))
    execute(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
    res_col = getMetrics(metric_engine, 'mathworks.metrics.CyclomaticComplexity');
    if res_col.Status == 0
        cyclo = res_col.Results(1).AggregatedValue;
    else
        cyclo = -1;
    end

    info = Simulink.MDLInfo(model_path);
    SLversion = info.SimulinkVersion;
    date = get_param(sys, 'LastModifiedDate');
    
    solver = get_param(sys, 'Solver');
    [compilable, output_data] = compile_and_run(sys);
end


function [compilable, output_data] = compile_and_run(sys)
    inits = {0, NaN};
    [compilable, output_data] = inits{:};

    model_name = get_param(sys, 'name');
    cd 'C:\work\Obfuscate-Model\src\tests\tmp'
    %cd '/home/matlab/SMOKE/src/tests/tmp/'
    try
        eval([model_name, '([],[],[],''compile'');']);
        compilable = 1;
        try
            while 1
                eval([model_name, '([],[],[],''term'');']);
            end
        catch
        end
        output_data = get_output(sys);
    catch ME
        disp(1)
    end
    cd '..'
end

function output_data = get_output(sys)
    
    try
        find_and_connect_inputs(sys)


        outputwatch = [get_param(sys, 'Name') '_watcher'];
        outputs = find_and_connect_outputs(sys, outputwatch);
        

        set_param(sys, 'StopTime', '10')
        set_param(sys, "SimulationCommand", "start")
        output_data = {};
        pause(1)
        for o = 1:outputs
            next_eval = evalin('base', [outputwatch num2str(o)]);
            output_data{end+1} = next_eval.Data(:);
        end
    catch ME    
        output_data = NaN;
        disp(1)
    end
end

function find_and_connect_inputs(sys)
    srcBlocks = find_system(sys, 'SearchDepth', 1, 'BlockType', 'Inport');
    for sb = 1:length(srcBlocks)
        srcBlock = srcBlocks(sb);
        srcLineHandles = get_param(srcBlock, 'LineHandles');
        destBlocks = get_param(srcLineHandles.Outport, 'DstPortHandle');
        dataType = get_param(srcBlock, 'OutDataTypeStr');

        generatorBlock = add_block('simulink/Sources/Sine Wave', [get_param(srcBlock, 'Parent') '/' 'MyGenerator' num2str(sb)]);
        set_param(generatorBlock, 'Amplitude', num2str(sb));
        set_param(generatorBlock, 'Frequency', num2str(sb));
        set_param(generatorBlock, 'Phase', num2str(sb));
        generatorPortHandles = get_param(generatorBlock, 'PortHandles');
        if strcmp(dataType, 'boolean')
            generatorBlock2 = add_block('simulink/Signal Attributes/Data Type Conversion', [get_param(srcBlock, 'Parent') '/' 'MyCaster' num2str(sb)]);
            set_param(generatorBlock2, 'OutDataTypeStr', 'boolean')
            add_line(get_param(generatorBlock, 'Parent'), generatorPortHandles.Outport, get_param(generatorBlock2, 'PortHandles').Inport)
            generatorPortHandles = get_param(generatorBlock2, 'PortHandles');
        end
        

        lines = get_param(srcBlock, 'LineHandles');
        delete_line(lines.Outport)
        delete_block(srcBlock)
        for db = 1:length(destBlocks)
            add_line(get_param(generatorBlock, 'Parent'), generatorPortHandles.Outport, destBlocks(db))
        end
    end
end

function outputs = find_and_connect_outputs(sys, outputwatch)
    destBlocks = find_system(sys, 'SearchDepth', 1, 'BlockType', 'Outport');
    for db = 1:length(destBlocks)
        destBlock = destBlocks(db);
        destLineHandles = get_param(destBlock, 'LineHandles');    
        srcPort = get_param(destLineHandles.Inport, 'SrcPortHandle');
        
        workspaceBlock = add_block('simulink/Sinks/To Workspace', [get_param(destBlock, 'Parent') '/' outputwatch num2str(db)]);
        set_param(workspaceBlock, 'VariableName', [outputwatch num2str(db)])
        workSpacePortHandles = get_param(workspaceBlock, 'PortHandles');
    
        
        add_line(get_param(destBlock, 'Parent'), srcPort, workSpacePortHandles.Inport);
    end
    outputs = length(destBlocks);
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
    %cd('/home/matlab/SMOKE/src/tests')
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
    csvData.ModelPath = string(csvData.ModelPath);
    csvData.NewPath = string(csvData.NewPath);
end
