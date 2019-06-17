function well = jt_import_from_trackmate(logfile, MAX_NANS)
% function well = jt_import_from_trackmate(logfile, max_missing_timepoints)
% 
% Imports a well's worth of data from a file, excluding any tracks that
% missed more than max_missing_timepoints.
% 
% example:
% well = jt_import_from_trackmate('1_1_1 tracks_auto.txt');

%% Parameter parsing
% Get rid of tracks that are too short - i.e. that miss more
% than MAX_NANS total timepoints.
if nargin < 2 || isempty(MAX_NANS)
    MAX_NANS = 10;
end

%% Import data from the TrackMate logfile
D = importdata(logfile);

%% Load all tracks
all_tracks = D.data(:,2); % The unique ID for each tracked cell
all_frames = D.data(:,3); % The frame number at which a track was spotted
all_I1     = D.data(:,7); % I1 is the intensity from the KTR channel
all_I2     = D.data(:,8); % I2 is the intensity from the H2B channel
all_x      = D.data(:,4); % x is the x-position of the nucleus
all_y      = D.data(:,5); % y is the y-position of the nucleus
all_t      = all_frames;  % This can be ignored - it will be overwritten by 'correct' delta-t between frames

%% Process tracks
u_tracks   = unique(all_tracks);
u_tracks   = u_tracks(~isnan(u_tracks));

for i = 1:length(u_tracks)
    track(i).label = u_tracks(i);
    ii = find(all_tracks == u_tracks(i));
    track(i).x     = all_x(ii);
    track(i).y     = all_y(ii);
    track(i).t     = all_t(ii);
    track(i).i1    = all_I1(ii);
    track(i).i2    = all_I2(ii);
    track(i).frame = all_frames(ii);
    if ~mod(i,20)
        fprintf('.')
    end
end
fprintf('\n')

%%
nF = max(all_frames)+1;
nC = length(track);
zd = nan*ones(nF, nC);
well.t  = zd;
well.i1 = zd;
well.i2 = zd;
well.x  = zd;
well.y  = zd;

for i = 1:nC
    ii = (track(i).frame)+1;
    well.t(ii,i) = track(i).t;
    well.x(ii,i) = track(i).x;
    well.y(ii,i) = track(i).y;
    well.i1(ii,i) = track(i).i1;
    well.i2(ii,i) = track(i).i2;
    
    if ~mod(i,20)
        fprintf('.')
    end
end
fprintf('\n')

%% QC
% Get rid of tracks that are too short - i.e. that miss more
% than MAX_NANS total timepoints.
num_nans = sum(isnan(well.t));

i_keep = find(num_nans < MAX_NANS);

well.t  = well.t(:,i_keep);
well.i1 = well.i1(:,i_keep);
well.i2 = well.i2(:,i_keep);
well.x  = well.x(:,i_keep);
well.y  = well.y(:,i_keep);

