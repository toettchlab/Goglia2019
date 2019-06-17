function PS = add_measurement(PS, p, meas, name)
% Adds a new measurement to the pulse-stats structure. The 'measurement'
% should be performed on individual cells. This function will also add a 
% mean 'measurement' per well, averaged over all single cells.

% Error handling
if size(meas,2) ~= length(PS)
    error('Measurements must be same size as PS structure.')
end

% Loop over measurements and add them in 
for i = 1:length(PS)
    PS(i).(name) = meas(:,i);
    PS(i).(['mean_' name]) = nanmean(meas(p.frames_to_analyze, i));
end

PS = orderfields(PS);