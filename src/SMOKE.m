function SMOKE(sys, ~, varargin)
% OBFUSCATEMODEL Obfuscate a Simulink model such that application-specific or
% company-specific details are removed.
%
%   Inputs:
%       sys         Model name.
%       parentSys   Parent model name. [Optional]
%       varargin    Parameter names and values for specifying what elements of
%                   the model are affected. [Optional]
%
%   Outputs:
%       N/A
%
%   Side Effects:
%       Modified model
%
%   Example:
%       obfuscateModel(gcs, [], {'removecolorblocks', 1})
    
    %% Input Handler
    % If no args are given, run all checks. 
    % If some args are given, only run those enabled.
    if isempty(varargin)
        default = 1;
    else
        default = 0;
    end
    
    if ~exist('parentSys', 'var')
        parentSys = [];
    end
    
    %% Manage parameters
    % Simulink
    %   Remove
    removemasks             = getInput('removemasks', varargin, default);
    removelibrarylinks      = getInput('removelibrarylinks', varargin, default);
    removemodelreferences   = getInput('removemodelreferences', varargin, 0); 
    removesignalnames       = getInput('removesignalnames', varargin, default);
    removedocblocks         = getInput('removedocblocks', varargin, default);
    removeannotations       = getInput('removeannotations', varargin, default);
    removedescriptions      = getInput('removedescriptions', varargin, default);
    removeblockcallbacks    = getInput('removeblockcallbacks', varargin, default);
    removemodelinformation  = getInput('removemodelinformation', varargin, default);
    
    removecolorblocks       = getInput('removecolorblocks', varargin, default);
    removecolorannotations  = getInput('removecolorannotations', varargin, default);
    removedialogparameters  = getInput('removedialogparameters', varargin, default);
    removefunctions         = getInput('removefunctions', varargin, default);
    removepositioning       = getInput('removepositioning', varargin, default);
    removesizes             = getInput('removesizes', varargin, default);
    removeSubsytems         = getInput('squashSubsystems', varargin, default);
    
    %   Rename
    renameblocks            = getInput('renameblocks', varargin, default); 
    renameconstants         = getInput('renameconstants', varargin, default);
    renamegotofromtag       = getInput('renamegotofromtag', varargin, default);
    renamedatastorename     = getInput('renamedatastorename', varargin, default);
    renamearguments         = getInput('renamearguments', varargin, default);
    renamefunctions         = getInput('renamefunctions', varargin, default);
    renameStflow            = getInput('renameStateFlow', varargin, default);
    
    %   Hide
    hidecontentpreview      = getInput('hidecontentpreview', varargin, default);
    hideportlabels          = getInput('hideportlabels', varargin, default);
    
    % Stateflow
    sfcharts                = getInput('sfcharts', varargin, default);
    sfports                 = getInput('sfports', varargin, default);
    sfevents                = getInput('sfevents', varargin, default);
    sfstates                = getInput('sfstates', varargin, default);
    sfboxes                 = getInput('sfboxes', varargin, default);
    sffunctions             = getInput('sffunctions', varargin, default);
    sflabels                = getInput('sflabels', varargin, default);
    
    
    % Recursion
    recursemodels           = getInput('recursemodels', varargin, default);

    % Context
    sysfolder               = getInput('sysfolder', varargin, 'No Path given');

    %Location
    completeModel           = getInput('completeModel', varargin, default);
    if completeModel
        obsStartSys = sys;
    else
        obsStartSys = gcs;
    end
    recurseSubsystems       = getInput('recurseSubsystems', varargin, default) || completeModel;

    %% Collect All Items to be Obfuscated

    if recurseSubsystems
        sd = inf;
    else
        sd = 1;
    end
    obsStartSysName = obsStartSys;
    obsStartSys = get_param(obsStartSys, 'Handle');
    sys = get_param(sys, 'Handle');
    blocks = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Block');
    lines = find_system(obsStartSys, 'FindAll', 'on', 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Line');
    datastores = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'DataStoreMemory');
    triggers = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'TriggerPort');
    subsystems = find_system(obsStartSysName, 'SearchDepth', sd-1, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem');
    annotations = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Annotation');
    docBlocks = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem', 'MaskType', 'DocBlock');
    inports = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Block', 'BlockType', 'Inport');
    gotos = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'Goto');
    constants = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'Constant');
    allArgIns   = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants,  'BlockType', 'ArgIn');
    allArgOuts  = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'ArgOut');   
    froms = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'From');
    writes = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'DataStoreWrite');
    reads  = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'DataStoreRead');
    bla = [blocks; lines; annotations];


    %% unlock model
    unlockModel(obsStartSys, blocks)

    
    %% Recurse Model References
    if ~removemodelreferences && recursemodels
        recurseModelReferences(sys, obsStartSys, varargin)
    end

    %% Perform Obfuscation
    % Remove parameters and blocks
    if removelibrarylinks
        removeLibraryLinks(blocks)
    end

    if removemasks
        removeMasks(blocks)
    end

    if removeblockcallbacks
        removeBlockCallbacks(blocks)
    end
    
    if removemodelreferences
        removeModelReferences(blocks)
    end

    if removesignalnames
        removeSignalNames(lines, blocks)
    end
    
    if removedescriptions
        removeDescriptions(bla)
    end
    
    if removedocblocks
        removeDocBlocks(docBlocks)
        blocks = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Block');
        subsystems = find_system(obsStartSysName, 'SearchDepth', sd-1, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem');
        annotations = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Annotation');
    end
    
    if removecolorannotations
        removeAnnotationColors(annotations)
    end
    
    if removeannotations
        removeAnnotations(annotations, blocks)
    end

    if removecolorblocks
        removeBlockColors(blocks)
    end
    
    if removemodelinformation
        removeModelInformation(sys)
    end

    if removedialogparameters
        removeDialogParameters(blocks)
    end

    if removefunctions
        removeFunctions(blocks)
    end
    
    removeCustomDataTypes(inports)  % will probably affect functionality

    if removeSubsytems
        if obsStartSys ~= sys
            obsStartSys = get_param(get_param(obsStartSys, 'Parent'), 'Handle');
            open_system(obsStartSys)
        end
        removeSubsystems(subsystems);
        blocks = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Block');
        subsystems = find_system(obsStartSysName, 'SearchDepth', sd-1, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem');
        if removeannotations
            annotations = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FindAll', 'on', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Annotation');
            removeAnnotations(annotations, blocks)
        end
    end    
          
    if hidecontentpreview
        hideContentPreview(subsystems);
        blocks = find_system(obsStartSys, 'SearchDepth', sd, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'MatchFilter', @Simulink.match.allVariants, 'Type', 'Block');
    end
    
    if hideportlabels
        hidePortLabels(subsystems);
    end

    if removesizes
        removeSizes(blocks)
    end

    if removepositioning
        removePositioning(blocks)
    end


    % Rename    
    if renameconstants
        renameConstants(constants)
    end
    
    if renamegotofromtag
        renameGotoTags(froms, gotos)
    end
    
    if renamedatastorename
        renameDSs(datastores, writes, reads)
    end
    
    if renamearguments
        renameArgs(allArgIns, allArgOuts);
    end
    
    if renamefunctions
        renameSimFcns(triggers);
    end
    
    if renameStflow
        renameStateflow(obsStartSys, 'sfcharts', sfcharts, 'sfports', sfports, 'sfevents', sfevents, 'sfstates', sfstates, 'sfboxes', sfboxes, 'sffunctions', sffunctions, 'sflabels', sflabels, recurseSubsystems);
    end

    if renameblocks
        renameBlocks(blocks)
    end
end