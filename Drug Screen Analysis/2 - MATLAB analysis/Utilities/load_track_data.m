function well = load_track_data(trackPath)
fnames = dir([trackPath '\*.txt']);

for i = 1:length(fnames)
    tmp = jt_import_from_trackmate([trackPath '\' fnames(i).name]); 
    tmp.fname = fnames(i).name; 
    well(i) = tmp; 
end

clear tmp