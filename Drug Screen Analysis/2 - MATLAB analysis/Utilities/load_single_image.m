function [IM_H2B IM_ERK] = load_single_image(well, p)
im_path = p.im_path;
nT      = p.nT;

%% Get image name
imname = [im_path '\' well.fname(1:end-4)];

IM_ERK = zeros(512, 512);
IM_H2B = zeros(512, 512);

%% Load for all timepoints
k = 1;

IM_ERK = imread(imname, (k-1)*2+1);
IM_H2B = imread(imname, k*2);

