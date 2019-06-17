function y = nan_imhmin(x, h)
% imhmin for 1D real-valued "images" that can contain NaNs.
% Truncates the NaNs out, computes the minima, then adds them back in.
ii = isnan(x);
inum = find(~ii);

xnum = x(inum);
ynum = imhmin(xnum,h);
y = nan*ones(size(x));
y(inum) = ynum;
