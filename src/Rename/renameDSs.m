function renameDSs(datastores, writesOrig, readsOrig)
% RENAMEDSS Give all Data Store Memory, Read, and Write blocks with generic
   
    renamed_writes = [];
    renamed_reads = [];
    
    for dsm = 1:length(datastores)
        datastorename  = get_param(datastores(dsm), 'DataStoreName');
        writes = writesOrig(strcmp(get_param(writesOrig, 'DataStoreName'), datastorename));
        reads = readsOrig(strcmp(get_param(readsOrig, 'DataStoreName'), datastorename));
        
        % Memory
        for i = 1:2^16
            ds_name = ['DataStore' num2str(i)];
            if ~ismember(ds_name, get_param(datastores, 'DataStoreName'))
                break
            end
        end
        set_param(datastores(dsm), 'DataStoreName', ds_name);
 
        % Write
        if ~isempty(writes)
            for w = 1:length(writes)
                renamed_writes(end+1) = get_param(writes(w), 'Handle');
                set_param(writes(w), 'DataStoreName', ds_name);
            end
        end
        
        % Read
        if ~isempty(reads)
            for r = 1:length(reads)
                renamed_reads(end+1) = get_param(reads(r), 'Handle');
                set_param(reads(r), 'DataStoreName', ds_name);
            end
        end
    end
    
    % Fix dangline reads/writes
    dangling_writes = writesOrig;
    dangling_reads  = readsOrig;
    dangling_writes = setdiff(dangling_writes, renamed_writes);
    dangling_reads  = setdiff(dangling_reads, renamed_reads);
    
    for dw = 1:length(dangling_writes)
        dsm = dsm + 1;
        set_param(dangling_writes(dw), 'DataStoreName', ['DataStore' num2str(dsm)]);
    end
    
    for dr = 1:length(dangling_reads)
        dsm = dsm + 1;
        set_param(dangling_reads(dr), 'DataStoreName', ['DataStore' num2str(dsm)]);
    end
end