function r_cn = get_overall_NC_ratio(well, p, toPlot)
% function r_cn = get_overall_NC_ratio(well, p, toPlot)

%% Parameters handling
if nargin < 3 || isempty(toPlot)
    toPlot = 0;
end

im_path = p.im_path;
nT = p.nT;
min_H2B_intensity = p.min_H2B_intensity;
min_Erk_intensity = p.min_Erk_intensity;
bkgd_Erk = p.bkgd_Erk;

%%
for k = 1:length(well)
    file = [im_path '\' well(k).fname(1:end-4)];
    nT   = length(well(k).t);
    r_cn(:,k) = im_nuc_cyt_ratio(file, nT, min_H2B_intensity, min_Erk_intensity, bkgd_Erk, toPlot);
    fprintf('.')
end
fprintf('\n')
