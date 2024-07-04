function removeModelInformation(sys)
% REMOVEMODELINFORMATION Reset the model information found in
% Model Properties > Main and Model Properties > History. The model must be
% saved in order for some changes to take effect (i.e., LastModifiedBy data).

    sys = get_param(sys, 'handle');
    date = datestr(now, 'ddd mmm dd HH:MM:SS yyyy');
    date = reshape(date, 1, length(date));
    name = 'user';

    % Change usernames
    set_param(sys, 'ModifiedByFormat', name); % Changes LastModifiedBy also, but only after saving
    set_param(sys, 'Creator', name);

    % Change dates
    set_param(sys, 'Created', date);
    set_param(sys, 'ModifiedDateFormat', date); % Changes LastModifiedDate also, but only after saving
    set_param(sys, 'ModifiedComment', '');
    set_param(sys, 'ModifiedHistory', '');
    set_param(sys, 'ModelVersionFormat', '1.0'); % Changes ModelVersion also, but only after saving
end