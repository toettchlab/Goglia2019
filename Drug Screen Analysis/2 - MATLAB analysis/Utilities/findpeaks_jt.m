function [pks pw pp wx] = findpeaks_jt(x, minp, toPlot)
% function [pks pw pp wx] = findpeaks_jt(x, minp, toPlot)
% 
% This function is an attempt to find peaks that fixes the weird issue
% associated with both 'prominence' and absolute height. In the case of
% prominence, things are weird because it is possible for the width of one 
% peak to overlap that of another! In the case of absolute height, the
% problem is different: amplitudes and pulse widths are gigantic because
% they erroneously assume that every pulse goes to zero in between.
% 
% So how do we solve these problems? We use prominence, but we truncate the
% region being analyzed to JUST the region around a single pulse. We
% identify these regions using *trough* finding (or peak finding on -1*x),
% and then analyze them for a single peak sequentially.
%
% To get the true peak height from each region, we actually get the heights
% from the full peak analysis (which only gives weird results for widths,
% not heights). This I believe is the best of all worlds.
% 
% This function assumes x real-valued, no NaNs. This can be done using
% interpnans(), a function I wrote to get rid of NaN values and replace
% with interpolations from preceding/following data.

if nargin < 3 || isempty(toPlot)
    % Edit this if you want to plot or not!
    toPlot = 0;
end

% Key parameter: minimum peak width!
mpw = 2;

x = x(:);      % make x a column vector
nT = numel(x); % the total # of timepoints

% loop to find the 1 peak between each pair of troughs
[~,tfs] = findpeaks(-x, 'MinPeakProminence', minp, 'MinPeakWidth', mpw, 'annotate', 'extents');

tfs = tfs(tfs > 2 & tfs < nT-1);
% Augment the troughs with the first and last timepoint. This makes sure
% that every dataset that we consider will have a beginning and end!
tfs = [1; tfs(:); nT];

% Initialize our output variables so we can add to them. Technically this
% is bad practice (since they grow with each iteration) but I am too lazy
% to do it right.
pks = [];
pw  = [];
pp  = [];
wx  = [];

% Loop over each interval.
for i = 1:length(tfs)-1
    % Start and endpoint of interval.
    istart = tfs(i);
    istop = tfs(i+1);
    
    % Find peaks only within the interval! You should just get 0 or 1 peak.
    [~,pks_i,pw_i,pp_i,wx_i] = findpeaks(x(istart:istop), 'MinPeakProminence', minp, 'MinPeakWidth', mpw, 'annotate', 'extents');
    
    % Translate peaks in time by the interval start time
    pks = [pks; pks_i(:)+istart-1];
    
    % Get the peak widths
    pw = [pw; pw_i(:)];
    
    % TO DO: Get rid of this and replace with a simple calculation.
    pp = [pp; pp_i(:)];
    
    % Get the beginning and end times for each peak
    wx = [wx; wx_i+istart-1];
end

% Get the original peak heights 
[~,~,~,pp2] = findpeaks(x,'MinPeakProminence',minp, 'MinPeakWidth', mpw);

if toPlot
    figure(1),clf
    plotpeaks_jt(x, pks, pw, pp2, wx)
    pause
end