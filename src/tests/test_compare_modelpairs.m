%runs script over a bunch of models
%tests whether an obfuscated model outputs the same as before, and is
%similarly simulatable, compilable


function test_compare_modelpairs()
    bdclose('all')
    warning('off', 'all');
    tableBefore = readtable('results_scalability.csv');
    models = find_models(tableBefore);

    csvAfter = 'results_compare.csv';
    if exist(csvAfter, 'file') ~= 2
        tableAfter = tableBefore;
        tableAfter.OrigCompilable = NaN(height(tableAfter), 1);
        tableAfter.ObfCompilable = NaN(height(tableAfter), 1);
        writetable(tableAfter, csvAfter);
        disp('CSV-File did not exist. Created a new file from previous tests.');
    else
        tableAfter = readtable(csvAfter);
    end
    runLoop(models, tableAfter, csvAfter);
end

function runLoop(models, table, csvFile)
    c_same = 0;
    c_diff = 0;
    for m = 1:length(models)
        if ~isnan(table{m, 'OrigCompilable'}) && ~isnan(table{m, 'ObfCompilable'})
            continue
        end
        comp_orig = is_compilable(models(m).original_file);
        comp_obf = is_compilable(models(m).obf_file);

        table{m, 'OrigCompilable'} = comp_orig;
        table{m, 'ObfCompilable'} = comp_obf;
        writetable(table, csvFile)
        c_same = c_same + double(comp_orig == comp_obf && comp_orig);
        c_diff = c_diff + double(comp_orig ~= comp_obf);
        fprintf('%i %i %i\n', m, c_same, c_diff)

    end
end


function compilable = is_compilable(file)
    bdclose('all')
    compilable = 0;
    sys = load_system(file);
    model_name = get_param(sys, 'name');
    cd 'C:\work\Obfuscate-Model\src\tests\tmp'
    try
        eval([model_name, '([],[],[],''compile'');']);
        compilable = 1;
        try
            while 1
                eval([model_name, '([],[],[],''term'');']);
            end
        catch
        end
    catch
    end
    cd '..'
end


        % output_orig = get_simoutput(models(m).original_file);
        % output_obf = get_simoutput(models(m).obf_file);
        % [simulatable, output_comparison] = compare_outputs(output_orig, output_obf);
function [sim_output] = get_simoutput(path)
    sim_output = [];
    try
        bdclose('all')
        sys = load_system(path);
        sys_name = get_param(sys, 'name');
        sm = simulation(sys_name);
        step(sm, 10)
        sim_output = sm.SimulationOutput;
    catch ME
        rethrow(ME)
    end
end

function [simulatable, output_comparison] = compare_outputs(o1, o2)
    
end

function modelpaths = find_models(table)
    modelpaths = struct('table_row',{}, 'original_file',{}, 'obf_file',{});
    for m=1:height(table)
        if table{m, 'Saveable'} ~= 1
            continue
        end
        modelpath.table_row = m;
        modelpath.original_file = table{m, 'NewPath'}{1};
        modelpath.obf_file = [modelpath.original_file(1:end-4) '_obf' modelpath.original_file(end-3:end)];
        modelpaths(end + 1) = modelpath;
    end
end
