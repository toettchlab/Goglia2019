function wells = nuclei_QC(wells, p, toPlot)
min_H2B_intensity = p.min_H2B_intensity;
max_H2B_CV        = p.max_H2B_CV;
min_Erk_intensity = p.min_Erk_intensity;

for i = 1:length(wells)
    H2B_mean = mean(wells(i).i2);
    H2B_CV   = std( wells(i).i2)./mean(wells(i).i2);
    Erk_mean = mean(wells(i).i1);
    
    ikeep =    find(H2B_mean > min_H2B_intensity   & ...
                    H2B_CV   < max_H2B_CV          & ...
                    Erk_mean > min_Erk_intensity);
    
	if toPlot
        subplot(2,1,1)
        plot(H2B_mean, H2B_CV, '.', ...
             H2B_mean(ikeep), H2B_CV(ikeep), '.')
        xlabel('mean of H2B intensity')
        ylabel('CV of H2B intensity')
        
        subplot(2,1,2)
        plot(H2B_mean, Erk_mean, '.', ...
             H2B_mean(ikeep), Erk_mean(ikeep), '.')
        xlabel('mean of H2B intensity')
        ylabel('mean of Erk intensity')
        pause
    end
    
	wells(i).i1 = wells(i).i1(:,ikeep);
	wells(i).i2 = wells(i).i2(:,ikeep);
	wells(i).x  = wells(i).x(:,ikeep);
	wells(i).y  = wells(i).y(:,ikeep);
    fprintf('.')
end
fprintf('\n')
