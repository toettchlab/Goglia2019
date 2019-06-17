function pulse_stats = jt_get_pulse_statistics(, MIN_PULSES, MIN_FIRST_PEAK_TIME)
% function pulse_stats = jt_get_pulse_statistics(well)
% 
% This function gets pulse statistics from our dataset

%% INITIALIZE SOME THINGS;
nWells = length(well); % # of wells

data = well(1).i1b;
nT   = size(data,1); % # of timepoints

%% GET MEAN OFFSET
mif = nan*ones(nT,nWells);
for i = 1:nWells
    x = nanmean(well(i).i1fold,2);
    nT = length(x); % because some wells are missing the last timepoint!
    mif(1:nT,i) = x(:);
end

% Cut last row by 1 because last timepoint was left off a few wells
mif = mif(1:end-1,:);

% get the 'mean' response over time. NOTE that you could instead compare to
% just the mean of the DMSO-treated wells. Here, we are assuming that on
% average, drugs don't change the mean response.
mifmean = mean(mif,2);

% get the DIFFERENCE between the current drug & the mean response.
mifdif = mif - repmat(mifmean,1,nWells);
pulse_stats.mean_offset = nansum(mifdif);

%% GET THE REST OF THE QUANTITIES 

% Measure the # of pulses per cell
for i = 1:nWells
    data = well(i).i1fold;
    [nT nC] = size(data);
    
    % Get # of pulses to compute frequency
    pulse_stats(i).all_np = zeros(1,nC); % mean pulse timing per cell
    pulse_stats(i).all_pp = zeros(1,nC); % mean pulse prominence per cell
    pulse_stats(i).all_pw = zeros(1,nC); % mean pulse width per cell
    pulse_stats(i).all_tbp = zeros(1,nC);
    
    for j = 1:nC
        % Get the # of pulses
        pt = well(i).PeakTimes{j};
        pulse_stats(i).all_np(j) = length(pt);
        
        % Get # of pulses to compute frequency
        pp = well(i).PeakProminences{j};
        pulse_stats(i).all_pp(j) = mean(pp); % NOTE that mean([]) = NaN, so you get nans when pulses don't occur
        
        % Get the duration of on-time phases
        pw = well(i).PeakWidths{j};
        pulse_stats(i).all_pw(j) = mean(pw);
        
        % Get the time between each pair of pulses
        pt = well(i).PeakTimes{j};
        pulse_stats(i).all_tbp(j) = mean(diff(pt(pt > MIN_FIRST_PEAK_TIME)));
        
        % Get total displacement from first to last timepoint
        pulse_stats(i).all_tot_disp(j)     = ((well(i).x(1,j)-well(i).x(end,j))^2 + ...
                                           (well(i).y(1,j)-well(i).y(end,j))^2)^(1/2);
        % Get total path length traveled during movie!
        pulse_stats(i).all_tot_dist(j)     = sum(sqrt(diff(well(i).x(:,j)).^2 + diff(well(i).y(:,j)).^2));
    end
    
    % Get % oscillating for things that pulse more than ONCE.
    pulse_stats(i).perc_osc = sum(pulse_stats(i).all_np > MIN_PULSES)/length(pulse_stats(i).all_np);
    
    pulse_stats(i).all_np(~pulse_stats(i).all_np) = nan; % if zero pulses, switch to nan so you don't bias
    
    % for all of the below, these nanmeans don't count non-pulsing cells!
    pulse_stats(i).mean_npulses  = nanmean(pulse_stats(i).all_np); 
    pulse_stats(i).mean_amp      = nanmean(pulse_stats(i).all_pp);
    pulse_stats(i).mean_ton      = nanmean(pulse_stats(i).all_pw);
    pulse_stats(i).mean_tbp      = nanmean(pulse_stats(i).all_tbp);
    pulse_stats(i).num_cells     = size(well(i).i1,2);
    pulse_stats(i).mean_tot_disp = nanmean(pulse_stats(i).all_tot_disp);
    pulse_stats(i).mean_tot_dist = nanmean(pulse_stats(i).all_tot_dist);
end

