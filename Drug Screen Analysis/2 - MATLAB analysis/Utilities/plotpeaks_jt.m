function plotpeaks_jt(x, pks, pw, pp, wx)
% make sure all are vectors
x = x(:); pks = pks(:); pw = pw(:); pp = pp(:);

% get the total # of timepoints
nT = numel(x);

% plot the data
plot(1:nT, x,'.-')

hold on

% now plot the peaks with cute little arrows pointing at them! :)
plot(pks,x(pks)*1.1,'bv','markerfacecolor','b')

% now plot the peak widths. NOTE that this assumes they are symmetric about
% the peak, which is not at all necessarily the case. they may look
% misaligned to the actual peak, but you should be able to interpret their
% width appropriately.
for i = 1:length(pw)
    % plot vertical line at peak
%     line(pks(i)*[1 1], x(pks(i))*[0 1], 'color', [1 0 0])
    line(pks(i)*[1 1], [x(pks(i)) - pp(i) x(pks(i))], 'color', [1 0 0])
    
    % plot horizontal line showing width
    line([wx(i,1) wx(i,2)], (x(pks(i))-pp(i)/2)*[1 1], 'color', [1 0.5 0.5])
%     line(pks(i)+[-pw(i)/2 pw(i)/2], (x(pks(i))-pp(i)/2)*[1 1], 'color', [1 0.5 0.5])
end
