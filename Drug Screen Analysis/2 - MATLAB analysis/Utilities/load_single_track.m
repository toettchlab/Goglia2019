function well = load_single_track(trackPath, i)
fnames = dir([trackPath '\*.txt']);

tmp = jt_import_from_trackmate([trackPath '\' fnames(i).name]); 
tmp.fname = fnames(i).name; 
well(i) = tmp; 
