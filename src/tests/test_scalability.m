%runs script over a bunch of models
%compares model metrics before and after anonymization


function test_scalability()
    SLNET_PATH = 'C:\work\data\SLNET';
    %SLNET_PATH = '/home/matlab/SLNET';
    TMP_MODEL_SAVE_PATH = 'C:\tmp\obfmodels';
    %TMP_MODEL_SAVE_PATH = '/home/matlab/SMOKE/src/tests/tmp';
    csvFile = [TMP_MODEL_SAVE_PATH filesep 'results_scalability.csv'];

    csvData = readCsv(TMP_MODEL_SAVE_PATH, csvFile);
    models = find_models(SLNET_PATH);
    runLoop(models, csvData, csvFile, TMP_MODEL_SAVE_PATH, get_args());
    disp('All models completely obfuscated.')
end


function csvData = runLoop(models, csvData, csvFile, TMP_MODEL_SAVE_PATH, args)
    warning('off', 'all');
    metric_engine = slmetric.Engine();

    for ii = 1:length(models)
        m = round(1.1^(ii-1));
    %for m = 1:length(models)
        if m > length(models)
            break
        end

        rng(m, 'twister')
        if height(csvData) >= m
            model_row = csvData(m,:);
            if model_row.Blocks_before == model_row.Blocks_after && model_row.Signals_before == model_row.Signals_after && model_row.Types_before == model_row.Types_after && model_row.Subs_before == model_row.Subs_after
                continue
            end
        end

        loadable = 0;
        bdclose('all')
        model = models(m);

        fprintf("%i %s\n", m, model.name)
        if ismember(model.name, {'host_receive.slx' 'Landing_Gear.slx' 'Landing_Gear_IP_Protect_START.slx' 'Landing_Gear_LS.slx' 'Landing_Gear_RSIM.slx' 'xtrlmod.mdl'})
            continue
        end


        try
            model_path = [model.folder filesep model.name];
            new_model_path = [TMP_MODEL_SAVE_PATH filesep 'o' num2str(m) model.name(end-3:end)];
            
            copyfile(model_path, new_model_path)
            sys = load_system(new_model_path);
            date = get_param(sys, 'LastModifiedDate');
            info = Simulink.MDLInfo(model_path);
            SLversion = info.SimulinkVersion;

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
            [blocks_bf, blocktypes_bf, signals_bf, subsystems_bf, cyclo_bf, SLversion_bf, date_bf, solver_bf, compilable_bf, output_data_bf] = compute_metrics(sys, metric_engine, date, SLversion, TMP_MODEL_SAVE_PATH);
            bdclose('all')
            sys = load_system(new_model_path);
            loadable = 1;
        catch ME
            csvData = add_to_table(csvData, csvFile, {m, model_path, '', loadable, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, '', '', '', '', '', '', NaN, NaN, NaN, '', ''}, m);
            continue %model is broken
        end
        sys = get_param(sys, 'Name');
        

        argsmf = [args 'sysfolder' model.folder];
        tic;
        SMOKE(sys, argsmf{:});
        time = toc;
        try
            sys = try_save(new_model_path, model, sys);
            info = Simulink.MDLInfo(new_model_path);
            SLversion = info.SimulinkVersion;            
            [blocks_af, blocktypes_af, signals_af, subsystems_af, cyclo_af, SLversion_af, date_af, solver_af, compilable_af, output_data_af] = compute_metrics(sys, metric_engine, datetime('now'), SLversion, TMP_MODEL_SAVE_PATH);
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
            info = Simulink.MDLInfo(new_model_path);
            SLversion = info.SimulinkVersion;
            [blocks_af, blocktypes_af, signals_af, subsystems_af, cyclo_af, SLversion_af, date_af, solver_af, compilable_af, output_data_af] = compute_metrics(sys, metric_engine, datetime('now'), SLversion, TMP_MODEL_SAVE_PATH);
        end
        [output_same, output_type_bf, output_type_af] = handle_outputs(output_data_bf, output_data_af);
        csvData = add_to_table(csvData, csvFile, {m, model_path, new_model_path, loadable, time, blocks_bf, blocks_af, blocktypes_bf, blocktypes_af, signals_bf, signals_af, subsystems_bf, subsystems_af, cyclo_bf, cyclo_af, SLversion_bf, SLversion_af, date_bf, date_af, solver_bf, solver_af, compilable_bf, compilable_af, output_same, output_type_bf, output_type_af}, m);
    end
end

function [output_same, output_type_bf, output_type_af] = handle_outputs(ob, oa)
    %if both outputs consist of NaN only     -> not same output
    %if lengths of outputs differ            -> not same output
    %if one has actual output, the other not -> not same output
    %if all outputs are equal (NaN is also equal!)->same output
    no = 'NoOutput';
    az = 'AllZeros';
    ap = 'ActualOutput';
    [output_type_bf, lb] = output_type(ob);
    [output_type_af, la] = output_type(oa);
    if strcmp(output_type_bf, no) || strcmp(output_type_af, no) || ~strcmp(output_type_bf, output_type_af) || ~isequal(lb, la)
        output_same = 0;
    elseif (strcmp(output_type_bf, ap) || strcmp(output_type_bf, az)) && (strcmp(output_type_af, ap) || strcmp(output_type_af, az)) && isequal(lb, la)
        output_same = check_each_nan_eq(ob, oa);
    elseif isequal(output_type_bf, output_type_af) && isequal(lb, la)
        output_same = 1;
    else
        error('Unexpected output types')
    end
end

