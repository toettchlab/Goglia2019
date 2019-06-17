function x = interpnans(x)
% Interpolate between NaN entries in a vector
% This is important for the peak finding algorithm to work, as far as I can
% tell...

x = x(:);

nanx = isnan(x);

% you can also interpolate between nans at beginning & end by ad
ifirst = find(~nanx, 1, 'first');
ilast = find(~nanx, 1, 'last');
x = [x(ifirst); x; x(ilast)];

% this is a freaking beautiful solution for interpolating internal NaNs
nanx = isnan(x);
t    = 1:numel(x);
x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));

% truncate the additional non-NaN values you added at beginning and end
x = x(2:end-1);
