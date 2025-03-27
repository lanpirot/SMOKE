function removeModelInformation(sys)
% REMOVEMODELINFORMATION Reset the model information found in
% Model Properties > Main and Model Properties > History. The model must be
% saved in order for some changes to take effect (i.e., LastModifiedBy data).

    sys = get_param(sys, 'handle');
    name = 'user';

    % Change info
    set_param(sys, 'ModifiedByFormat', name); % Changes LastModifiedBy also, but only after saving
    set_param(sys, 'Creator', name);
    set_param(bdroot,'Created', datestr(datetime("now"), 31)) % Changes LastModifiedDate also, but only after saving
    set_param(sys, 'ModifiedComment', '');
    set_param(sys, 'ModifiedHistory', '');
    set_param(sys, 'ModelVersionFormat', '1.0'); % Changes ModelVersion also, but only after saving
    try
        set_param(sys, 'ExtraOptions', '');
    catch ME
    end
end