function run_analyses(paramFile)
% function run_analyses(paramFile)
% 
% Analyzes a particular dataset with the parameters of interest, found in
% the comma-separated value file paramFile. The analysis first loads cell 
% tracks from trackMate. It then performs a variety of quality control 
% analysis.
% 
% The steps can be summarized as follows:
% 
% 1. First, we check to ensure a minimum histone + Erk intensity throughout 
% each track (as well as a minimum CV of the histone intensity over time). 
% This step uses the parameters min_H2B_intensity, max_H2B_CV, and 
% min_Erk_intensity. It eliminates some tracks from further analysis and is
% carried out by the function nuclei_QC.m
% 
% 2. Next, we obtain filtered, background-subtracted, and inverted Erk
% traces to better analyze Erk activity over time. (Ideally, cells will be
% all the way 'off' in Erk activity at some timepoint so that it is easy 
% to assess the maximum possible nuclear KTR fluorescence - this helps to
% normalize each cell's activity to its expression level. This can be
% achieved by adding a MEK or EGFR inhibitor at the very end of the expt.)
% This analysis is performed by find_all_peaks.m and uses the parameters
% hmin_height and bkgd_Erk. Filtering is performed by h-minimization of
% each trajectory to remove local minima of height less than 'h' raw
% intensity units (this gets rid of spurious noisy peaks) before
% trajectories are inverted and normalized.
% 
% 3. Next, we obtain all the pulse statistics and mean cyt-nuc ratio over
% time in each well. These analyses are all saved in a structure PS
% containing fields for every subsequent analysis. The parameters that
% affect this calculation are min_prominence (the minimum amplitude
% required to call a peak) and frames_to_analyze (which allows the user to 
% restrict analysis to particular desired data frames). For nuc-cyt ratio
% calculations from each whole well, the min_H2B_intensity and 
% min_Erk_intensity parameters are also used. These analyses are carried 
% out by find_all_peaks, get_pulse_statistics, and get_overall_NC_ratio.
% 
% On my laptop, a ballpark estimate for the analysis time is:
% ~10 sec / image stack / 100 timepoints 
% 
% Input arguments are
% 
% paramFile     -   a comma-separated value file containing the parameters
%                   used for the Erk analysis pipeline
% 
% Example run:
% 
% tic
% paramFile = 'analysis_parameters.csv';
% run_analyses(paramFile)
% toc

%% Set path variables to the data analysis package
path(pathdef)
addpath([pwd '\Utilities'], '-begin');

%% Load all analysis parameters
p = load_parameters(paramFile);

%% Load track data
disp('Loading cell tracks...')
well = load_track_data(p.track_path);
disp('Done loading cell tracks.')

%% Analyze all cell-track data 
% Results in a structure of 'pulse statistics', PS.
% Measurements can be added to PS using add_measurement()
% All functions take 'p' as an input argument, which contains
% all parameters in the experiment's Excel file.

disp('Getting pulse stats...')
% Quality control over nuclear detection & tracking.
well = nuclei_QC(well, p, 0);
% Do all data processing and peak-finding
well = find_all_peaks(well, p);
% Get all the pulse statistics!
PS   = get_pulse_statistics(well, p);
% get overall ERK activity
r_cn = get_overall_NC_ratio(well, p, 0);
% combine r_cn and PS
PS = add_measurement(PS, p, r_cn, 'r_cn');
disp('Done getting pulse stats.')

%% Save results
save(p.savefile, 'PS', 'p', 'well');
