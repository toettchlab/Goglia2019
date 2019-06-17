function x_bin = binarize_jt(x, bx)

x = x(:);
bx = round(bx);

x_bin = zeros(size(x));

for i = 1:size(bx,1)
    x_bin(bx(i,1):bx(i,2)) = 1;
end

x_bin = x_bin > 0;
