function y = perform_h_minimization(x, h)

[nT nC] = size(x);
for j = 1:nC
    y(:,j) = nan_imhmin(x(:,j), h);
end
