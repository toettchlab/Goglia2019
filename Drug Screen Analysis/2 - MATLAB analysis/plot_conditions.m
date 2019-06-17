%% Set path variables to the data analysis package
path(pathdef)
addpath('.\Utilities', '-begin');

%% Initialize some useful parameters
% get # of wells analyzed
nWells = length(well);

% get name for each well "condition"
for i = 1:length(well)
    [a b] = strtok(well(i).fname, '.');
    condNames{i} = a;
end

%% Plot spatial positions of cells in each well

for i = 1:nWells
    figure(1),clf
    plot(well(i).x, well(i).y, '.')
    hold on
    plot(well(i).x(1,:), well(i).y(1,:), 'o')
    set(gca, 'ydir', 'reverse')
    title(sprintf('well %d', i))
    axis equal
    title(sprintf('%s - tracked nuclei over time', condNames{i}))
    pause
end

%% Plot individual cell trajectories + identified pulses

for i = 1:length(well)
    for j = 1:size(well(i).i1fold,2)
        figure(1),clf
        set(gcf, 'position', [300 308 538 233])
        plotpeaks_jt(well(i).i1fold(:,j), ...
                     well(i).PeakTimes{j}, ...
                     well(i).PeakWidths{j}, ...
                     well(i).PeakProminences{j}, ...
                     well(i).PeakWindows{j})
        set(gca, 'ylim', [-0.1 1.1], 'xlim', [0 length(well(i).t)])
        xlabel('time (frame)'), ylabel('Erk activity')
        title(sprintf('%s cell %d', condNames{i}, j))
        pause
    end
end

%% Plot 30 cells at random from the dataset as a heat-map

Nsamples = 30;

% Initialize figure
figure(1),clf
set(gcf, 'position', [181 228 394 366])

for i = 1:length(well)
    Nc = size(well(i).i1fold,2);
    if Nc >= Nsamples
        ii = randperm(Nc, Nsamples);
    else
        ii = 1:Nc;
    end
    imagesc(well(i).i1fold(:,ii)')
    name = sprintf('%s', condNames{i});
    title(name, 'interpreter', 'none')
    axis square
    drawnow
    set(gca, 'clim', [0.05 0.55])
    drawnow
    pause
end

%% Plots
plot_variables = {'mean_r_cn'
                  'mean_npulses'
                  'mean_amp'
                  'mean_ton'
                  'mean_tot_dist'};

clear y
ii = 1:length(well);
for i = 1:length(plot_variables)
    y(:,i) = [PS.(plot_variables{i})];
end

for i = 1:length(plot_variables)
    bar(y(ii,i))
    set(gca, 'xtick', 1:length(well), ...
             'xticklabel', condNames(ii), ...
             'xticklabelrotation', 45, ...
             'TickLabelInterpreter','none', ...
             'xlim', [0 length(well)+1  ])
    ylabel(plot_variables(i), 'interpreter', 'none')
    pause
end
