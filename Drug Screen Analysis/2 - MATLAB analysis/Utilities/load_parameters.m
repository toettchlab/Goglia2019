function p = load_parameters(fname)

% Loads parameters from a file
T = readtable(fname);

for i = 1:length(T.PARAMETERS)
    if ismember(T.VALUES{i}, '0123456789+-.eEdD:')
        p.(T.PARAMETERS{i}) = str2num(T.VALUES{i});
    else
        p.(T.PARAMETERS{i}) = T.VALUES{i};
    end
end

clear T;