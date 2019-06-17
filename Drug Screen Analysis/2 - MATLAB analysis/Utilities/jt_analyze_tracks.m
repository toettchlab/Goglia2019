function well = jt_analyze_tracks(well, h, minp, bkgd, min_i, toPlot)

if nargin < 6 || isempty(toPlot)
    toPlot = 0;
end

%% Subtract bkgd and get rid of non-expressors
i1b = well.i1 - bkgd; % subtract background
ikeep = find(min(i1b) >= 0); % get rid of cells w/negative intensities
well.i1b = i1b(:,ikeep);

%% Get h min
% Do not keep local minima if their depth is less than 'h' (for this
% dataset, values between 0.3-1 seem to make sense).
%
% This gets rid of 'noisy' troughs than can get picked up later as peaks.
% (recall that this dataset has not yet been inverted, so what we will call
% 'peaks' ARE still troughs.
i1 = well.i1b;
[nT nC] = size(i1);

i1 = perform_h_minimization(i1, h);
i1 = -perform_h_minimization(-i1, h);
well.i1_hmin = i1;

i1 = well.i1_hmin;

%% Max divide
% Normalize each cell to its expression level!

% Max divide
i1max = max(i1);
i1 = i1./repmat(i1max, nT, 1);

% This also performs the flip: now pulses are positive, and all
% intensities go from zero to one.
i1 = 1 - i1;
well.i1max  = i1max;
well.i1fold = i1;

%%
for j = 1:nC
    % Interpolate to remove all NaN values
    dd = interpnans(i1(:,j));
    
    [pks pw pp wx] = findpeaks_jt(dd, minp, toPlot);
    ddb = binarize_jt(dd, wx);

    well.PeakTimes{j}       = pks;
    well.PeakWidths{j}      = pw;
    well.PeakProminences{j} = pp;
    well.PeakWindows{j}     = wx;
    well.Binarized(:,j)     = ddb(:);
end
