function test_parameters(paramFile, track_to_test)
% function test_parameters(paramFile, track_to_test)
% This function tests a candidate set of parameters in paramFile, showing
% key plots that enable the user to assess whether the parameters chosen
% are good for processing that particular dataset.
% 
% The function only loads a single image + track file, so it runs
% relatively quickly. It first shows parameters associated with Erk and
% histone masking, estimates the Erk background intensity value, and then
% plots h-minimum-filtered single-cell trajectories with all pulses 
% annotated.
% 
% These plots enable the user to test a set of parameters on a single 
% image before applying them globally to an entire experiment using
% run_analyses.m
% 
% Input arguments are
% 
% paramFile     -   a comma-separated value file containing the parameters
%                   used for the Erk analysis pipeline
% track_to_test -   if you want to test parameters on a particular
%                   image/track pair, you can specify its index here.
% 
% Example use:
% paramFile = 'drug_screen_params.csv';
% find_parameters(paramFile)

%% Set path variables to the data analysis package
path(pathdef)
addpath([pwd '\Utilities'], '-begin');

if nargin < 2 || isempty(track_to_test)
    track_to_test = 1; % Just load the first track.
end

%% Load all analysis parameters
p = load_parameters(paramFile);

%% Load track data
disp('Get H2B/Erk parameters...')

well = load_single_track(p.track_path, track_to_test);
well = well(track_to_test);

[IM_H2B IM_ERK] = load_single_image(well, p);

fprintf('Current parameters:\n')
fprintf('min_H2B_intensity: %g\n', p.min_H2B_intensity)
fprintf('max_H2B_CV: %g\n', p.max_H2B_CV)
fprintf('min_Erk_intensity: %g\n', p.min_Erk_intensity)

%%

H2B_mean = mean(well.i2);
H2B_CV   = std( well.i2)./mean(well.i2);
Erk_mean = mean(well.i1);

ikeep =    find(H2B_mean > p.min_H2B_intensity   & ...
            H2B_CV       < p.max_H2B_CV          & ...
            Erk_mean     > p.min_Erk_intensity);

%%
BW = IM_H2B > p.min_H2B_intensity & ...
     IM_ERK > p.min_Erk_intensity;
BW = imopen(BW, strel('disk', 5));    

BW_RGB(:,:,1) = 255*bwmorph(BW, 'remove');
BW_RGB(:,:,2) = 0;
BW_RGB(:,:,3) = 0;

bounds = get_imshow_bounds(IM_ERK, [0 0.95]);
G_ERK = mat2gray(IM_ERK, bounds);
bounds = get_imshow_bounds(IM_H2B, [0 0.95]);
G_H2B = mat2gray(IM_H2B, bounds);

%%
figure(1),clf
set(gcf, 'position', [161 44 488 431])
IMov = imoverlay(G_ERK, bwmorph(BW, 'remove'), [1 0 0]);
imshow(IMov)
% hold on
% imshow(BW_RGB)
figure(2),clf
set(gcf, 'position', [161 44 488 431])
IMov = imoverlay(G_H2B, bwmorph(BW, 'remove'), [1 0 0]);
imshow(IMov)
% hold on
% imshow(BW_RGB)
figure(3),clf
set(gcf, 'position', [657 44 244 431])
subplot(2,1,1)
plot(H2B_mean, H2B_CV, '.', ...
     H2B_mean(ikeep), H2B_CV(ikeep), '.')
xlabel('mean of H2B intensity')
ylabel('CV of H2B intensity')

subplot(2,1,2)
plot(H2B_mean, Erk_mean, '.', ...
     H2B_mean(ikeep), Erk_mean(ikeep), '.')
xlabel('mean of H2B intensity')
ylabel('mean of Erk intensity')

tmp = get_imshow_bounds(IM_ERK, [0.05 inf]);
good_background = tmp(1);

fprintf('A good ERK background intensity is probably %g.\n', good_background);

disp('Press any key to continue to pulse analysis parameters')
pause

%% now check h-min and prominence measure
close all

well = nuclei_QC(well, p, 0);
well = find_all_peaks(well, p);

%%
figure(1),clf
set(gcf, 'position', [1074 204 621 472])

for j = 1:size(well.i1fold,2)
    figure(1),clf
    subplot(2,1,1)
    plot(well.i1b(:,j))
    set(gca, 'xlim', [0 length(well.t)])
    xlabel('time (frame)'), ylabel('Raw KTR trace')
    subplot(2,1,2)
    plotpeaks_jt(well.i1fold(:,j), ...
                 well.PeakTimes{j}, ...
                 well.PeakWidths{j}, ...
                 well.PeakProminences{j}, ...
                 well.PeakWindows{j})
    set(gca, 'ylim', [-0.1 1.1], 'xlim', [0 length(well.t)])
    xlabel('time (frame)'), ylabel('Erk activity')
    title(sprintf('cell %d', j))
    pause
end
