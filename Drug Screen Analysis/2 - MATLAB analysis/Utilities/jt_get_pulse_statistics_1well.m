function pulse_stats = jt_get_pulse_statistics_1well(well, ii, MIN_PULSES)
% function pulse_stats = jt_get_pulse_statistics_1well(well, ii, MIN_PULSES)
% Get pulse stats

%% GET TOTAL ERK

%% GET THE REST OF THE QUANTITIES 

[nT nC] = size(well.i1fold(ii,:));
    
% Get # of pulses to compute frequency
pulse_stats.all_erk = zeros(1,nC); % total Erk offset per cell
pulse_stats.all_np = zeros(1,nC);  % # pulses per cell
pulse_stats.all_pp = zeros(1,nC);  % mean pulse prominence per cell
pulse_stats.all_pw = zeros(1,nC);  % mean pulse width per cell
pulse_stats.all_tbp = zeros(1,nC); % mean timing between pulses per cell

for j = 1:nC
    % Figure out which peaks you want to keep.
    ipeaks = ismember(well.PeakTimes{j}, ii);
    
    
    pulse_stats.all_erk(j) = nanmean(well.i1fold(ii,j));
    
    % Get the # of pulses
    pt = well.PeakTimes{j}(ipeaks);
    pulse_stats.all_np(j) = length(pt);

    % Get # of pulses to compute frequency
    pp = well.PeakProminences{j}(ipeaks);
    pulse_stats.all_pp(j) = mean(pp); % NOTE that mean([]) = NaN, so you get nans when pulses don't occur

    % Get the duration of on-time phases
    pw = well.PeakWidths{j}(ipeaks);
    pulse_stats.all_pw(j) = mean(pw);

    % Get the time between each pair of pulses
    pt = well.PeakTimes{j}(ipeaks);
    pulse_stats.all_tbp(j) = mean(diff(pt));

    % Get total displacement from first to last timepoint
    pulse_stats.all_tot_disp(j)     = ((well.x(ii(1),j) - well.x(ii(end),j))^2 + ...
                                       (well.y(ii(1),j) - well.y(ii(end),j))^2)^(1/2);
    % Get total path length traveled during movie!
    pulse_stats.all_tot_dist(j)     = sum(sqrt(diff(well.x(ii,j)).^2 + diff(well.y(ii,j)).^2));
end

% Get % oscillating for things that pulse more than ONCE.
pulse_stats.perc_osc = sum(pulse_stats.all_np > MIN_PULSES)/length(pulse_stats.all_np);

% NB: I think # of pulses should be zero if no pulses are detected. Other stats
% should only count for pulses (e.g. don't put a 'zero' in for amplitude if
% there were no pulses).
% pulse_stats.all_np(~pulse_stats.all_np) = nan; % if zero pulses, switch to nan so you don't bias

% for all of the below, these nanmeans don't count non-pulsing cells!

pulse_stats.mean_erk      = nanmean(pulse_stats.all_erk);
pulse_stats.mean_npulses  = nanmean(pulse_stats.all_np); 
pulse_stats.mean_amp      = nanmean(pulse_stats.all_pp);
pulse_stats.mean_ton      = nanmean(pulse_stats.all_pw);
pulse_stats.mean_tbp      = nanmean(pulse_stats.all_tbp);
pulse_stats.num_cells     = nC;
pulse_stats.mean_tot_disp = nanmean(pulse_stats.all_tot_disp);
pulse_stats.mean_tot_dist = nanmean(pulse_stats.all_tot_dist);
pulse_stats.mean_i1max    = nanmean(well.i1max);

