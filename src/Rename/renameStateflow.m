function renameStateflow(startSys, varargin)
% RENAMESTATEFLOW Rename chart blocks and their data to generic names.
    sys = bdroot(startSys);

    sys = get_param(sys, 'handle');
    % If not args are given, run all checks. 
    % If some args are given, only run those enabled.
    if isempty(varargin)
        default = 1;
    else
        default = 0;
    end

    sfcharts = getInput('sfcharts', varargin, default);
    sfports  = getInput('sfports', varargin, default);
    sfevents = getInput('sfevents', varargin, default);
    sfboxes  = getInput('sfboxes',  varargin, default);
    sfstates = getInput('sfstates', varargin, default);
    sffunctions = getInput('sffunctions', varargin, default);
    sflabels = getInput('sflabels', varargin, default);
    

    rt = sfroot;
    model = rt.find('-isa', 'Simulink.BlockDiagram', '-and', 'Name', bdroot(get_param(sys, 'Name')));
    charts = model.find('-isa', 'Stateflow.Chart');

    for i = 1:length(charts)
        c = charts(i);

        if ~startsWith(c.Path, getfullname(startSys))
            continue
        end

        % Rename charts
        if sfcharts
            c.Name = ['StateflowChart' num2str(i)];
        end
        
        % Rename ports
        if sfports
            input_data = c.find('-isa', 'Stateflow.Data', 'Scope', 'Input');
            for j = 1:length(input_data)
                input_data(j).Name = ['Input' num2str(j)];
            end

            output_data = c.find('-isa', 'Stateflow.Data', 'Scope', 'Output');
            for k = 1:length(output_data)
                output_data(k).Name = ['Output' num2str(k)];
            end
        end

        % Rename events
        if sfevents
            events = c.find('-isa', 'Stateflow.Event');
            for l = 1:length(events)
                events(l).Name = ['Event' num2str(l)];
            end
        end
        
        % Rename boxes
        if sfboxes
            boxes = c.find('-isa', 'Stateflow.Box');
            disp(boxes)
            for n = 1:length(boxes)
                boxes(n).Name = ['Box' num2str(n)];
            end
        end
        
        %% Rename states
        % Save parameter because it needs to be turned off
        if sfstates
            boxes = c.find('-isa', 'Stateflow.Box');
            grp = get(boxes, 'IsGrouped');

            if numel(grp) > 1
                isgrouped = cell2mat(grp);
            else
                isgrouped = grp;
            end
            set(boxes, 'IsGrouped', 0);

            states = c.find('-isa', 'Stateflow.State');
            for m = 1:length(states)
                try
                    states(m).Name = ['State' num2str(m)];
                    states(m).LabelString = ['State' num2str(m)];
                catch ME
                    if ~ismember(ME.identifier, {'Stateflow:misc:CannotChangeStatesInGroupedState'})
                        rethrow(ME)
                    end
                end
            end

            % Turn back on
            for o = 1:length(boxes)
                boxes(o).IsGrouped = isgrouped(o);
            end
        end

        %% Rename functions
        % Functions are used in transitions, etc. so its difficult to change
        if sffunctions
            sf_functions = [c.find('-isa', 'Stateflow.Function') ; c.find('-isa', 'Stateflow.SLFunction')];
            for f = 1:length(sf_functions)
                sf_functions(f).Name = ['function' num2str(f)];
            end
        end

        %% Relabel transitions
        if sflabels
            sf_transitions = c.find('-isa', 'Stateflow.Transition');
            for t = 1:length(sf_transitions)
                %disp(sf_transitions(t).LabelString)
                sf_transitions(t).LabelString = relabel(sf_transitions(t).LabelString);
                %disp(relabel(sf_transitions(t).LabelString))
            end
        end
    end
end

%remove IP information from labels
function label = relabel(label)
    % Split the string
    tokens = regexp(label, '[\(\)\[\],<>=\s]+', 'split');
    for i = 1:length(tokens)
        token = tokens{i};
        token_before = token;
        token = strrep(token,'_','');
        token = strrep(token,'-','');
        token = strrep(token,'{','');
        token = strrep(token,'}','');
        token = strrep(token,'.','');
        token = strrep(token,';','');
        token = strrep(token,'~','');

        if ~isnan(str2double(token))
            label = strrep(label, token_before, char(string(0)));
        elseif all(isstrprop(token, 'alphanum')) && strlength(token) > 1
            label = strrep(label, token_before, token_before(1:2));
        end
    end
end