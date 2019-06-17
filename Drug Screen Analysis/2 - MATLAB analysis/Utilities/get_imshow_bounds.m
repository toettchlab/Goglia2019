function bounds = get_imshow_bounds(IM, cutoffs)
% function bounds = get_imshow_bounds(IM, cutoffs)
% 
% 'Cutoffs' refers to percentile cutoffs for the histogram of pixel
% intensities. 
% 
% For example:
% 
% cutoffs = [-inf inf] is the maximum scale: bounds = [0 65535].
% cutoffs = [0 1] scales to min/max pixel intensities in the image:
%                 bounds = [imin imax] where imin = min pixel intensity 
%                 and imax = max pixel intensity
% cutoffs = [-inf 0.95] leads to bounds = [0 i95] where i95 is the 
%                 intensity of the 95th %ile brightest pixel.
% 
% Example usage:
% bounds = get_imshow_bounds(IM_ERK, [-inf 0.95]);

% Get cumulative distribution of image intensities
[im_hist x] = imhist(IM, 65535);
im_hist = im_hist/sum(im_hist);
tf = cumsum(im_hist); 

% Pick bounds that 
bounds(1) = x(find(tf > cutoffs(1), 1, 'first'));
bounds(2) = x(find(tf < cutoffs(2), 1, 'last'));


