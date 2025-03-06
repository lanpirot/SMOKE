function unlockModel(startSys, blocks)
    %if strcmp(get_param(sys, 'Lock'), 'on')
    %    warning('Model must be unlocked.');
    %    %set_param(sys, 'Lock', 'off')
    %    return
    %end
    try
        set_param(startSys, 'Lock', 'off');
    end
    for j=1:length(blocks)
        try
            set_param(blocks(j), 'Lock', 'off');
        end
        try
            set_param(blocks(j), 'Permissions', 'ReadWrite')
        end
    end
end