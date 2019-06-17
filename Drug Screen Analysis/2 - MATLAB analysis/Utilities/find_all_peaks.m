function well_out = find_all_peaks(well, p)
hmin_height = p.hmin_height;
min_prominence = p.min_prominence;
bkgd_Erk = p.bkgd_Erk;
dt = p.dt;

for i = 1:length(well)
    well_out(i) = jt_analyze_tracks(well(i), hmin_height, min_prominence, bkgd_Erk, 0, 0);
    fprintf('.')
end
fprintf('\n');

for i = 1:length(well)
    well_out(i).t = (dt*(0:size(well(i).i1,1)-1)/60);
end