function os = check_each_nan_eq(b, a)
    os = 1;
    for i = 1:length(b)
        for j = 1:length(b{i})
            if isnumeric(b{i}(j)) && isnumeric(a{i}(j)) && isnan(b{i}(j)) && isnan(a{i}(j))
                continue
            elseif ~isequal(b{i}(j), a{i}(j))
                os = 0;
                return
            end
        end
    end
end

function [o_type, l] = output_type(o)
    no = 'NoOutput';
    az = 'AllZeros';
    ap = 'ActualOutput';
    if iscell(o)
        l = length(o);
        o_type = no;
        for i = 1:l
            l(end + 1) = length(o{i});
            for j = 1:length(o{i})
                if isnumeric(o{i}(j)) && o{i}(j) == 0 && strcmp(o_type, no)
                    o_type = az;
                elseif isnumeric(o{i}(j)) && o{i}(j) ~= 0 && ~isnan(o{i}(j))
                    o_type = ap;
                end
            end
        end
    elseif isnan(o)
        o_type = no;
        l = 1;
    else
        error('Unexpected output')
    end
end

function [blocks, blocktypes, signals, subsystems, cyclo, SLversion, date, solver, compilable, output_data] = compute_metrics(sys, metric_engine, date, SLversion, TMP_MODEL_SAVE_PATH)
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
    
    try
        solver = get_param(sys, 'Solver');
    catch
        solver = 'unknown';
    end
    [compilable, output_data] = compile_and_run(sys, TMP_MODEL_SAVE_PATH);
end


function [compilable, output_data] = compile_and_run(sys, TMP_MODEL_SAVE_PATH)
    inits = {0, NaN};
    [compilable, output_data] = inits{:};

    model_name = get_param(sys, 'name');
    cd(TMP_MODEL_SAVE_PATH)
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
    end
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
    writetable(table, filename);
end

function models = find_models(path)
    models = vertcat(vertcat(dir(fullfile(path, strcat('**',filesep,'*.slx')))), vertcat(dir(fullfile(path, strcat('**',filesep,'*.mdl')))));
end

function csvData = readCsv(TMP_MODEL_SAVE_PATH, csv_filename)
    if exist(TMP_MODEL_SAVE_PATH, 'dir') ~= 7
        mkdir(TMP_MODEL_SAVE_PATH)
    end

    if exist(csv_filename, 'file') ~= 2
        % File does not exist, create a new one with the expected schema
        header = {'ID', 'ModelPath', 'NewPath', 'Loadable', 'Time', 'Blocks_before', 'Blocks_after', 'Types_before', 'Types_after', 'Signals_before', 'Signals_after', 'Subs_before', 'Subs_after', 'cyclo_before', 'cyclo_after', 'SLversion_before', 'SLversion_after', 'date_before', 'date_after', 'solver_before', 'solver_after', 'compilable_before', 'compilable_after', 'same_output', 'OutputType_before', 'OutputType_after'};
        % Convert the header to a table and write it to a CSV file
        writetable(cell2table(header), csv_filename, 'WriteVariableNames', false);
        disp('CSV-File did not exist. Created a new file with the expected schema.');
        csvData = readtable(csv_filename);
    else
         csvData = readtable(csv_filename);
    end

   
    csvData.ModelPath = string(csvData.ModelPath);
    csvData.NewPath = string(csvData.NewPath);
    csvData.SLversion_before = string(csvData.SLversion_before);
    csvData.SLversion_after = string(csvData.SLversion_after);
    csvData.date_before = string(csvData.date_before);
    csvData.date_after = string(csvData.date_after);
    csvData.solver_before = string(csvData.solver_before);
    csvData.solver_after = string(csvData.solver_after);
    csvData.OutputType_before = string(csvData.OutputType_before);
    csvData.OutputType_after = string(csvData.OutputType_after);
end

function args = get_args()
    %OPTION 1
    %sanitize and obfuscate all but links/referenced models -- this would
    %break the metrics (e.g. additional Subsystems appear, etc.), and is thus ignored
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
    %OPTION 2
    %only obfuscate, don't change semantics or break the model
    %use this: output_same = isequal(output_data_bf, output_data_af) || (isnan(output_data_bf) && isnan(output_data_af))
    % args = {...
    %     'removemasks',            0, ...
    %     'removelibrarylinks',     0, ...
    %     'removesignalnames',      1, ...
    %     'removedocblocks',        1, ...
    %     'removeannotations',      1, ...
    %     'removedescriptions',     1, ...
    %     'removeblockcallbacks',   0, ...
    %     'removemodelinformation', 1, ...
    %     'removecolorblocks',      1, ...
    %     'removecolorannotations', 1, ...
    %     'removedialogparameters', 0, ...
    %     'removefunctions',        0, ...
    %     'removepositioning',      1, ...
    %     'removesizes',            1, ...
    %     'renameblocks',           1, ...
    %     'renameconstants',        0, ...
    %     'renamegotofromtag',      0, ...
    %     'renamedatastorename',    0, ...
    %     'renamearguments',        0, ...
    %     'renamefunctions',        1, ...
    %     'renameStateFlow',        0, ...
    %     'hidecontentpreview',     1, ...
    %     'hideportlabels',         1, ...
    %     'sfcharts',               0, ...
    %     'sfports',                0, ...
    %     'sfevents',               0, ...
    %     'sfstates',               0, ...
    %     'sfboxes',                0, ...
    %     'sffunctions',            0, ...
    %     'sflabels',               0, ...
    %     'removemodelreferences',  0, ...
    %     'recursemodels',          1, ...
    %     'customdatatypes',        0, ...
    %     'completeModel',          1};
end