function r_cn = im_nuc_cyt_ratio(imname, nT, T_H2B, T_ERK, bkgd_Erk, to_plot)
% function r_cn = im_nuc_cyt_ratio(imname, nT, T_H2B, T_ERK, bkgd_Erk, to_plot)
% 
% This function analyzes the overall nuclear-cytosolic ratio at all 
% timepoints from an image. Cells may be heterogeneous, with some
% expressing a nuclear marker and some expressing an ERK biosensor; the
% code identifies co-expressing cells and, on aggregate, gets the differene
% between nuclear and cytosolic activity. (This is, in a sense, a proxy for
% a Western blot showing overall Erk levels.)
% 
% INPUT ARGUMENTS:
% imname        -    The image you are analyzing. This image can be a
%                    timelapse but MUST contain exactly two channels: an
%                    Erk channel (first) and a histone channel (2nd).
% nT            -    The number of timepoints in the timelapse image.
% T_H2B         -    The threshold in H2B levels used to identify nuclei
% T_ERK         -    The threshold in Erk levels used to determine whether
%                    the nucleus comes from an Erk-fluorescent cell.
% bkgd_Erk      -    the background fluor. intensity in the Erk channel
% to_plot       -    If you'd like to plot the binary masks showing nuclei
%                    and 'cytosolic' regions, set this to 1!
% 
% OUTPUT ARGUMENTS
% r_cn          -    A (nT x 1) vector containing the cytosolic-nuclear
%                    ratio averaged across all cytosolic and nuclear pixels
%                    identified by the algorithm.
% 
% Example call:
% r_cn = im_nuc_cyt_ratio('rx_scn_01.nd2.tif', 101, 600, 700, 0);
% 
% 

if nargin < 3 || isempty(T_H2B)
    T_H2B = 600;
end
if nargin < 4 || isempty(T_ERK)
    T_ERK = 700;
end    
if nargin < 5 || isempty(bkgd_Erk)
    bkgd = 270;
end
if nargin < 6 || isempty(to_plot)
    to_plot = 0;
end

r_cn = zeros(nT, 1);

for k = 1:nT
    IM_ERK = imread(imname, (k-1)*2+1);
    IM_H2B = imread(imname, k*2);
    
%     % old version - good but maybe nuclei are a bit too big
% 	  BW_nuc = imopen(IM_H2B > T_H2B & IM_ERK > T_ERK, strel('disk', 5));
%     BW_cyt = (imdilate(BW_nuc, strel('disk', 5)) - BW_nuc) > 0;
    
    % new version - smaller nuclei with a gap to the cytosol
    BW_nuc = imopen(IM_H2B > T_H2B & IM_ERK > T_ERK, strel('disk', 4));
    BW_cyt = (imdilate(BW_nuc, strel('disk', 6)) - BW_nuc) > 0;
    BW_nuc = imerode(BW_nuc, strel('disk', 2));
    BW_cyt = imerode(BW_cyt, strel('disk', 1));
    
    if to_plot
        subplot(1,2,1)
        imshow(BW_nuc)
        subplot(1,2,2)
        imshow(BW_cyt)
        pause
    end
    
    i_nuc = IM_ERK(BW_nuc);
    i_cyt = IM_ERK(BW_cyt);
    
    % Get nuclear-cytosol ratio
    r_cn(k) = mean(i_cyt - bkgd_Erk)/mean(i_nuc - bkgd_Erk);
end